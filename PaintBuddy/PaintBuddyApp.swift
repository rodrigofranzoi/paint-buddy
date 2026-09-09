import SwiftUI
import BuddyCore
import BuddyFirebase
import BuddyUI

@main
struct PaintBuddyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = ColorStore.shared

    private let brand = BuddyBrand.paintBuddy

    init() {
        BuddyFirebase.configure()
        BuddyFirebase.log(event: BuddyFirebase.Event.appLaunch)
    }

    var body: some Scene {
        WindowGroup("Paint Buddy") {
            DashboardView()
                .environmentObject(store)
                .frame(minWidth: 760, minHeight: 480)
                .background(BuddyMainWindowRegistrar())
                .buddyAppearance(brand: brand)
        }
        .defaultSize(width: 860, height: 560)
        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
