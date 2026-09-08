import XCTest
@testable import PaintBuddy
import BuddyCore

final class ColorStoreTests: XCTestCase {
    @MainActor
    func testIngestHex() {
        let store = ColorStore()
        store.clearAllHistory()
        XCTAssertTrue(store.ingestClipboardText("#1A73E8"))
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.items.first?.kind, .hex)
    }

    @MainActor
    func testIngestNamed() {
        let store = ColorStore()
        store.clearAllHistory()
        XCTAssertTrue(store.ingestClipboardText("red"))
        XCTAssertEqual(store.items.first?.kind, .named)
    }

    @MainActor
    func testIgnoresNonColor() {
        let store = ColorStore()
        store.clearAllHistory()
        XCTAssertFalse(store.ingestClipboardText("hello world"))
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testCopyDoesNotAddHistory() {
        let store = ColorStore()
        store.clearAllHistory()
        XCTAssertTrue(store.ingestClipboardText("#1A73E8"))
        let count = store.items.count
        guard let item = store.items.first else {
            return XCTFail("Expected a color item")
        }
        store.copyItem(item, format: .hex)
        store.copyString("#FF0000")
        XCTAssertEqual(store.items.count, count)
    }
}
