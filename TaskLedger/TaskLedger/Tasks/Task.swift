//
//  Task.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//

import SwiftData
import Foundation

@Model
class Task: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var timestamp: Date
    var name: String
    var taskTypeRaw: String
    var taskFixedDate: Date?
    var amount: Double
    var days: [Int]
    var notes: String
    @Relationship(inverse: \Event.task)
    var events: [Event]
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
    
    init(
        timestamp: Date,
        name: String,
        taskType: TaskType = .counter,
        amount: Double = 0.0,
        days: [Int] = [],
        notes: String = "",
        events: [Event] = []) {
            self.timestamp = timestamp
            self.name = name
            self.taskTypeRaw = taskType.rawValue
            self.amount = amount
            self.days = days
            self.notes = notes
            self.events = events
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
