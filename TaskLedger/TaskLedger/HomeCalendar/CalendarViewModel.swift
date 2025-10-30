//
//  HomeCalendarViewMode.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//
import Foundation
import SwiftData
import SwiftUI

final class CalendarViewModel: ObservableObject {
  var modelContext: ModelContext
  var tasks: [EventTask] = []
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    self.tasks = fetchData()
  }
  
  private func fetchData() -> [EventTask] {
    do {
      let descriptor = FetchDescriptor<EventTask>(sortBy: [])
      let fetched = try modelContext.fetch(descriptor)
      return fetched
    } catch {
      return []
    }
  }
}

final class CalendarTaskSummaryViewModel: ObservableObject {
  
  let task: EventTask
  init(task: EventTask) {
    self.task = task
  }
  
  
  func sameMonthPredicate(for task: EventTask) -> Predicate<EventMark> {
    let idk = task.id
    return #Predicate<EventMark> {
      $0.task?.id == idk
    }
  }
}

