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
    @Published var currentDate: Date {
        didSet {
            dayString = dayDateFormatter.string(from: currentDate)
            fetchTasks()
        }
    }
    @Published var dayString: String
    @Published var showTasksList: Bool = false
    @Published var showCalendar: Bool = false
    @Published var showAddTaskView: Bool = false
    @Published var tasks: [EventTask] = []
    
    @DInjected(\.fetcher) private var fetcher: Fetcher
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
        self.tasks = fetcher.fetchTasks(for: currentDate)
    }
    
    func nextDate() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }
    
    func previousDate() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
    }
    
    func deleteTask(at indexSet: IndexSet) {
        do {
            for index in indexSet {
                let task = tasks.remove(at: index)
                modelContext.delete(task)
            }
            try modelContext.save()
            fetchTasks()
        } catch {
            print("Error deleting task: \(error.localizedDescription)")
        }
    }
    
    func markTask(_ task: EventTask) {
        do {
            if task.isCheck(currentDate), let event = task.removeEventForDate(currentDate) {
                modelContext.delete(event)
            } else {
                let eventMerk = EventMark(date: currentDate,
                                          amount: task.amount,
                                          task: task)
                modelContext.insert(eventMerk)
            }
            try modelContext.save()
        } catch {
            
        }
    
    }
    
}
