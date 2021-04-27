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

enum QuoteStore {
    static var allQuotes: [String] = []
    static func removeQuote(_ quote: String) { }

    static func fetchRandom(_ completion: @escaping (String) -> ()) {

    }
}

final class DailyQuoteGroup: LocalNotificationsGroup {
    let groupIdentifier: String = "dailyQuote"

    var preferredExecutionContext: LocalNotificationsGroupContextPreference {
        return .canRunOnAnyQueue
    }

    func getTimeline(completion: @escaping (NotificationsTimeline) -> ()) {
        let timeline = NotificationsTimeline {
            EveryDay(forDays: 50, starting: .today)
                .at(hour: 9, minute: 00)
                .schedule(with: makeRandomQuoteContent(completion:))
        }
        completion(timeline)
    }

    private func makeRandomQuoteContent(completion: @escaping (NotificationContent) -> ()) {
        QuoteStore.fetchRandom { (quote) in
            let content = NotificationContent(
                title: quote,
                body: "Open app for more quotes",
                sound: .default
            )
            completion(content)
        }
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    LocalNotifications.reschedule(
        group: DailyQuoteGroup(),
        permissionStrategy: .scheduleIfSystemAllowed
    )

    return true
}

func readme() {

//let toggle = NotificationsPermissionSwitch(group: DailyQuoteGroup())

    LocalNotifications.disable(group: DailyQuoteGroup())

    let userDisabledQuote = ""
QuoteStore.removeQuote(userDisabledQuote)

LocalNotifications.reschedule(
    group: DailyQuoteGroup(),
    permissionStrategy: .scheduleIfSystemAllowed
)

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryMonth(forMonths: 12, starting: .thisMonth)
        .first(.friday)
        .at(hour: 20, minute: 15)
        .schedule(title: "First Friday", body: "Oakland let's go!")
}
 
// `NotificationContent` is a subclass of `UNNotificationContent`.
// You can also use `UNNotificationContent` directly
let content = NotificationContent(
    title: "Test Notification",
    body: "This one is for a README",
    sound: .default
)
    
let group = LocalNotifications.schedule(permissionStrategy: .scheduleIfSystemAllowed) {
    Today()
        .at(hour: 20, minute: 30)
        .schedule(title: "Hello today", sound: .default)
    Tomorrow()
        .at(hour: 20, minute: 45)
        .schedule(title: "Hello tomorrow", sound: .default)
} completion: { result in
    if result.isSuccess {
        print("Scheduled!")
    }
}
    
    LocalNotifications.remove(group: group)

LocalNotifications.schedule(
    content: content,
    at: Tomorrow().at(hour: 20, minute: 15),
    group: "test-notifications",
    permissionStrategy: .scheduleIfSystemAllowed
)
    
func randomContent() -> NotificationContent {
    return NotificationContent(title: String(Int.random(in: 0 ... 100)))
}

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryDay(forDays: 30, starting: .today)
        .at(hour: 20, minute: 30, second: 30)
        .schedule(with: randomContent)
        .withTargetContentIdentifier("haha")
}
    do {
let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 360, repeats: true)

let content = UNMutableNotificationContent()
content.title = "Repeating"
content.body = "Every 6 minutes"
content.sound = .default

let request = UNNotificationRequest(
    identifier: "repeating_360",
    content: content,
    trigger: trigger
)

LocalNotifications.directSchedule(
    request: request,
    permissionStrategy: .askSystemPermissionIfNeeded
) // completion is optional
    }
    
//func content(forTriggerDate date: Date) -> NotificationContent {
//    // create content based on date
//}
//
//LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
//    EveryDay(forDays: 30, starting: .today)
//        .at(hour: 20, minute: 30, second: 30)
//        .schedule(with: content(forTriggerDate:))
//}
    
LocalNotifications.SystemAuthorization.getCurrent { status in
    switch status {
    case .allowed:
        print("allowed")
    case .deniedNow:
        print("denied")
    case .deniedPreviously:
        print("denied and needs to enable in settings")
    case .undetermined:
        print("not asked yet")
    }
    if status.isAllowed {
        print("can schedule!")
    }
}
    
LocalNotifications.requestPermission(strategy: .askSystemPermissionIfNeeded) { success in
    if success {
        print("Allowed")
    }
}
}
