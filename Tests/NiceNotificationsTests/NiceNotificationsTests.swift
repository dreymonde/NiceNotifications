import XCTest
@testable import NiceNotifications

final class NiceNotificationsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NiceNotifications().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
