//
//  Task.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class EventTask: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var timestamp: Date
    var name: String
    var taskFixedDate: Date?
    var amount: Double
    var repeatingPattern: RepeatingPattern?
    var days: [Int]
    var notes: String
    @Relationship(deleteRule: .cascade)
    var events: [EventMark]
    var taskType: TaskType
    var archivedAt: Date?
    var snoozedUntil: Date?
    
    // need to performance check this!
    var isExistingToday: Bool {
        let today = DaysCalculator.compDateFormatter.string(from: Date())
        return events.contains(where: { event in
            DaysCalculator.compDateFormatter.string(from: event.date) == today
        })
    }
    
    var todayEvent: EventMark? {
        let today = DaysCalculator.compDateFormatter.string(from: Date())
        return events.first(where: { event in
            DaysCalculator.compDateFormatter.string(from: event.date) == today
        })
    }
    
    var isTodayDone: Bool {
        todayEvent != nil
    }
    
    init(
        timestamp: Date,
        name: String,
        taskType: TaskType = .counter,
        amount: Double = 0.0,
        taskFixedDate: Date? = nil,
        repeatingPattern: RepeatingPattern? = nil,
        days: [Int] = [],
        notes: String = "",
        events: [EventMark] = [],
        archivedAt: Date? = nil,
        snoozedUntil: Date? = nil
    ) {
        self.timestamp = timestamp
        self.name = name
        self.taskType = taskType
        self.amount = amount
        self.days = days
        self.notes = notes
        self.events = events
        self.taskFixedDate = taskFixedDate
        self.repeatingPattern = repeatingPattern
        self.archivedAt = archivedAt
        self.snoozedUntil = snoozedUntil
    }
    
    func summaryShortText(_ summary: EventMartSummary?) -> String {
        if taskType == .counter, let counterSummary = summary?.counterSummary {
            return "\(counterSummary)"
        } else if taskType == .time, let timerSummary = summary?.amountSummary {
            return "\(timerSummary)"
        } else if taskType == .cost || taskType == .income, let summary = summary?.amountSummary {
            return MoneyFormatter.formatter.string(from: NSNumber(value: summary)) ?? "\(summary)"
        }
        return ""
    }
    
    func dayEvent(_ date: Date = Date()) -> EventMark? {
        let givenDate = DaysCalculator.compDateFormatter.string(from: date)
        return events.first(where: { event in
            DaysCalculator.compDateFormatter.string(from: event.date) == givenDate
        })
    }
    
    func isCheck(_ date: Date = Date()) -> Bool {
        return dayEvent(date) != nil
    }
    
    @discardableResult
    func removeEventForDate(_ date: Date) -> EventMark? {
        let today = DaysCalculator.compDateFormatter.string(from: date)
        let toReturn = dayEvent(date)
        events.removeAll(where: { event in
            DaysCalculator.compDateFormatter.string(from: event.date) == today
        })
        return toReturn
    }
    
    @discardableResult
    func addTodayEvent(amount: Double? = nil) -> EventMark {
        let event = EventMark(date: Date(), amount: amount ?? self.amount, task: self)
        events.append(event)
        return event
    }

    static func example() -> EventTask {
        EventTask(
            timestamp: Date(),
            name: "Example Task",
            taskType: .counter,
            amount: 1.0,
            repeatingPattern: .daily(weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday]),
            days: [0, 1, 2, 3, 4],
            notes: "This is an example task."
        )
    }
        
}

enum Weekdays: Int, Codable, CaseIterable, Identifiable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var id: Int { rawValue }
    var stringName: String {
        switch self {
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            case .sunday: return "Sunday"
        }
    }
}

enum RepeatingPattern: Codable, Hashable, CustomCaseIterable {
    
    case daily(weekdays: [Weekdays])
    case monthly(day: Int)
    case yearly(day: Int, month: Int)
    
    var name: String {
        switch self {
        case .daily:
            return "Daily"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    static var allNames: [String] = [
        RepeatingPattern.daily(weekdays: []).name,
        RepeatingPattern.monthly(day: 0).name,
        RepeatingPattern.yearly(day: 0, month: 0).name
    ]
    
    static var allValuesSamples: [any CustomCaseIterable] = [
        RepeatingPattern.daily(weekdays: []),
        RepeatingPattern.monthly(day: 0),
        RepeatingPattern.yearly(day: 0, month: 0)
    ]
        
}

enum TaskType: String, CaseIterable, Codable, CustomCaseIterable {
    case counter
    case cost
    case income
    case time
    
    var number: Int {
        switch self {
        case .counter: return 0
        case .cost: return 1
        case .income: return 2
        case .time: return 3
        }
    }
    var imageName: String {
        switch self {
        case .counter: return "plus.minus.capsule"
        case .cost: return "dollarsign.bank.building"
        case .income: return "singaporedollarsign.bank.building"
        case .time: return "clock.badge"
        }
    }
    
    var color: Color {
        switch self {
        case .counter: return .blue
        case .cost: return .red
        case .income: return .green
        case .time: return .yellow
        }
    }
    
    var imageNameMarked: String {
        switch self {
        case .counter: return "plus.minus.capsule.fill"
        case .cost: return "dollarsign.bank.building.fill"
        case .income: return "singaporedollarsign.bank.building.fill"
        case .time: return "clock.badge.fill"
        }
    }
    
    var taskName: String {
        switch self {
        case .counter: return "Counter"
        case .cost: return "Cost"
        case .income: return "Income"
        case .time: return "timer"
        }
    }
    
    static var allNames: [String] {
        TaskType.allCases.map { $0.taskName }
    }
    
    static var allValuesSamples: [any CustomCaseIterable] {
        TaskType.allCases
    }
    
    var name: String {
        self.taskName
    }
}

extension EventTask {
    func getMonthSummaryTasks(month: String, year: String) -> String {
        let monthEvents = events.filter {
            $0.year == year && $0.month == month
        }
        if taskType == .counter {
            let counterSum = monthEvents.count
            return "\(counterSum) times"
        }
        if taskType == .cost {
            var costSum = 0.0
            monthEvents.forEach { costSum += $0.amount }
            return "\(costSum) spend"
        }
        if taskType == .income {
            var incomSum = 0.0
            monthEvents.forEach { incomSum += $0.amount }
            return "\(incomSum) earned"
        }
        if taskType == .time {
            var amountTime = 0.0
            monthEvents.forEach { amountTime += $0.amount }
            return "\(amountTime) time spend"
        }
        return ""
    }
}
