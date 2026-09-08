import AppKit
import Foundation
import BuddyCore
import BuddyFirebase
import Combine

struct ColorHistoryItem: Identifiable, Codable, Equatable, Hashable {
    enum Source: String, Codable, Sendable {
        case clipboard
        case picker
    }

    var id: UUID
    var createdAt: Date
    /// Canonical `#RRGGBB` (or `#RRGGBBAA` when alpha < 1).
    var hex: String
    /// Original clipboard / picker token.
    var raw: String
    var kind: ColorTokenKind
    var source: Source
    var alpha: Double

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        hex: String,
        raw: String,
        kind: ColorTokenKind,
        source: Source,
        alpha: Double = 1
    ) {
        self.id = id
        self.createdAt = createdAt
        self.hex = hex
        self.raw = raw
        self.kind = kind
        self.source = source
        self.alpha = alpha
    }

    var nsColor: NSColor? {
        EditorRedactionSettings.nsColor(fromColorToken: hex)
            ?? EditorRedactionSettings.nsColor(fromColorToken: raw)
    }

    var displayTitle: String {
        PaintColorSettings.copyFormat.string(from: nsColor ?? .black)
    }
}

extension Notification.Name {
    static let paintToggleFloatingPanel = Notification.Name("paint.buddy.toggleFloatingPanel")
    static let paintShowColorPicker = Notification.Name("paint.buddy.showColorPicker")
}

@MainActor
final class ColorStore: ObservableObject {
    static let shared = ColorStore()

    @Published var items: [ColorHistoryItem] = []
    @Published var selectedId: UUID?
    @Published var query: String = ""
    @Published var maxHistoryCount: Int = PaintColorSettings.maxHistoryCount

    private var timer: Timer?
    private var lastChangeCount: Int = -1
    private let historyKey = "paint.history"

    init() {
        load()
    }

    var filtered: [ColorHistoryItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return items }
        return items.filter {
            $0.hex.lowercased().contains(q)
                || $0.raw.lowercased().contains(q)
                || $0.kind.rawValue.contains(q)
        }
    }

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollPasteboard()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func pollPasteboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        guard let text = pb.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty
        else { return }

        ingestClipboardText(text)
    }

    /// Parses clipboard text and prepends allowed color tokens.
    @discardableResult
    func ingestClipboardText(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var added = false

        if let kind = EditorRedactionSettings.colorTokenKind(trimmed),
           PaintColorSettings.allows(kind),
           let color = EditorRedactionSettings.nsColor(fromColorToken: trimmed) {
            prepend(makeItem(color: color, raw: trimmed, kind: kind, source: .clipboard))
            return true
        }

        let tokens = DetectedContentExtractor.extractTokens(from: trimmed)
            .filter { $0.kind == .color }
        for token in tokens {
            guard let kind = EditorRedactionSettings.colorTokenKind(token.raw),
                  PaintColorSettings.allows(kind),
                  let color = token.nsColor
            else { continue }
            prepend(makeItem(color: color, raw: token.raw, kind: kind, source: .clipboard))
            added = true
        }
        return added
    }

    func addFromPicker(color: NSColor) {
        let converted = color.usingColorSpace(.sRGB) ?? color
        let format = PaintColorSettings.copyFormat
        let raw = format.string(from: converted)
        let kind: ColorTokenKind = {
            switch format {
            case .hex: return .hex
            case .rgb: return .rgb
            case .rgba: return .rgba
            }
        }()
        prepend(makeItem(color: converted, raw: raw, kind: kind, source: .picker))
        copyStringToPasteboard(raw)
    }

    /// Copies a color string to the pasteboard without adding a history entry.
    func copyString(_ string: String) {
        copyStringToPasteboard(string)
    }

    /// Copies the preferred format (or an explicit format). Does not add to history.
    func copyItem(_ item: ColorHistoryItem, format: PaintCopyFormat? = nil) {
        guard let color = item.nsColor else {
            copyStringToPasteboard(item.raw)
            return
        }
        let resolved = format ?? PaintColorSettings.copyFormat
        switch resolved {
        case .hex:
            copyStringToPasteboard(item.hex)
        case .rgb, .rgba:
            copyStringToPasteboard(resolved.string(from: color))
        }
    }

    func delete(_ item: ColorHistoryItem) {
        items.removeAll { $0.id == item.id }
        if selectedId == item.id { selectedId = items.first?.id }
        save()
    }

    func clearAllHistory() {
        items = []
        selectedId = nil
        save()
    }

    func applyHistoryLimits() {
        maxHistoryCount = PaintColorSettings.maxHistoryCount
        prune()
        save()
    }

    private func makeItem(
        color: NSColor,
        raw: String,
        kind: ColorTokenKind,
        source: ColorHistoryItem.Source
    ) -> ColorHistoryItem {
        let converted = color.usingColorSpace(.sRGB) ?? color
        let alpha = Double(converted.alphaComponent)
        let hex: String = {
            if alpha < 0.999 {
                let r = Int(round(converted.redComponent * 255))
                let g = Int(round(converted.greenComponent * 255))
                let b = Int(round(converted.blueComponent * 255))
                let a = Int(round(converted.alphaComponent * 255))
                return String(format: "#%02X%02X%02X%02X", r, g, b, a)
            }
            return EditorRedactionSettings.hex(from: converted)
        }()
        return ColorHistoryItem(
            hex: hex,
            raw: raw,
            kind: kind,
            source: source,
            alpha: alpha
        )
    }

    private func prepend(_ item: ColorHistoryItem) {
        // Dedupe consecutive identical hex.
        if let first = items.first, first.hex.compare(item.hex, options: .caseInsensitive) == .orderedSame {
            items[0] = item
            selectedId = item.id
            save()
            return
        }
        items.insert(item, at: 0)
        selectedId = item.id
        prune()
        save()
        BuddyFirebase.log(event: "color_saved", parameters: ["source": item.source.rawValue])
    }

    private func prune() {
        let limit = PaintColorSettings.maxHistoryCount
        maxHistoryCount = limit
        if items.count > limit {
            items = Array(items.prefix(limit))
        }
    }

    private func copyStringToPasteboard(_ string: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(string, forType: .string)
        lastChangeCount = pb.changeCount
    }

    /// Replaces history for App Store marketing captures.
    func installMarketingSeed() {
        UserDefaults.standard.set(
            PaintFloatingViewMode.grid.rawValue,
            forKey: BuddySettingsKey.paintFloatingViewMode
        )
        UserDefaults.standard.set(
            PaintCopyFormat.hex.rawValue,
            forKey: BuddySettingsKey.paintCopyFormat
        )

        let now = Date()
        items = [
            ColorHistoryItem(
                id: MarketingColorID.violet,
                createdAt: now.addingTimeInterval(-60),
                hex: "#7C3AED",
                raw: "#7C3AED",
                kind: .hex,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.emerald,
                createdAt: now.addingTimeInterval(-120),
                hex: "#10B981",
                raw: "rgb(16, 185, 129)",
                kind: .rgb,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.tomato,
                createdAt: now.addingTimeInterval(-180),
                hex: "#FF6347",
                raw: "tomato",
                kind: .named,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.sky,
                createdAt: now.addingTimeInterval(-240),
                hex: "#0EA5E9",
                raw: "#0EA5E9",
                kind: .hex,
                source: .picker
            ),
            ColorHistoryItem(
                id: MarketingColorID.amber,
                createdAt: now.addingTimeInterval(-300),
                hex: "#F59E0B",
                raw: "rgba(245, 158, 11, 1)",
                kind: .rgba,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.rose,
                createdAt: now.addingTimeInterval(-360),
                hex: "#F43F5E",
                raw: "(244, 63, 94)",
                kind: .tuple,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.indigo,
                createdAt: now.addingTimeInterval(-420),
                hex: "#6366F1",
                raw: "#6366F1",
                kind: .hex,
                source: .clipboard
            ),
            ColorHistoryItem(
                id: MarketingColorID.slate,
                createdAt: now.addingTimeInterval(-480),
                hex: "#64748B",
                raw: "#64748B",
                kind: .hex,
                source: .clipboard
            )
        ]
        selectedId = MarketingColorID.violet
        save()
    }

    enum MarketingColorID {
        static let violet = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000001")!
        static let emerald = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000002")!
        static let tomato = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000003")!
        static let sky = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000004")!
        static let amber = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000005")!
        static let rose = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000006")!
        static let indigo = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000007")!
        static let slate = UUID(uuidString: "CCCCCCCC-0001-4000-8000-000000000008")!
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([ColorHistoryItem].self, from: data)
        else { return }
        items = decoded
        selectedId = items.first?.id
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }
}
