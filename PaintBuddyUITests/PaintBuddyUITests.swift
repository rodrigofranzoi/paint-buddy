import XCTest

final class PaintBuddyUITests: XCTestCase {
    func testLaunchShowsApp() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.exists)
    }
}
