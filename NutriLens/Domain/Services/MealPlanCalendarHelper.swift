//
//  MealPlanCalendarHelper.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Encapsulates robust, timezone-aware Monday-to-Sunday calendar operations.
//

import Foundation

public struct MealPlanCalendarHelper: Sendable {
    public let calendar: Calendar

    public init(calendar: Calendar = .current) {
        var cal = calendar
        cal.firstWeekday = 2 // Monday is standard ISO first day of week
        self.calendar = cal
    }

    /// Returns the Monday 00:00:00 of the week containing the given date
    public func startOfWeek(for date: Date) -> Date {
        // Use calendar's weekOfYear / yearForWeekOfYear components to lock Monday
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        comps.weekday = 2 // Monday
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        if let monday = calendar.date(from: comps) {
            return calendar.startOfDay(for: monday)
        }
        // Fallback: search backwards for weekday 2
        var current = calendar.startOfDay(for: date)
        while calendar.component(.weekday, from: current) != 2 {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = prev
        }
        return current
    }

    /// Returns the Sunday 23:59:59 of the week containing the given date
    public func endOfWeek(for date: Date) -> Date {
        let monday = startOfWeek(for: date)
        if let sunday = calendar.date(byAdding: .day, value: 6, to: monday),
           let endOfSunday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: sunday) {
            return endOfSunday
        }
        return calendar.date(byAdding: .day, value: 7, to: monday) ?? date
    }

    /// Returns the exact 7 calendar days (Monday through Sunday) for the week
    public func daysOfWeek(for date: Date) -> [Date] {
        let monday = startOfWeek(for: date)
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)
        }
    }

    /// Advances or rewinds the week by a given count
    public func addingWeeks(_ count: Int, to date: Date) -> Date {
        calendar.date(byAdding: .weekOfYear, value: count, to: date) ?? date
    }

    /// Normalizes a date to 00:00:00 in local calendar
    public func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Checks if two dates fall on the exact same calendar day
    public func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    /// Returns true if the date is today
    public func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    /// Formats a week range header string, e.g. "09 Th11 - 15 Th11, 2026"
    public func formatWeekRange(for date: Date) -> String {
        let monday = startOfWeek(for: date)
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday

        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "vi_VN")
        dayFormatter.dateFormat = "dd/MM"

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"

        let mondayStr = dayFormatter.string(from: monday)
        let sundayStr = dayFormatter.string(from: sunday)
        let yearStr = yearFormatter.string(from: sunday)

        return "\(mondayStr) – \(sundayStr), \(yearStr)"
    }

    /// Formats weekday abbreviation (T2, T3, T4, T5, T6, T7, CN)
    public func vietnameseWeekdayShort(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 2: return "T2"
        case 3: return "T3"
        case 4: return "T4"
        case 5: return "T5"
        case 6: return "T6"
        case 7: return "T7"
        case 1: return "CN"
        default: return ""
        }
    }

    /// Formats full Vietnamese weekday and date: "Thứ Hai, 10 tháng 11"
    public func vietnameseFullDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d 'tháng' M"
        return formatter.string(from: date).capitalized
    }
}
