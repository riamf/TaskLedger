//
//  Event.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 04/10/2025.
//
import SwiftData
import SwiftUI

@Model
class Event {
    @Attribute(.unique) var id: String = UUID().uuidString
    var date: Date
    var amount: Double
    var task: Task
    
    init(date: Date, amount: Double = 0.0, task: Task) {
        self.date = date
        self.amount = amount
        self.task = task
    }
}
