//
//  File.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//


import UIKit

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    func toLocalTime() -> Date {
        let timezone = TimeZone.current

        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))

        return Date(timeInterval: seconds, since: self)
    }

    func toGlobalTime() -> Date {
        let timezone = TimeZone.current

        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))

        return Date(timeInterval: seconds, since: self)
    }

    /// Переводит вермя на московское
    func toMSKTime() -> Date {
        guard let timezoneMSK = TimeZone(identifier: "GMT+03:00") else { return self }
        let currentTimezone = TimeZone.current

        let secontMSK = timezoneMSK.secondsFromGMT(for: Date())
        let secondCurrent = currentTimezone.secondsFromGMT(for: Date())

        let seconds = -TimeInterval(secondCurrent - secontMSK)
        return Date(timeInterval: seconds, since: self)
    }
}

extension Date {
    var timestampInMilliseconds: UInt64 {
        UInt64(timeIntervalSince1970 * 1000)
    }
}

extension Date {
    /// Вчерашний день
    static var yesterday: Date { return Date().dayBefore }
    /// Завтрашний день
    static var tomorrow: Date { return Date().dayAfter }

    /// День до текущей даты
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -.one, to: noon) ?? .now
    }

    /// День после текущей даты
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: .one, to: noon) ?? .now
    }

    /// Полуночь даты
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: .zero, second: .zero, of: self) ?? .now
    }
}

extension Date? {
    var orNow: Date {
        self ?? .now
    }
}
