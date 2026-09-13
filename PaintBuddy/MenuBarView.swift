import SwiftUI
import BuddyUI
import BuddyCore
import AppKit

struct MenuBarView: View {
    @EnvironmentObject private var store: ColorStore
    @EnvironmentObject private var pause: BuddyPauseController
    @AppStorage(BuddySettingsKey.paintMenuBarRecentCount) private var menuBarRecentCount =
        PaintColorSettings.defaultMenuBarRecentCount

    private var recent: [ColorHistoryItem] {
        Array(store.items.prefix(max(menuBarRecentCount, 1)))
    }

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
                    NotificationCenter.postPaintShowColorPicker()
                } label: {
                    Image(systemName: "eyedropper")
                }
                .buttonStyle(.borderless)
                .help("Pick Color")
                .accessibilityLabel("Pick Color")
                .accessibilityIdentifier("menubar-pick-color")

                Button {
                    NotificationCenter.default.post(name: .paintToggleFloatingPanel, object: nil)
                } label: {
                    Image(systemName: "clock")
                }
                .buttonStyle(.borderless)
                .help("History Palette")
                .accessibilityLabel("History Palette")
                .accessibilityIdentifier("menubar-floating-palette")

                Button {
                    NotificationCenter.default.post(name: .paintToggleFloatingFavoritesPanel, object: nil)
                } label: {
                    Image(systemName: "swatchpalette")
                }
                .buttonStyle(.borderless)
                .help("Favorites Palette")
                .accessibilityLabel("Favorites Palette")
                .accessibilityIdentifier("menubar-floating-favorites")

                Spacer(minLength: 0)
            }
            .padding([.horizontal, .top])
            .padding(.bottom, BuddyTheme.Spacing.sm)

            Text("Recent")
                .font(.headline)
                .padding(.horizontal)

            if recent.isEmpty {
                Text("No colors yet")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            BuddyMenuBarFooter {
                BuddyPauseControls(pause: pause)

                BuddyClearHistoryButton(itemNoun: "colors") {
                    store.clearAllHistory()
                }
                .disabled(store.items.isEmpty)

                BuddyMenuBarAppControls(appName: "Paint Buddy", brand: .paintBuddy)
            }
        }
        .frame(width: 300, height: 480)
        .accessibilityIdentifier("menubar")
    }
}
