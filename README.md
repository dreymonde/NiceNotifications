# NiceNotifications

<img src="_Media/icon.png" width="70">

> **[Nice Photon](https://nicephoton.com) is available for hire!** Talk to us if you have any iOS app development needs. We have 10+ years of experience making iOS apps for top Silicon Valley companies. Reach out at [hi@nicephoton.com](mailto:hi@nicephoton.com)

**NiceNotifications** reimagines local notifications on Apple platforms.

It gives developers a new way to manage notification scheduling, permissions and grouping.

At its most basic form, it helps to schedule local notifications easily, in a declarative way.

At its most advanced, it introduces a whole new way of looking at local notifications, with the concept of "Notification Timelines", similar to `WidgetKit` or `ClockKit` APIs.

Built at **[Nice Photon](https://nicephoton.com)**.  
Maintainer: [@dreymonde](https://github.com/dreymonde)

As of now, **NiceNotifications** is in early beta. Some APIs is likely to change between releases. Breaking changes are to be expected. Feedback on the API is very welcome!

## Usage

```swift
import NiceNotifications

LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
    EveryMonth(forMonths: 12, starting: .thisMonth)
        .first(.friday)
        .at(hour: 20, minute: 15)
        .schedule(title: "First Friday", body: "Oakland let's go!")
}
```

## Guide

WIP

## Installation

### Swift Package Manager
1. Click File &rarr; Swift Packages &rarr; Add Package Dependency.
2. Enter `http://github.com/nicephoton/NiceNotifications.git`

## Acknowledgments

Built at **[Nice Photon](https://nicephoton.com)**

Special thanks to:

 - [@camanjj](https://github.com/camanjj) for his valuable feedback on the API
