import SwiftUI
import BuddyCore
import BuddyUI
import AppKit

struct DashboardView: View {
    @EnvironmentObject private var store: ColorStore

    private var selected: ColorHistoryItem? {
        store.items.first { $0.id == store.selectedId }
    }

    var body: some View {
        NavigationSplitView {
            BuddyListChrome(query: $store.query) {
                List(store.filtered, selection: $store.selectedId) { item in
                    ColorHistoryRow(item: item)
                        .tag(item.id)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(BuddyTheme.BuddyColor.border.opacity(0.4))
                        .accessibilityIdentifier("history-row")
                        .contextMenu {
                            Button("Copy") {
                                store.copyItem(item)
                            }
                            Button("Delete", role: .destructive) {
                                store.delete(item)
                            }
                        }
                }
                .listStyle(.inset)
                .accessibilityIdentifier("history-list")
            }
            .navigationTitle("Colors")
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 420)
        } detail: {
            if let selected {
                ColorDetailPane(item: selected)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "paintpalette")
                        .font(.largeTitle)
                    Text("Select a color")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    NotificationCenter.default.post(name: .paintShowColorPicker, object: nil)
                } label: {
                    Image(systemName: "eyedropper")
                }
                .help("Pick Color")
                .accessibilityIdentifier("toolbar-pick-color")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    NotificationCenter.default.post(name: .paintToggleFloatingPanel, object: nil)
                } label: {
                    Image(systemName: "rectangle.on.rectangle")
                }
                .help("Floating Palette")
                .accessibilityIdentifier("toolbar-floating-palette")
            }
            ToolbarItem(placement: .primaryAction) {
                BuddyClearHistoryButton(itemNoun: "colors", style: .toolbar) {
                    store.clearAllHistory()
                }
                .disabled(store.items.isEmpty)
            }
            ToolbarItem(placement: .automatic) {
                BuddySettingsGearButton()
            }
        }
    }
}

struct ColorHistoryRow: View {
    @EnvironmentObject private var store: ColorStore
    let item: ColorHistoryItem

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(nsColor: item.nsColor ?? .gray))
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.5), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.buddyBody)
                    .lineLimit(1)
                Text(item.raw)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)

            Button {
                store.copyItem(item)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Copy color")
        }
        .padding(.vertical, 2)
    }
}

struct ColorDetailPane: View {
    @EnvironmentObject private var store: ColorStore
    let item: ColorHistoryItem

    @State private var swatchJustCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: BuddyTheme.Spacing.md) {
            Button {
                store.copyItem(item)
                swatchJustCopied = true
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_200_000_000)
                    swatchJustCopied = false
                }
            } label: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: item.nsColor ?? .gray))
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.4), lineWidth: 1)
                    )
                    .overlay {
                        if swatchJustCopied {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.black.opacity(0.4))
                            Label("Copied", systemImage: "checkmark.circle.fill")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Copy preferred format")
            .accessibilityLabel(item.displayTitle)
            .accessibilityHint("Copies to clipboard")
            .accessibilityValue(swatchJustCopied ? "Copied" : "")

            Group {
                CopyableColorValueRow(title: "Hex", value: item.hex) {
                    store.copyItem(item, format: .hex)
                }
                if let color = item.nsColor {
                    CopyableColorValueRow(
                        title: "RGB",
                        value: EditorRedactionSettings.rgbString(from: color)
                    ) {
                        store.copyItem(item, format: .rgb)
                    }
                    CopyableColorValueRow(
                        title: "RGBA",
                        value: EditorRedactionSettings.rgbaString(from: color)
                    ) {
                        store.copyItem(item, format: .rgba)
                    }
                }
                LabeledContent("Captured") {
                    Text(item.raw)
                        .textSelection(.enabled)
                }
                LabeledContent("Source") {
                    Text(item.source == .picker ? "Color Panel" : "Clipboard")
                }
            }
            .font(.buddyBody)

            HStack {
                Button("Copy Preferred Format") {
                    store.copyItem(item)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("detail-copy")

                Spacer()
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(item.displayTitle)
    }
}

/// Tappable color format value with a trailing copy button. Copy does not add to history.
private struct CopyableColorValueRow: View {
    let title: String
    let value: String
    let onCopy: () -> Void

    @State private var valueJustCopied = false
    @State private var buttonJustCopied = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: BuddyTheme.Spacing.sm) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)

            Button(action: copyValue) {
                Text(valueJustCopied ? "Copied" : value)
                    .foregroundStyle(valueJustCopied ? Color.green : Color.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(valueJustCopied ? "Copied" : "Copy \(title)")
            .accessibilityLabel("\(title) \(value)")
            .accessibilityHint("Copies to clipboard")
            .accessibilityValue(valueJustCopied ? "Copied" : "")

            Button(action: copyButton) {
                Image(systemName: buttonJustCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(buttonJustCopied ? Color.green : Color.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(buttonJustCopied ? "Copied" : "Copy \(title)")
            .help(buttonJustCopied ? "Copied" : "Copy to clipboard")
        }
    }

    private func copyValue() {
        onCopy()
        valueJustCopied = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            valueJustCopied = false
        }
    }

    private func copyButton() {
        onCopy()
        buttonJustCopied = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            buttonJustCopied = false
        }
    }
}
