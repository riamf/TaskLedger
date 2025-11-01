//
//  DayViewViewModel.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 03/10/2025.
//
import Foundation
import SwiftUI
import SwiftData

class DayViewViewModel: ObservableObject {
  var currentDate: Date {
    didSet {
      dayString = dayDateFormatter.string(from: currentDate)
    }
  }
  @Published var dayString: String
  @Published var showTasksList: Bool = false
  @Published var showAddTaskView: Bool = false
  @Published var tasks: [EventTask] = []
  
  @DInjected(\.modelContext) private var modelContext: ModelContext
  
  init(currentDate: Date) {
    self.currentDate = currentDate
    dayString = dayDateFormatter.string(from: currentDate)
  }
  
  let dayDateFormatter: DateFormatter = {
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "d MMMM yyyy"
    return dayFormatter
  }()
  
  func fetchTasks() {
    // Placeholder for fetching tasks logic
    
    let fetchDescriptor = FetchDescriptor<EventTask>()
  }
  
  func nextDate() {
    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
  }
  
  func previousDate() {
    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
  }
  
}
