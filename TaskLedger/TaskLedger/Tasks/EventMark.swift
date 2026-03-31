//
//  Event.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 04/10/2025.
//
import SwiftData
import SwiftUI

@Model
class EventMark {
  var id: String = UUID().uuidString
  var amount: Double = 0.0
  
  var date: Date = Date()
  var year: String = ""
  var month: String = ""
  var day: String = ""
  var hour: String = ""
  var minute: String = ""

  @Relationship(inverse: \EventTask.events)
  var task: EventTask?
  
  init(date: Date, amount: Double = 0.0, task: EventTask) {
    self.date = date
    self.amount = amount
    self.task = task
    self.minute = date.minute
    self.hour = date.hour
    self.day = date.day
    self.month = date.month
    self.year = date.year
  }
}
