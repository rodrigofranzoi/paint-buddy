import AppKit
import SwiftUI
import BuddyCore
import BuddyUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var popoverOutsideClickMonitors: [Any] = []
    var store: ColorStore?
    private let floatingPanel = FloatingPalettePanelController(kind: .history)
    private let floatingFavoritesPanel = FloatingPalettePanelController(kind: .favorites)
    private let colorPicker = ColorPickerController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        BuddyLaunchAtLogin.enableByDefaultOnFirstInstall()
        BuddyAppearanceSettings.applyAppKitAppearance()
        BuddyAppReviewPrompt.shared.recordLaunch()

        let store = ColorStore.shared
        self.store = store
        floatingPanel.attach(store: store)
        floatingFavoritesPanel.attach(store: store)
        colorPicker.attach(store: store)

        let pause = BuddyPauseController.shared
        pause.onPauseChanged = { [weak self] isPaused in
            if isPaused {
                self?.store?.stopMonitoring()
            } else {
                self?.store?.startMonitoring()
            }
            self?.updateStatusIcon()
        }
        pause.restorePersistedPauseIfNeeded()
        if !pause.isPaused {
            store.startMonitoring()
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
        statusItem = item
        updateStatusIcon()

        let popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
        popover.contentSize = NSSize(width: 300, height: 480)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(store)
                .environmentObject(pause)
                .buddyAppearance(brand: .paintBuddy)
        )
        self.popover = popover

        NotificationCenter.default.addObserver(
            forName: .buddyPauseDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatusIcon()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .paintToggleFloatingPanel,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.floatingPanel.toggle()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .paintToggleFloatingFavoritesPanel,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.floatingFavoritesPanel.toggle()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .paintShowColorPicker,
            object: nil,
            queue: .main
        ) { [weak self] note in
            let destination = PaintColorPickDestination.fromNotification(note)
            Task { @MainActor in
                self?.beginColorPick(destination: destination)
            }
        }

        if BuddyMarketingCapture.isEnabled {
            NSApp.setActivationPolicy(.regular)
            PaintMarketingCaptureRunner.startIfNeeded(
                store: store,
                showPopover: { [weak self] in self?.showPopoverForCapture() },
                showFloatingPanel: { [weak self] in self?.showFloatingPanelForCapture() }
            )
        } else {
            if PaintColorSettings.floatingPanelOnLaunch {
                floatingPanel.show()
            }
            BuddyMainWindow.hideOnLaunchIfNeeded()
        }
    }

    @discardableResult
    private func showPopoverForCapture() -> NSWindow? {
        showPopover()
        return popover?.contentViewController?.view.window
    }

    @discardableResult
    private func showFloatingPanelForCapture() -> NSWindow? {
        floatingPanel.show()
        return floatingPanel.panelWindow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc private func togglePopover() {
        guard let popover else { return }
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    /// Dismisses the menu-bar popover while sampling, then restores it after pick/cancel if it was open.
    private func beginColorPick(destination: PaintColorPickDestination = .history) {
        let shouldRestorePopover = popover?.isShown == true
        if shouldRestorePopover {
            closePopover()
        }

        // Let the popover finish dismissing so the eyedropper can receive clicks.
        Task { @MainActor in
            if shouldRestorePopover {
                try? await Task.sleep(nanoseconds: 80_000_000)
            }
            colorPicker.show(destination: destination) { [weak self] in
                guard shouldRestorePopover else { return }
                self?.showPopover()
            }
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button, let popover else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
        popover.contentViewController?.view.window?.makeKey()
        startOutsideClickMonitoring()
    }

    private func closePopover() {
        popover?.performClose(nil)
        stopOutsideClickMonitoring()
    }

    private func startOutsideClickMonitoring() {
        stopOutsideClickMonitoring()

        if let global = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            Task { @MainActor in
                self?.dismissPopoverIfClickOutside()
            }
        } {
            popoverOutsideClickMonitors.append(global)
        }

        if let local = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            Task { @MainActor in
                self?.dismissPopoverIfClickOutside()
            }
            return event
        } {
            popoverOutsideClickMonitors.append(local)
        }
    }

    private func stopOutsideClickMonitoring() {
        for monitor in popoverOutsideClickMonitors {
            NSEvent.removeMonitor(monitor)
        }
        popoverOutsideClickMonitors.removeAll()
    }

    private func dismissPopoverIfClickOutside() {
        guard let popover, popover.isShown else { return }

        let location = NSEvent.mouseLocation

        if let popoverWindow = popover.contentViewController?.view.window,
           popoverWindow.frame.contains(location) {
            return
        }

        if let button = statusItem?.button,
           let buttonWindow = button.window {
            let buttonFrame = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
            if buttonFrame.contains(location) {
                return
            }
        }

        closePopover()
    }

    private func updateStatusIcon() {
        let paused = BuddyPauseController.shared.isPaused
        let name = paused ? "paintpalette.fill" : "paintpalette"
        let description = paused ? "Paint Buddy (paused)" : "Paint Buddy"
        statusItem?.button?.image = NSImage(systemSymbolName: name, accessibilityDescription: description)
        statusItem?.button?.appearsDisabled = paused
    }
}

extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        stopOutsideClickMonitoring()
    }
}
