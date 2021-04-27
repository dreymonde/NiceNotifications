# NiceNotifications

<img src="_Media/icon.png" width="70">

> **[Nice Photon](https://nicephoton.com) is available for hire!** Talk to us if you have any iOS app development needs. We have 10+ years of experience making iOS apps for top Silicon Valley companies. Reach out at [hi@nicephoton.com](mailto:hi@nicephoton.com)

**NiceNotifications** reimagines local notifications on Apple platforms.

It gives developers a new way to manage notification scheduling, permissions and grouping.

At its most basic form, it helps to schedule local notifications easily, in a declarative way.

At its most advanced, it introduces a whole new way of looking at local notifications, with the concept of "Notification Timelines", similar to `WidgetKit` or `ClockKit` APIs.

Built at **[Nice Photon](https://nicephoton.com)**.  
Maintainer: [@dreymonde](https://github.com/dreymonde)

> **WARNING!** As of now, **NiceNotifications** is in early beta. Some APIs is likely to change between releases. Breaking changes are to be expected. Feedback on the API is very welcome!

## Showcase

```swift
import NiceNotifications

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryMonth(forMonths: 12, starting: .thisMonth)
        .first(.friday)
        .at(hour: 20, minute: 15)
        .schedule(title: "First Friday", body: "Oakland let's go!")
}
```

## Installation

### Swift Package Manager
1. Click File &rarr; Swift Packages &rarr; Add Package Dependency.
2. Enter `http://github.com/nicephoton/NiceNotifications.git`

## Basics Guide

### Scheduling a one-off notification

```swift
// `NotificationContent` is a subclass of `UNNotificationContent`.
// You can also use `UNNotificationContent` directly
let content = NotificationContent(
    title: "Test Notification",
    body: "This one is for a README",
    sound: .default
)

LocalNotifications.schedule(
    content: content,
    at: Tomorrow().at(hour: 20, minute: 15),
    permissionStrategy: .scheduleIfSystemAllowed
)
```

### What is `permissionStrategy`?

In most cases, **NiceNotifications** will handle all the permission stuff for you. So you can feel free to schedule notifications at any time, and permission strategy will take care of permissions.

Basic permission strategies:

1. `askSystemPermissionIfNeeded` - if the permission was already given, will proceed to schedule. If the permission was not yet asked, it will ask for system permission, and then proceed if successful. If the permission was rejected previously, it will not proceed.
2. `scheduleIfSystemAllowed` - will only proceed to schedule if the permission was already given before. Otherwise, will do nothing.

### What is `Tomorrow().at( ... )`?

**NiceNotifications** uses **[DateBuilder](https://github.com/nicephoton/DateBuilder)** to help define notification trigger dates in a simple, clear and easily readable way. Please refer to **[DateBuilder README](https://github.com/nicephoton/DateBuilder)** for full details.

Here's a short reference:

```swift
Today()
    .at(hour: 20, minute: 15)

NextWeek()
    .weekday(.saturday)
    .at(hour: 18, minute: 50)

EveryWeek(forWeeks: 10, starting: .thisWeek)
    .weekendStartDay
    .at(hour: 9, minute: 00)

EveryDay(forDays: 30, starting: .today)
    .at(hour: 19, minute: 15)
    
ExactlyAt(account.createdAt)
    .addingDays(15)
    
WeekOf(account.createdAt)
    .addingWeeks(1)
    .lastDay
    .at(hour: 10, minute: 00)

EveryMonth(forMonths: 12, starting: .thisMonth)
    .lastDay
    .at(hour: 23, minute: 50)

NextYear().addingYears(2)
    .firstMonth.addingMonths(3) // April (in Gregorian)
    .first(.thursday)

ExactDay(year: 2020, month: 10, day: 5)
    .at(hour: 10, minute: 15)

ExactYear(year: 2020)
    .lastMonth
    .lastDay
```

### Scheduling multiple notifications

```swift
LocalNotifications.schedule(permissionStrategy: .scheduleIfSystemAllowed) {
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
```

### Scheduling recurring notifications

> **WARNING!** iOS only allows you to have no more than 64 scheduled local notifications, the rest will be silently discarded. [(Docs)](https://developer.apple.com/documentation/uikit/uilocalnotification)

```swift
func randomContent() -> NotificationContent {
    return NotificationContent(title: String(Int.random(in: 0...100)))
}

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryDay(forDays: 30, starting: .today)
        .at(hour: 20, minute: 30, second: 30)
        .schedule(with: randomContent)
}
```

For recurring content based on date:

```swift
func content(forTriggerDate date: Date) -> NotificationContent {
    // create content based on date
}

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryDay(forDays: 30, starting: .today)
        .at(hour: 20, minute: 30, second: 30)
        .schedule(with: content(forTriggerDate:))
}
```

### Cancelling notification groups

```swift
let group = LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryDay(forDays: 30, starting: .today)
        .at(hour: 15, minute: 30)
        .schedule(title: "Hello!")
}

// later:

LocalNotifications.remove(group: group)
```

### Asking permission without scheduling

```swift
LocalNotifications.requestPermission(strategy: .askSystemPermissionIfNeeded) { success in
    if success {
        print("Allowed")
    }
}
```

### Getting current system permission status

```swift
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
```

### Scheduling directly with `UNNotificationRequest`

If you just want to use the permission portion of **NiceNotifications** and create `UNNotificationRequest` instances yourself, use `.directSchedule` function:

```swift
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
```

## Advanced Guide

### Notification Timelines

The most powerful feature of **NiceNotifications** is *timelines* within *notification groups*, which lets you describe your entire local notifications experience in a WidgetKit-like manner.

#### Case study: "Daily Quote" notifications

Let's say we have an app that shows a different quote from a list every morning. The user can also disable / enable certain quotes, or add their own.

For that, we need to define a new class that implements `LocalNotificationsGroup` protocol:

```swift
public protocol LocalNotificationsGroup {
    var groupIdentifier: String { get }    
    func getTimeline(completion: @escaping (NotificationsTimeline) -> ())
}
```

Groups not only allow you to have clear logical separation between different experiences, but to also have user permission on a per group basis (we'll get to that later).

Let's implement our `DailyQuoteGroup`:

```swift
final class DailyQuoteGroup: LocalNotificationsGroup {
    let groupIdentifier: String = "dailyQuote"

    func getTimeline(completion: @escaping (NotificationsTimeline) -> ()) {
        let timeline = NotificationsTimeline {
            EveryDay(forDays: 50, starting: .today)
                .at(hour: 9, minute: 00)
                .schedule(title: "Storms make oaks take deeper root.")
        }
        completion(timeline)
    }
}
```

But this will only give us 50 identical quotes for the next 50 days. Let's make it more interesting by giving a user an actual random quote each day:

```swift
final class DailyQuoteGroup: LocalNotificationsGroup {
    let groupIdentifier: String = "dailyQuote"

    func getTimeline(completion: @escaping (NotificationsTimeline) -> ()) {
        let timeline = NotificationsTimeline {
            EveryDay(forDays: 50, starting: .today)
                .at(hour: 9, minute: 00)
                .schedule(with: makeRandomQuoteContent)
        }
        completion(timeline)
    }

    private func makeRandomQuoteContent() -> NotificationContent? {
        guard let randomQuote = QuoteStore.enabledQuotes.randomElement() else {
            return nil
        }

        return NotificationContent(
            title: randomQuote,
            body: "Tap here for more daily inspiration"
        )
    }
}
```

Looks great! Every time `makeRandomQuoteContent` gets invoked, we'll get a different quote, which is exactly what we want.

Okay, so what do we do with it now?

#### "Rescheduling" notification groups

Scheduling notification groups is easy:

```swift
LocalNotifications.reschedule(
    group: DailyQuoteGroup(),
    permissionStrategy: .askSystemPermissionIfNeeded
) // completion is optional
```

Why is it called "reschedule"? Because every time we inkove this function with the same group, the whole timeline will be cleaned and recreated.

Why is it useful? First of all, let's say that the user has disabled one of the quotes from showing up. But it might've been already scheduled! Not a problem: we'll simply call reschedule again, and it will no longer show up:

```swift
QuoteStore.disableQuote(userDisabledQuote)

LocalNotifications.reschedule(
    group: DailyQuoteGroup(),
    permissionStrategy: .scheduleIfSystemAllowed
)
```

Since `DailyQuoteGroup` uses `QuoteStore.enabledQuotes` to generate a random quote, newly rescheduled group will not have a disabled quote anymore!

Secondly, you've noticed that we've only scheduled for 50 days since "today". This is because we cannot use system recurring notifications (since that only allows us to have the same content for each notification), and iOS only allows us no more than 64 scheduled notifications at once.

So yes, it will require us to periodically reschedule the group to "reset" the 50 days. One of the best places for that is `applicationDidFinishLaunchingWithOptions`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    LocalNotifications.reschedule(
        group: DailyQuoteGroup(),
        permissionStrategy: .scheduleIfSystemAllowed
    )

    return true
}
```

Alternatively, you can schedule background execution tasks to periodically refresh notifications.

### Group-level permissions

Permission Strategy has two different levels:

- System level: basically if user allowed the app to send notifications. This is the regular "App X wants to send notifications" permission.
- Group level: this relates to whether the user has enabled a certain group. For example, user can opt in to receive a quote every evening, but not receive one in the morning.

Here's how to make your own custom permission strategy:

```swift
LocalNotifications.PermissionStrategy(
    groupLevel: PermissionStrategy.GroupLevel,
    systemLevel: PermissionStrategy.SystemLevel
)
```

Permission strategy will always execute group level strategy first, and if succesfull, will proceed to system level.

#### Group Level

##### `.bypass`:

Will skip group level permission check and go straight to system level. This will not change existing group-level permission, if present.

##### `.allowAutomatically`:

Will enable permission on a group level and will save that decision, and will then proceed to system level check.

If the user previously disabled / denied this group permission, `.allowAutomatically` will overwrite that decision.

##### `.askPermission(AskPermissionMode, PermissionAsker)`: 

Will ask user's permission before proceeding to system level check, and will save that decission. Will only ask permission if the permission was not given before, otherwise will proceed straight to system level check.

**AskPermissionMode**:

- `.once`: will only ask for permission once. If the user has denied this group, any subsequent call will not ask for permission, and will not schedule notifications
- `.alwaysIfNotAllowed`: will always ask for permission if it was not already given

**PermissionAsker**:

This class is responsible for asking group-level permission. You can use `.defaultAlert(on:)` to show a pre-made alert (English only), use `.alert(on:title:message:noActionTitle:yesActionTitle:)`, or create your own:

```swift
let permissionAsker = LocalNotifications.ApplicationLevelPermissionAsker { (completion) in
    // ask permission, then call completion with Result<Bool, Error>
}
```

##### `.ifAlreadyAllowed`:

Will proceed to system level check only if the category was allowed before

##### `.ifAllowed(other:)`:

Will proceed to system level check only if the *other* specified category is allowed

#### System Level

##### `.askPermission`:

Will ask system notification permission if neccessary

##### `.ifAlreadyAllowed`:

Will only proceed to schedule notifications if already allowed by the system; otherwise will not proceed

### Notification Permission Switch

For `UIKit`, **NiceNotifications** provides `NotificationsPermissionSwitch`, a custom `UIView` that shows and allows to modify group-level permission for a notification group

```swift
let toggle = NotificationsPermissionSwitch(group: DailyQuoteGroup())
toggle.onEnabled = { _ in ... }
toggle.onDisabled = { _ in ... }
toggle.onDeniedBySystem = { _ in /* show "Open Settings" alert to user */ }
```

This saves you a lot of complexity that you usually need to implement yourself.

In case you want to show your own pre-permission when user tries to enable the category, you can use `.permissionAsker` property:

```swift
// make sure to not introduce retain cycles here
toggle.permissionAsker = { .defaultAlert(on: viewController) }
```

If you want to use any other control instead of a system `UISwitch`, you can write your own adapter for `NotificationPermissionView`. For reference, see `__UISwitchAdapter` in `NotificationsPermissionView.swift`.

### Disabling a notification group

Disabling a group will remove all pending notifications, as well as prevent new reschedulings until the permission is given again:

```swift
LocalNotifications.disable(group: DailyQuoteGroup())
```

### Getting group-level authorization information

```swift
let status = LocalNotifications.GroupLevelAuthorization.getCurrent(forGroup: DailyQuoteGroup().groupIdentifier)

switch status {
case .allowed: /* ... */
case .denied: /* ... */
case .notAsked: /* ... */
}
```

## Performance Improvements

### 1. Generating content asynchronously

`NotificationsTimeline` allows content to be created asynchronously, using one of available `schedule(with:)` overloads:

```swift
final class DailyQuoteGroup: LocalNotificationsGroup {
    let groupIdentifier: String = "dailyQuote"

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
```

Other available `.schedule` overloads:

```swift
.schedule(title: String? = nil, subtitle: String? = nil, body: String? = nil, sound: UNNotificationSound? = .default)
.schedule(with maker: @escaping () -> UNMutableNotificationContent?)
.schedule(with maker: @escaping (LocalNotifications.Trigger) -> UNMutableNotificationContent?)
.schedule(with maker: @escaping (_ nextTriggerDate: Date) -> UNMutableNotificationContent?)
.schedule(with asyncMaker: @escaping (_ trigger: LocalNotifications.Trigger, _ completion: @escaping (UNMutableNotificationContent?) -> Void) -> Void)
.schedule(with asyncMaker: @escaping (_ nextTriggerDate: Date, _ completion: @escaping (UNMutableNotificationContent?) -> Void) -> Void)
.schedule(with asyncMaker: @escaping (_ completion: @escaping (UNMutableNotificationContent?) -> Void) -> Void)
.schedule(with content: @autoclosure @escaping () -> UNMutableNotificationContent?)
```

### 2. Creating timeline on background queue

By default, `getTimeline` will always be called on a main thread. If your app logic allows `getTimeline` to be called on a background queue, set `preferredExecutionContext` to `.canRunOnAnyQueue`:

```swift
final class DailyQuoteGroup: LocalNotificationsGroup {
    let groupIdentifier: String = "dailyQuote"

    var preferredExecutionContext: LocalNotificationsGroupContextPreference {
        return .canRunOnAnyQueue
    }

    func getTimeline(completion: @escaping (NotificationsTimeline) -> ()) {
        ...
    }
}
```

## Apps that use NiceNotifications

1. [Ask Yourself Everyday](https://apps.apple.com/app/apple-store/id1531322948?mt=8&platform=iphone)
2. [Time and Again: Track Routines](https://apps.apple.com/app/apple-store/id1229632235?mt=8&ref=github)
3. Submit yours by opening a PR!

## Acknowledgments

Built at **[Nice Photon](https://nicephoton.com)**

Special thanks to:

 - [@camanjj](https://github.com/camanjj) for his valuable feedback on the API
