import SwiftUI
import BuddyUI
import BuddyCore
import AppKit

struct MenuBarView: View {
    @EnvironmentObject private var store: ColorStore
    @EnvironmentObject private var pause: BuddyPauseController
    @AppStorage(BuddySettingsKey.paintMenuBarRecentCount) private var menuBarRecentCount =
        PaintColorSettings.defaultMenuBarRecentCount

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if pause.isPaused {
                Text(pause.statusSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .top])
            }

            HStack(spacing: BuddyTheme.Spacing.sm) {
                Button {
                    NotificationCenter.default.post(name: .paintShowColorPicker, object: nil)
                } label: {
                    Label("Pick Color", systemImage: "eyedropper")
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("menubar-pick-color")

                Button {
                    NotificationCenter.default.post(name: .paintToggleFloatingPanel, object: nil)
                } label: {
                    Label("Palette", systemImage: "rectangle.on.rectangle")
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("menubar-floating-palette")
            }
            .padding([.horizontal, .top])
            .padding(.bottom, BuddyTheme.Spacing.sm)

            Text("Recent")
                .font(.headline)
                .padding(.horizontal)

            let recent = Array(store.items.prefix(max(menuBarRecentCount, 1)))
            if recent.isEmpty {
                Text("No colors yet")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(Array(recent.enumerated()), id: \.element.id) { index, item in
                    MenuBarRow(
                        title: item.displayTitle,
                        subtitle: item.raw,
                        colorSwatch: item.nsColor.map { Color(nsColor: $0) },
                        copyAction: { store.copyItem(item) },
                        showsSeparator: index < recent.count - 1
                    ) {
                        store.copyItem(item)
                    }
                    .padding(.horizontal)
                }
            }

            Spacer(minLength: 0)

            BuddyPauseControls(pause: pause)

            BuddyClearHistoryButton(itemNoun: "colors") {
                store.clearAllHistory()
            }
            .disabled(store.items.isEmpty)

            BuddyMenuBarAppControls(appName: "Paint Buddy", brand: .paintBuddy)
        }
        .frame(width: 300, height: 480)
        .accessibilityIdentifier("menubar")
    }
}
