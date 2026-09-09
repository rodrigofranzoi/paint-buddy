import XCTest
@testable import PaintBuddy
import BuddyCore
import AppKit

final class ColorStoreTests: XCTestCase {
    @MainActor
    func testIngestHex() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("#1A73E8"))
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.items.first?.kind, .hex)
    }

    @MainActor
    func testIngestNamed() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("red"))
        XCTAssertEqual(store.items.first?.kind, .named)
    }

    @MainActor
    func testIgnoresNonColor() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertFalse(store.ingestClipboardText("hello world"))
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testCopyDoesNotAddHistory() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("#1A73E8"))
        let count = store.items.count
        guard let item = store.items.first else {
            return XCTFail("Expected a color item")
        }
        store.copyItem(item, format: .hex)
        store.copyString("#FF0000")
        XCTAssertEqual(store.items.count, count)
    }

    @MainActor
    func testFavoriteAddDedupeAndRemove() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("#1A73E8"))
        guard let item = store.items.first else {
            return XCTFail("Expected a color item")
        }

        store.addFavorite(item)
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertTrue(store.isFavorite(item))

        store.addFavorite(item)
        XCTAssertEqual(store.favorites.count, 1, "Duplicate hex should not create a second favorite")

        store.toggleFavorite(item)
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertFalse(store.isFavorite(hex: "#1A73E8"))
    }

    @MainActor
    func testFavoritePersistsSeparatelyFromHistory() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("#10B981"))
        guard let item = store.items.first else {
            return XCTFail("Expected a color item")
        }
        store.addFavorite(item)
        store.clearAllHistory()
        XCTAssertTrue(store.items.isEmpty)
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertEqual(store.favorites.first?.hex.uppercased(), "#10B981")
    }

    @MainActor
    func testDeleteHistoryDoesNotRemoveFavorite() {
        let store = ColorStore()
        store.clearAllHistory()
        clearFavorites(store)
        XCTAssertTrue(store.ingestClipboardText("#F59E0B"))
        guard let item = store.items.first else {
            return XCTFail("Expected a color item")
        }
        store.addFavorite(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
        XCTAssertEqual(store.favorites.count, 1)
    }

    func testSuggestionsIncludeRelativesAndHarmony() {
        let color = NSColor(srgbRed: 0.486, green: 0.227, blue: 0.929, alpha: 1)
        let suggestions = PaintColorSuggestions.suggestions(from: color)
        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertTrue(suggestions.contains { $0.kind == .darker })
        XCTAssertTrue(suggestions.contains { $0.kind == .lighter })
        XCTAssertTrue(suggestions.contains { $0.kind == .complementary })
        XCTAssertTrue(suggestions.contains { $0.kind == .analogous })
        XCTAssertTrue(suggestions.contains { $0.kind == .muted })
        let baseHex = EditorRedactionSettings.hex(from: color).uppercased()
        XCTAssertFalse(suggestions.contains { $0.hex.uppercased() == baseHex })
    }

    func testRGBAComponents() {
        let color = NSColor(srgbRed: 16.0 / 255.0, green: 185.0 / 255.0, blue: 129.0 / 255.0, alpha: 0.5)
        let components = EditorRedactionSettings.rgbaComponents(from: color)
        XCTAssertEqual(components.r, 16)
        XCTAssertEqual(components.g, 185)
        XCTAssertEqual(components.b, 129)
        XCTAssertEqual(components.a, 0.5, accuracy: 0.001)
    }

    @MainActor
    private func clearFavorites(_ store: ColorStore) {
        for favorite in store.favorites {
            store.removeFavorite(favorite)
        }
    }
}
