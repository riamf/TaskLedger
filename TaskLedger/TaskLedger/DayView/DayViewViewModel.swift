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
    @Published var errorMessage: String?
    
    @DInjected(\.fetcher) private var fetcher: Fetcher
    @DInjected(\.modelContext) private var modelContext: ModelContext
    @DInjected(\.notifications) private var notifications: NotificationService
    
    init(currentDate: Date, tasks: [EventTask] = []) {
        self.tasks = tasks
        self.currentDate = currentDate
        dayString = dayDateFormatter.string(from: currentDate)
    }
    
    let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
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
            errorMessage = String(localized: "error_delete_task")
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
            fetchTasks()
        } catch {
            errorMessage = String(localized: "error_mark_task")
        }
    }
    
    func snoozeTask(_ task: EventTask, days: Int) {
        let snoozeUntil = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate
        task.snoozedUntil = snoozeUntil
        
        do {
            try modelContext.save()
            fetchTasks()
        } catch {
            errorMessage = String(localized: "error_snooze_task")
        }
    }
    
    func archiveTask(_ task: EventTask) {
        task.archivedAt = Date()
        if task.notificationEnabled {
            notifications.removeNotification(for: task.id)
        }
        do {
            try modelContext.save()
            fetchTasks()
        } catch {
            errorMessage = String(localized: "error_archive_task")
        }
    }
    
    func deleteTask(_ task: EventTask) {
        if task.notificationEnabled {
            notifications.removeNotification(for: task.id)
        }
        modelContext.delete(task)
        do {
            try modelContext.save()
            fetchTasks()
        } catch {
            errorMessage = String(localized: "error_delete_task")
        }
    }
}
