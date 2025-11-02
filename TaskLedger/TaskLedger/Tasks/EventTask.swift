//
//  Task.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//

import SwiftData
import Foundation

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
    @Relationship()
    var events: [EventMark]
    var taskType: TaskType
    
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
    
    init(
        timestamp: Date,
        name: String,
        taskType: TaskType = .counter,
        amount: Double = 0.0,
        days: [Int] = [],
        notes: String = "",
        repeatingPattern: RepeatingPattern? = nil,
        events: [EventMark] = [],
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.timestamp = timestamp
        self.name = name
        self.taskType = taskType
        self.amount = amount
        self.days = days
        self.notes = notes
        self.events = events
        self.repeatingPattern = repeatingPattern
    }
    
    @discardableResult
    func removeTodayEvent() -> EventMark? {
        let today = DaysCalculator.compDateFormatter.string(from: Date())
        let toReturn = todayEvent
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
}

enum Weekdays: Int, Codable, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
}

enum RepeatingPattern: Codable {
    case daily(weekdays: [Weekdays])
    case monthly(day: Int)
    case yearly(day: Int, month: Int)
}

enum TaskType: String, CaseIterable, Codable {
    case counter
    case cost
    case income
    case time
    
    var imageName: String {
        switch self {
        case .counter: return "plus.minus.capsule"
        case .cost: return "dollarsign.bank.building"
        case .income: return "singaporedollarsign.bank.building"
        case .time: return "clock.badge"
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
        case .time: return "timeer"
        }
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


