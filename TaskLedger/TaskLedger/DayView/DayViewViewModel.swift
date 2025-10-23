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
    @Query var tasks: [EventTask]
    var currentDate: Date {
        didSet {
            dayString = dayDateFormatter.string(from: currentDate)
        }
    }
    @Published var dayString: String
    
    init(currentDate: Date) {
        self.currentDate = currentDate
        dayString = dayDateFormatter.string(from: currentDate)
    }
    
    let dayDateFormatter: DateFormatter = {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d MMMM yyyy"
        return dayFormatter
    }()
}
