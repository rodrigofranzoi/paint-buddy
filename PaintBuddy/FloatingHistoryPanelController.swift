import AppKit
import SwiftUI
import BuddyCore
import BuddyUI

@MainActor
final class FloatingHistoryPanelController {
    private var panel: NSPanel?
    private weak var store: ColorStore?

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
            rootView: FloatingHistoryView()
                .environmentObject(store)
                .buddyAppearance(brand: .paintBuddy)
        )
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 420),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = "Paint Buddy"
        panel.contentViewController = hosting
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.minSize = NSSize(width: 220, height: 280)
        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: frame.maxX - 280, y: frame.midY - 210))
        }
        return panel
    }
}

struct FloatingHistoryView: View {
    @EnvironmentObject private var store: ColorStore
    @AppStorage(BuddySettingsKey.paintMenuBarRecentCount) private var recentCount =
        PaintColorSettings.defaultMenuBarRecentCount
    @AppStorage(BuddySettingsKey.paintFloatingViewMode) private var viewModeRaw =
        PaintFloatingViewMode.detailed.rawValue
    @AppStorage(BuddySettingsKey.paintCopyFormat) private var copyFormatRaw =
        PaintCopyFormat.hex.rawValue

    @State private var copiedItemId: UUID?

    private var viewMode: PaintFloatingViewMode {
        PaintFloatingViewMode(rawValue: viewModeRaw) ?? .detailed
    }

    private var visibleItems: [ColorHistoryItem] {
        Array(store.items.prefix(max(recentCount * 2, 20)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: BuddyTheme.Spacing.sm) {
                Text("Palette")
                    .font(.headline)
                Spacer(minLength: 0)
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
                .frame(maxWidth: 132)
                .help("Palette layout")
                .accessibilityIdentifier("floating-view-mode")

                Button {
                    NotificationCenter.default.post(name: .paintShowColorPicker, object: nil)
                } label: {
                    Image(systemName: "eyedropper")
                }
                .buttonStyle(.borderless)
                .help("Pick Color")
                .accessibilityIdentifier("floating-pick-color")
            }
            .padding([.horizontal, .top])
            .padding(.bottom, BuddyTheme.Spacing.sm)

            if store.items.isEmpty {
                Text("Copy a color or pick one")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            } else {
                switch viewMode {
                case .grid:
                    gridContent
                case .minimal:
                    listContent(detailed: false)
                case .detailed:
                    listContent(detailed: true)
                }
            }
        }
        .frame(minWidth: 220, minHeight: 280)
        .accessibilityIdentifier("floating-palette")
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 64, maximum: 88), spacing: 8)],
                spacing: 8
            ) {
                ForEach(visibleItems) { item in
                    Button {
                        copyColor(item)
                    } label: {
                        let fill = item.nsColor ?? .gray
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
                                } else {
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
                    .help(copiedItemId == item.id ? "Copied" : preferredLabel(for: item))
                    .accessibilityLabel(preferredLabel(for: item))
                    .accessibilityHint("Copies to clipboard")
                    .accessibilityValue(copiedItemId == item.id ? "Copied" : "")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, BuddyTheme.Spacing.sm)
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

    private func listContent(detailed: Bool) -> some View {
        List(visibleItems, selection: $store.selectedId) { item in
            Button {
                copyColor(item)
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color(nsColor: item.nsColor ?? .gray))
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
                    if copiedItemId == item.id {
                        Text("Copied")
                            .font(.callout)
                            .foregroundStyle(.green)
                            .lineLimit(1)
                    } else if detailed {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.displayTitle)
                                .font(.callout)
                                .lineLimit(1)
                            Text(item.raw)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text(item.displayTitle)
                            .font(.callout)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .tag(item.id)
            .accessibilityHint("Copies to clipboard")
            .accessibilityValue(copiedItemId == item.id ? "Copied" : "")
        }
        .listStyle(.plain)
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
