import AppKit
import Foundation
import SwiftUI
import BuddyCore
import BuddyUI

@MainActor
enum PaintMarketingCaptureRunner {
    private static var hostedWindow: NSWindow?

    static func startIfNeeded(
        store: ColorStore,
        showPopover: @escaping () -> NSWindow?,
        showFloatingPanel: @escaping () -> NSWindow?,
        showFloatingFavoritesPanel: @escaping () -> NSWindow?
    ) {
        guard BuddyMarketingCapture.isEnabled else { return }

        store.stopMonitoring()
        store.installMarketingSeed()
        // Prefer light chrome for App Store assets.
        NSApp.appearance = NSAppearance(named: .aqua)
        UserDefaults.standard.set(
            BuddyAppearanceSettings.ColorSchemePreference.light.rawValue,
            forKey: BuddySettingsKey.appearanceColorScheme
        )

        Task { @MainActor in
            do {
                let out = try BuddyMarketingCapture.ensureOutputDirectory()
                await BuddyMarketingCapture.sleep(0.4)
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)

                let window = makeHostedWindow(store: store)
                window.makeKeyAndOrderFront(nil)
                await BuddyMarketingCapture.sleep(0.8)

                try await captureMainScenes(store: store, window: window, out: out)
                try await capturePalette(showFloatingPanel: showFloatingPanel, out: out)
                try await captureFavorites(showFloatingFavoritesPanel: showFloatingFavoritesPanel, out: out)
                try await captureFormats(store: store, out: out)
                try await captureMenubar(showPopover: showPopover, out: out)

                print("[BuddyMarketing] Paint Buddy captures written to \(out.path)")
                NSApp.terminate(nil)
            } catch {
                fputs("[BuddyMarketing] ERROR: \(error)\n", stderr)
                NSApp.terminate(nil)
            }
        }
    }

    private static func makeHostedWindow(store: ColorStore) -> NSWindow {
        if let hostedWindow {
            return hostedWindow
        }
        let root = DashboardView()
            .environmentObject(store)
            .frame(minWidth: 720, minHeight: 480)
            .buddyAppearance(brand: .paintBuddy)
        let hosting = NSHostingController(rootView: root)
        let window = NSWindow(contentViewController: hosting)
        window.title = String(localized: "Paint Buddy")
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 1040, height: 680))
        window.center()
        window.isReleasedWhenClosed = false
        hostedWindow = window
        BuddyMainWindow.register(window)
        return window
    }

    private static func captureMainScenes(store: ColorStore, window: NSWindow, out: URL) async throws {
        let scenes: [(String, UUID)] = [
            ("history", ColorStore.MarketingColorID.violet),
            ("pick", ColorStore.MarketingColorID.sky),
            ("detail", ColorStore.MarketingColorID.tomato)
        ]
        for (scene, id) in scenes {
            store.selectedId = id
            store.objectWillChange.send()
            BuddyMarketingCapture.stage(scene)
            await BuddyMarketingCapture.sleep(1.0)
            try BuddyMarketingCapture.captureWindow(window, to: out.appendingPathComponent("\(scene).png"))
        }
    }

    private static func capturePalette(showFloatingPanel: @escaping () -> NSWindow?, out: URL) async throws {
        hostedWindow?.orderOut(nil)
        await BuddyMarketingCapture.sleep(0.3)
        guard let panel = showFloatingPanel() else {
            throw BuddyMarketingCapture.CaptureError.missingMainWindow
        }
        BuddyMarketingCapture.stage("palette")
        await BuddyMarketingCapture.sleep(1.0)
        try BuddyMarketingCapture.captureWindow(panel, to: out.appendingPathComponent("palette.png"))
        panel.orderOut(nil)
    }

    private static func captureFavorites(
        showFloatingFavoritesPanel: @escaping () -> NSWindow?,
        out: URL
    ) async throws {
        hostedWindow?.orderOut(nil)
        await BuddyMarketingCapture.sleep(0.3)
        guard let panel = showFloatingFavoritesPanel() else {
            throw BuddyMarketingCapture.CaptureError.missingMainWindow
        }
        BuddyMarketingCapture.stage("favorites")
        await BuddyMarketingCapture.sleep(1.0)
        try BuddyMarketingCapture.captureWindow(panel, to: out.appendingPathComponent("favorites.png"))
        panel.orderOut(nil)
    }

    private static func captureFormats(store: ColorStore, out: URL) async throws {
        hostedWindow?.orderOut(nil)
        let root = SettingsView()
            .environmentObject(store)
            .frame(minWidth: 620, minHeight: 560)
        let hosting = NSHostingController(rootView: root)
        let window = NSWindow(contentViewController: hosting)
        window.title = String(localized: "Settings")
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 640, height: 600))
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        BuddyMarketingCapture.stage("formats")
        await BuddyMarketingCapture.sleep(1.0)
        try BuddyMarketingCapture.captureWindow(window, to: out.appendingPathComponent("formats.png"))
        window.orderOut(nil)
    }

    private static func captureMenubar(showPopover: @escaping () -> NSWindow?, out: URL) async throws {
        hostedWindow?.orderOut(nil)
        await BuddyMarketingCapture.sleep(0.3)
        guard let popoverWindow = showPopover() else {
            throw BuddyMarketingCapture.CaptureError.missingPopoverWindow
        }
        BuddyMarketingCapture.stage("menubar")
        await BuddyMarketingCapture.sleep(0.8)
        try BuddyMarketingCapture.captureWindow(popoverWindow, to: out.appendingPathComponent("menubar.png"))
    }
}
