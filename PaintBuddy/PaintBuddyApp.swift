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
                .frame(minWidth: 640, minHeight: 420)
                .background(BuddyMainWindowRegistrar())
                .buddyAppearance(brand: brand)
        }
        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
