import SwiftUI
import BuddyCore
import BuddyUI

struct SettingsView: View {
    @EnvironmentObject private var store: ColorStore

    private let brand = BuddyBrand.paintBuddy
    private let items: [BuddySettingsItem] = [
        .appearance,
        .preferences,
        .privacy
    ]

    var body: some View {
        BuddySettingsSidebarView(
            brand: brand,
            items: items,
            initialSelection: BuddyMarketingCapture.isEnabled ? .preferences : nil
        ) { item in
            switch item.id {
            case BuddySettingsItem.appearance.id:
                BuddyAppearanceSettingsSection(brand: brand)
            case BuddySettingsItem.preferences.id:
                PaintHistorySettingsSection {
                    store.applyHistoryLimits()
                }
                PaintFormatSettingsSection()
                BuddyPauseSettingsSection()
                BuddyClearHistorySettingsSection(itemNoun: "colors") {
                    store.clearAllHistory()
                }
                Section("Startup") {
                    BuddyLaunchAtLoginToggle()
                }
            case BuddySettingsItem.privacy.id:
                BuddyLegalLinksSection(brand: brand)
            default:
                EmptyView()
            }
        }
        .accessibilityIdentifier("settings")
    }
}
