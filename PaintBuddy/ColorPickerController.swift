import AppKit
import BuddyCore

/// One-shot screen color sampler: eyedropper cursor, click to save into history.
@MainActor
final class ColorPickerController: NSObject {
    private weak var store: ColorStore?
    /// Retained while the system sampler UI is active.
    private var activeSampler: NSColorSampler?

    func attach(store: ColorStore) {
        self.store = store
    }

    func show() {
        // Cancel any in-flight sampler before starting a new pick.
        activeSampler = nil

        let sampler = NSColorSampler()
        activeSampler = sampler
        NSApp.activate(ignoringOtherApps: true)
        sampler.show { [weak self] color in
            Task { @MainActor in
                guard let self else { return }
                self.activeSampler = nil
                guard let color else { return }
                self.store?.addFromPicker(color: color)
            }
        }
    }
}
