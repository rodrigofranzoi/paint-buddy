import AppKit
import SwiftUI
import BuddyCore
import BuddyUI

enum FloatingPaletteKind: Equatable {
    case history
    case favorites

    var title: String {
        switch self {
        case .history: return "History"
        case .favorites: return "Favorites"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .history: return "floating-palette"
        case .favorites: return "floating-favorites"
        }
    }
}

@MainActor
final class FloatingPalettePanelController {
    private var panel: NSPanel?
    private weak var store: ColorStore?
    private let kind: FloatingPaletteKind

    init(kind: FloatingPaletteKind) {
        self.kind = kind
    }

    func attach(store: ColorStore) {
        self.store = store
    }

    func toggle() {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
        } else {
            show()
        }
    }

    func show() {
        guard let store else { return }
        if panel == nil {
            panel = makePanel(store: store)
        }
        guard let panel else { return }
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Visible panel window for App Store marketing captures.
    var panelWindow: NSWindow? {
        panel?.isVisible == true ? panel : nil
    }

    private func makePanel(store: ColorStore) -> NSPanel {
        let hosting = NSHostingController(
            rootView: FloatingPaletteView(kind: kind)
                .environmentObject(store)
                .buddyAppearance(brand: .paintBuddy)
        )
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 420),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = kind == .history
            ? String(localized: "Paint Buddy")
            : String(localized: "Favorites")
        panel.contentViewController = hosting
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.minSize = NSSize(width: 220, height: 280)
        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            let offset: CGFloat = kind == .history ? 280 : 560
            panel.setFrameOrigin(NSPoint(x: frame.maxX - offset, y: frame.midY - 210))
        }
        return panel
    }
}

/// Backwards-compatible alias used by marketing capture / existing call sites.
typealias FloatingHistoryPanelController = FloatingPalettePanelController

extension FloatingPalettePanelController {
    /// History panel convenience used by older call sites.
    convenience init() {
        self.init(kind: .history)
    }
}

struct FloatingPaletteView: View {
    @EnvironmentObject private var store: ColorStore
    let kind: FloatingPaletteKind

    @AppStorage(BuddySettingsKey.paintMenuBarRecentCount) private var recentCount =
        PaintColorSettings.defaultMenuBarRecentCount
    @AppStorage(BuddySettingsKey.paintFloatingViewMode) private var viewModeRaw =
        PaintFloatingViewMode.detailed.rawValue
    @AppStorage(BuddySettingsKey.paintCopyFormat) private var copyFormatRaw =
        PaintCopyFormat.hex.rawValue
    @AppStorage(BuddySettingsKey.paintFloatingGridCellSize) private var gridCellSize =
        PaintColorSettings.defaultFloatingGridCellSize

    @State private var copiedItemId: UUID?
    @State private var hoveredItemId: UUID?
    @State private var showAddFavorite = false
    @State private var manualFavoriteColor = Color.white

    private var viewMode: PaintFloatingViewMode {
        PaintFloatingViewMode(rawValue: viewModeRaw) ?? .detailed
    }

    private var clampedCellSize: CGFloat {
        CGFloat(
            min(
                max(gridCellSize, PaintColorSettings.minFloatingGridCellSize),
                PaintColorSettings.maxFloatingGridCellSize
            )
        )
    }

    private var visibleItems: [ColorHistoryItem] {
        switch kind {
        case .history:
            return Array(store.items.prefix(max(recentCount * 2, 20)))
        case .favorites:
            return store.favorites
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if visibleItems.isEmpty {
                VStack(spacing: BuddyTheme.Spacing.sm) {
                    if kind == .favorites {
                        Text("No favorites yet")
                            .foregroundStyle(.secondary)
                        Text("Pick a color or add one manually")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text("Copy a color or pick one")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    Group {
                        switch viewMode {
                        case .grid:
                            gridContent
                        case .minimal:
                            listContent(detailed: false)
                        case .detailed:
                            listContent(detailed: true)
                        }
                    }
                    .onChange(of: visibleItems.first?.id) { id in
                        scrollToNewest(id, proxy: proxy)
                    }
                    .onAppear {
                        scrollToNewest(visibleItems.first?.id, proxy: proxy)
                    }
                }
            }
        }
        .frame(minWidth: 220, minHeight: 280)
        .accessibilityIdentifier(kind.accessibilityIdentifier)
        .onChange(of: gridCellSize) { newValue in
            let clamped = min(
                max(newValue, PaintColorSettings.minFloatingGridCellSize),
                PaintColorSettings.maxFloatingGridCellSize
            )
            if clamped != newValue {
                gridCellSize = clamped
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuddyTheme.Spacing.xs) {
            HStack(spacing: BuddyTheme.Spacing.xs) {
                Text(LocalizedStringKey(kind.title))
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Picker("View", selection: $viewModeRaw) {
                    Image(systemName: "square.grid.2x2")
                        .tag(PaintFloatingViewMode.grid.rawValue)
                    Image(systemName: "list.bullet")
                        .tag(PaintFloatingViewMode.minimal.rawValue)
                    Image(systemName: "list.bullet.rectangle")
                        .tag(PaintFloatingViewMode.detailed.rawValue)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .controlSize(.small)
                .frame(maxWidth: 112)
                .help("Palette layout")
                .accessibilityIdentifier("floating-view-mode")

                if viewMode == .grid {
                    Stepper(
                        value: $gridCellSize,
                        in: PaintColorSettings.minFloatingGridCellSize...PaintColorSettings.maxFloatingGridCellSize,
                        step: 8
                    ) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .controlSize(.small)
                    .help("Swatch size \(Int(clampedCellSize)) pt")
                    .accessibilityIdentifier("floating-grid-cell-size")
                }

                Button {
                    NotificationCenter.postPaintShowColorPicker(
                        destination: kind == .favorites ? .favorites : .history
                    )
                } label: {
                    Image(systemName: "eyedropper")
                }
                .buttonStyle(.borderless)
                .help(kind == .favorites ? "Pick Favorite Color" : "Pick Color")
                .accessibilityIdentifier("floating-pick-color")

                if kind == .favorites {
                    Button {
                        showAddFavorite = true
                    } label: {
                        AddFavoriteSymbol()
                    }
                    .buttonStyle(.borderless)
                    .help("Add favorite color")
                    .accessibilityIdentifier("floating-add-favorite")
                    .popover(isPresented: $showAddFavorite, arrowEdge: .bottom) {
                        AddFavoriteColorPopover(color: $manualFavoriteColor) { nsColor in
                            store.addFavorite(color: nsColor)
                            showAddFavorite = false
                        }
                    }
                }

                if kind == .history {
                    Button {
                        NotificationCenter.default.post(name: .paintToggleFloatingFavoritesPanel, object: nil)
                    } label: {
                        Image(systemName: "swatchpalette")
                    }
                    .buttonStyle(.borderless)
                    .help("Open Favorites")
                    .accessibilityIdentifier("floating-open-favorites")
                } else {
                    Button {
                        NotificationCenter.default.post(name: .paintToggleFloatingPanel, object: nil)
                    } label: {
                        Image(systemName: "clock")
                    }
                    .buttonStyle(.borderless)
                    .help("Open History")
                    .accessibilityIdentifier("floating-open-history")
                }
            }
        }
        .padding([.horizontal, .top])
        .padding(.bottom, BuddyTheme.Spacing.sm)
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: clampedCellSize, maximum: clampedCellSize),
                        spacing: 8
                    )
                ],
                spacing: 8
            ) {
                ForEach(visibleItems) { item in
                    paletteCell(item)
                        .id(item.id)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, BuddyTheme.Spacing.sm)
        }
    }

    private func paletteCell(_ item: ColorHistoryItem) -> some View {
        let fill = item.nsColor ?? .gray
        let showLabel = hoveredItemId == item.id || copiedItemId == item.id
        return Button {
            copyColor(item)
        } label: {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(nsColor: fill))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.5), lineWidth: 1)
                )
                .overlay {
                    if copiedItemId == item.id {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(.black.opacity(0.45))
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else if showLabel {
                        Text(preferredLabel(for: item))
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.55)
                            .foregroundStyle(contrastingLabelColor(for: fill))
                            .padding(4)
                            .accessibilityHidden(true)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredItemId = hovering ? item.id : (hoveredItemId == item.id ? nil : hoveredItemId)
        }
        .help(copiedItemId == item.id ? "Copied" : preferredLabel(for: item))
        .accessibilityLabel(preferredLabel(for: item))
        .accessibilityHint("Copies to clipboard")
        .accessibilityValue(copiedItemId == item.id ? "Copied" : "")
        .contextMenu { itemContextMenu(item) }
    }

    private func listContent(detailed: Bool) -> some View {
        // Do not bind List selection to `store.selectedId` — selecting a favorite while the
        // main window shows History asserts when the ID is not in that list.
        List {
            ForEach(visibleItems) { item in
                listRow(item, detailed: detailed)
                    .id(item.id)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .contextMenu { itemContextMenu(item) }
            }
        }
        .listStyle(.plain)
    }

    private func listRow(_ item: ColorHistoryItem, detailed: Bool) -> some View {
        let fill = item.nsColor ?? .gray
        let components = EditorRedactionSettings.rgbaComponents(from: fill)
        let isHovered = hoveredItemId == item.id
        return VStack(alignment: .leading, spacing: 6) {
            Button {
                copyColor(item)
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color(nsColor: fill))
                            .frame(width: 18, height: 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.5), lineWidth: 1)
                            )
                        if copiedItemId == item.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(radius: 1)
                        }
                    }
                    Text(preferredLabel(for: item))
                        .font(.callout.monospaced())
                        .fontWeight(detailed && isHovered ? .bold : .regular)
                        .lineLimit(1)
                        .foregroundStyle(copiedItemId == item.id ? BuddyTheme.BuddyColor.success : Color.primary)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(copiedItemId == item.id ? "Copied" : "Copy \(preferredLabel(for: item))")
            .accessibilityLabel(preferredLabel(for: item))
            .accessibilityHint("Copies preferred format to clipboard")
            .accessibilityValue(copiedItemId == item.id ? "Copied" : "")

            if detailed {
                VStack(alignment: .leading, spacing: 4) {
                    FloatingChannelCopyChip(label: "Hex", value: item.hex) {
                        store.copyString(item.hex)
                    }
                    HStack(spacing: 6) {
                        FloatingChannelCopyChip(label: "R", value: "\(components.r)") {
                            store.copyString("\(components.r)")
                        }
                        FloatingChannelCopyChip(label: "G", value: "\(components.g)") {
                            store.copyString("\(components.g)")
                        }
                        FloatingChannelCopyChip(label: "B", value: "\(components.b)") {
                            store.copyString("\(components.b)")
                        }
                        FloatingChannelCopyChip(label: "A", value: alphaChannelString(components.a)) {
                            store.copyString(alphaChannelString(components.a))
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.vertical, detailed ? 2 : 0)
        .onHover { hovering in
            guard detailed else { return }
            hoveredItemId = hovering ? item.id : (hoveredItemId == item.id ? nil : hoveredItemId)
        }
    }

    private func scrollToNewest(_ id: UUID?, proxy: ScrollViewProxy) {
        guard let id else { return }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(id, anchor: .top)
            }
        }
    }

    private func alphaChannelString(_ alpha: Double) -> String {
        if abs(alpha - 1) < 0.000_1 { return "1" }
        return String(alpha)
    }

    @ViewBuilder
    private func itemContextMenu(_ item: ColorHistoryItem) -> some View {
        Button("Copy") {
            copyColor(item)
        }
        if kind == .history {
            Button(store.isFavorite(item) ? "Remove Favorite" : "Favorite") {
                store.toggleFavorite(item)
            }
            Button("Delete", role: .destructive) {
                store.delete(item)
            }
        } else {
            Button("Remove Favorite", role: .destructive) {
                store.removeFavorite(item)
            }
        }
    }

    private func preferredLabel(for item: ColorHistoryItem) -> String {
        let format = PaintCopyFormat(rawValue: copyFormatRaw) ?? .hex
        return format.string(from: item.nsColor ?? .black)
    }

    private func contrastingLabelColor(for color: NSColor) -> Color {
        let rgb = color.usingColorSpace(.deviceRGB) ?? color
        let luminance =
            0.299 * rgb.redComponent
            + 0.587 * rgb.greenComponent
            + 0.114 * rgb.blueComponent
        return luminance > 0.55 ? Color.black.opacity(0.85) : Color.white.opacity(0.95)
    }

    private func copyColor(_ item: ColorHistoryItem) {
        store.copyItem(item)
        copiedItemId = item.id
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if copiedItemId == item.id {
                copiedItemId = nil
            }
        }
    }
}

private struct FloatingChannelCopyChip: View {
    let label: LocalizedStringKey
    let value: String
    let onCopy: () -> Void

    @State private var justCopied = false

    var body: some View {
        Button {
            onCopy()
            justCopied = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                justCopied = false
            }
        } label: {
            HStack(spacing: 4) {
                Text(label)
                Text(value)
            }
            .font(.caption.monospaced())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(justCopied ? BuddyTheme.BuddyColor.success.opacity(0.35) : BuddyTheme.BuddyColor.border.opacity(0.25))
            )
        }
        .buttonStyle(.plain)
        .help(justCopied ? "Copied" : "Copy \(label)")
        .accessibilityLabel(Text("Copy \(label) \(value)"))
        .accessibilityValue(justCopied ? "Copied" : "")
    }
}

/// Kept for marketing / older references that expect this type name.
typealias FloatingHistoryView = FloatingPaletteView

extension FloatingPaletteView {
    init() {
        self.init(kind: .history)
    }
}
