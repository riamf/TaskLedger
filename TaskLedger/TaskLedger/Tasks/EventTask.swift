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
    var taskTypeRaw: String
    var taskFixedDate: Date?
    var amount: Double
    var days: [Int]
    var notes: String
    @Relationship()
    var events: [EventMark]
    var taskType: TaskType {
        get { TaskType(rawValue: taskTypeRaw) ?? .counter }
        set { taskTypeRaw = newValue.rawValue }
    }
    
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
        events: [EventMark] = []) {
            self.timestamp = timestamp
            self.name = name
            self.taskTypeRaw = taskType.rawValue
            self.amount = amount
            self.days = days
            self.notes = notes
            self.events = events
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
    func addTodayEvent(amount: Double = 0.0) -> EventMark {
        let event = EventMark(date: Date(), amount: amount, task: self)
        events.append(event)
        return event
    }
}

enum TaskType: String, CaseIterable {
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
