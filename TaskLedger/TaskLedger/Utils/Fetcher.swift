import Foundation
import SwiftData

final class Fetcher {
    
    @DInjected(\.modelContext) private var modelContext: ModelContext
    
    func fetchTasks(for date: Date) -> [EventTask] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let legacyDayNumber = DaysCalculator.dayNumberInWeekFrom(startOfDay)

        let distantFuture = Date.distantFuture
        let distantPast = Date.distantPast
        
        let predicate = #Predicate<EventTask> { task in
            ((task.archivedAt ?? distantFuture) >= startOfDay) &&
            ((task.snoozedUntil ?? distantPast) <= startOfDay)
        }
        
        do {
            let tasks = try modelContext.fetch(FetchDescriptor(predicate: predicate))
            
            return tasks.filter { task in
                if let pattern = task.repeatingPattern {
                    switch pattern {
                    case .daily(let weekdays):
                        if let currentWeekday = self.weekdayFromCalendar(weekdayIndex) {
                            return weekdays.contains(currentWeekday)
                        }
                        return false
                    case .monthly(let dayOfMonth):
                        return day == dayOfMonth
                    case .yearly(let dayOfMonth, let monthOfYear):
                        return day == dayOfMonth && month == monthOfYear
                    }
                }
                
                if let fixedDate = task.taskFixedDate {
                    return Calendar.current.isDate(fixedDate, inSameDayAs: date)
                }
                
                if !task.days.isEmpty {
                    return task.days.contains(legacyDayNumber)
                }
                
                return false
            }
        } catch {
            return []
        }
    }
    
    private func weekdayFromCalendar(_ component: Int) -> Weekdays? {
        switch component {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
    
    func fetchSummary(for date: Date) -> [EventTask: EventMartSummary] {
        let searchedMonth = DaysCalculator.monthFormatter.string(from: date)
        let searchedYear = DaysCalculator.yearFormatter.string(from: date)
        do {
            let predicate = #Predicate<EventMark>() {
                $0.month == searchedMonth && $0.year == searchedYear
            }
            let events = try modelContext.fetch(FetchDescriptor<EventMark>(predicate: predicate))
            
            // Group events by their associated task (skip events without a task)
            var grouped = [EventTask: [EventMark]]()
            for event in events {
                guard let task = event.task else { continue }
                grouped[task, default: []].append(event)
            }
            
            // Map grouped events into summaries
            var eventsDict = [EventTask: EventMartSummary]()
            for (task, eventsForTask) in grouped {
                eventsDict[task] = EventMartSummary(task: task, events: eventsForTask)
            }
            
            return eventsDict
        } catch {
            return [:]
        }
    }
}

struct EventMartSummary {
    let amountSummary: Double
    let counterSummary: Int
    let timeSummary: Int
    let events: [EventMark]
    let task: EventTask
    
    init(task: EventTask, events: [EventMark]) {
        self.task = task
        self.events = events
        amountSummary = events.reduce(0.0, { $0 + $1.amount })
        counterSummary = events.filter { $0.task?.taskType == .counter }.count
        timeSummary = events.filter { $0.task?.taskType == .time }.reduce(0, { $0 + Int($1.amount) } )
    }
}

#if DEBUG
@MainActor
let previewContainer: ModelContainer = {
    do {
        // Create a schema and a configuration that is stored only in memory
        let schema = Schema([EventTask.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        
        // Add sample data to the container's main context
        let sampleTask1 = EventTask.example() // Assuming this returns a new instance
        let sampleTask2 = EventTask.example()
        
        container.mainContext.insert(sampleTask1)
        container.mainContext.insert(sampleTask2)
        
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()
#endif // DEBUG
