import XCTest
@testable import NiceNotifications

final class NiceNotificationsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

func readme() {
LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryMonth(forMonths: 12, starting: .thisMonth)
        .first(.friday)
        .at(hour: 20, minute: 15)
        .schedule(title: "First Friday", body: "Oakland let's go!")
}
}
