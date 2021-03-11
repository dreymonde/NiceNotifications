# NiceNotifications

<img src="_Media/icon.png" width="70">

> **[Nice Photon](https://nicephoton.com) is available for hire!** Talk to us if you have any iOS app development needs. We have 10+ years of experience making iOS apps for top Silicon Valley companies. Reach out at [hi@nicephoton.com](mailto:hi@nicephoton.com)

**NiceNotifications**

Built at **[Nice Photon](https://nicephoton.com)**.  
Maintainer: [@dreymonde](https://github.com/dreymonde)

As of now, **NiceNotifications** is in early beta. Some APIs is likely to change between releases. Breaking changes are to be expected. Feedback on the API is very welcome!

## Usage

```swift
import DateBuilder

Today()
    .at(hour: 20, minute: 15)
    .dateComponents() // year: 2021, month: 1, day: 31, hour: 20, minute: 15

NextWeek()
    .weekday(.saturday)
    .at(hour: 18, minute: 50)
    .dateComponents() // DateComponents

EveryWeek(forWeeks: 10, starting: .thisWeek)
    .weekendStartDay
    .at(hour: 9, minute: 00)
    .dates() // [Date]
    
ExactlyAt(account.createdAt)
    .addingDays(15)
    .date() // Date
    
WeekOf(account.createdAt)
    .addingWeeks(1)
    .lastDay
    .at(hour: 10, minute: 00)
    .dateComponents() // DateComponents

EveryMonth(forMonths: 12, starting: .thisMonth)
    .lastDay
    .at(hour: 23, minute: 50)
    .dateComponents() // [DateComponents]

NextYear().addingYears(2)
    .firstMonth.addingMonths(3) // April (in Gregorian)
    .first(.thursday)
    .dateComponents() // year: 2024, month: 4, day: 4

ExactDay(year: 2020, month: 10, day: 5)
    .at(hour: 10, minute: 15)
    .date() // Date

ExactYear(year: 2020)
    .lastMonth
    .lastDay
    .dateComponents()
```

## Guide

### Chapter Zero

## Installation

### Swift Package Manager
1. Click File &rarr; Swift Packages &rarr; Add Package Dependency.
2. Enter `http://github.com/nicephoton/NiceNotifications.git`

## Acknowledgments

Built at **[Nice Photon](https://nicephoton.com)**

Special thanks to:

 - [@camanjj](https://github.com/camanjj) for his valuable feedback on the API
