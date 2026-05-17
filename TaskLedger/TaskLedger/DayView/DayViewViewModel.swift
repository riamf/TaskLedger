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
    @DInjected(\.analytics) private var analytics: AnalyticsService
    
    init(currentDate: Date, tasks: [EventTask] = []) {
        self.tasks = tasks
        self.currentDate = currentDate
        dayString = dayDateFormatter.string(from: currentDate)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(currentDate)
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
        analytics.logDayNavigation(method: .arrow, direction: .next)
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }
    
    func previousDate() {
        analytics.logDayNavigation(method: .arrow, direction: .previous)
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
    }

    func selectDateFromCalendar(_ date: Date) {
        let startOfCurrent = Calendar.current.startOfDay(for: currentDate)
        let startOfNew = Calendar.current.startOfDay(for: date)

        guard startOfCurrent != startOfNew else {
            currentDate = date
            return
        }

        analytics.logDayNavigation(
            method: .calendarPicker,
            direction: startOfNew > startOfCurrent ? .next : .previous
        )
        currentDate = date
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
            let wasDone = task.isCheck(currentDate)

            if wasDone, let event = task.removeEventForDate(currentDate) {
                modelContext.delete(event)
            } else {
                let eventMerk = EventMark(date: currentDate,
                                          amount: task.amount,
                                          task: task)
                modelContext.insert(eventMerk)
            }
            try modelContext.save()
            fetchTasks()
            analytics.logTaskToggle(task: task, isNowDone: !wasDone)
            if !wasDone {
                analytics.logFinancialCompletion(for: task)
            }
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
            analytics.logTaskSnoozed(days: days)
        } catch {
            errorMessage = String(localized: "error_snooze_task")
        }
    }
    
    func archiveTask(_ task: EventTask, effectiveFrom visibleDate: Date) {
        task.archivedAt = Calendar.current.startOfDay(for: visibleDate).addingTimeInterval(-1)
        if task.notificationEnabled {
            notifications.removeNotification(for: task.id)
        }
        do {
            try modelContext.save()
            fetchTasks()
            analytics.logTaskArchived(taskType: task.taskType)
            analytics.updateTotalTasksCount(fetcher.fetchActiveTaskCount())
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
            analytics.logTaskFullyDeleted(taskType: task.taskType)
            analytics.updateTotalTasksCount(fetcher.fetchActiveTaskCount())
        } catch {
            errorMessage = String(localized: "error_delete_task")
        }
    }
}
