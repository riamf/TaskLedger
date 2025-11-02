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
    
    @DInjected(\.fetcher) private var fetcher: Fetcher
    
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
        self.tasks = fetcher.fetchTasks(for: currentDate)
    }
    
    func nextDate() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }
    
    func previousDate() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
    }
    
}
