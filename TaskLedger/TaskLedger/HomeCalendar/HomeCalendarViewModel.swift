//
//  HomeCalendarViewMode.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//
import Foundation
import SwiftData
import SwiftUI

final class HomeCalendarViewModel: ObservableObject {
  @Query var tasks: [EventTask]
  
  func sameMonthPredicate(for task: EventTask) -> Predicate<EventMark> {
    let idk = task.id
    return #Predicate<EventMark> {
      $0.task?.id == idk
    }
  }
}

