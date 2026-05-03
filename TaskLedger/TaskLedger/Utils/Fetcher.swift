import Foundation
import SwiftData

final class Fetcher {
    
    @DInjected(\.modelContext) private var modelContext: ModelContext
    
    func fetchTasks(for date: Date) -> [EventTask] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let components = Calendar.current.dateComponents([.weekday, .day, .month], from: date)
        let weekdayIndex = components.weekday ?? 1
        let day = components.day ?? 1
        let month = components.month ?? 1
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
                // Repeating tasks should not appear on days before they were created
                if task.taskFixedDate == nil {
                    let createdDay = Calendar.current.startOfDay(for: task.timestamp)
                    guard startOfDay >= createdDay else { return false }
                }
                
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
                
                if !task.days.isEmpty, let weekday = Weekdays(rawValue: legacyDayNumber) {
                    return task.weekdays.contains(weekday)
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
    
    /// Returns unique tasks grouped by name + type, sorted by most recently created.
    func fetchUniqueTaskTemplates() -> [EventTask] {
        do {
            let tasks = try modelContext.fetch(FetchDescriptor<EventTask>())
            
            var seen = Set<String>()
            var unique = [EventTask]()
            
            // Sort by newest first so we keep the most recent instance
            let sorted = tasks.sorted { $0.timestamp > $1.timestamp }
            for task in sorted {
                let key = "\(task.name.lowercased().trimmingCharacters(in: .whitespaces))|\(task.taskType.rawValue)"
                if seen.insert(key).inserted {
                    unique.append(task)
                }
            }
            return unique
        } catch {
            return []
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
            
            // First pass: find which groupIds have multiple distinct tasks (true template groups)
            var taskIdsByGroupId = [String: Set<String>]()
            for event in events {
                guard let task = event.task else { continue }
                taskIdsByGroupId[task.groupId, default: []].insert(task.id)
            }
            
            // Second pass: group events. Use groupId only when it links multiple tasks;
            // otherwise fall back to task.id so unrelated tasks stay separate.
            var grouped = [String: (representative: EventTask, events: [EventMark])]()
            for event in events {
                guard let task = event.task else { continue }
                let isTemplateGroup = (taskIdsByGroupId[task.groupId]?.count ?? 0) > 1
                let key = isTemplateGroup ? task.groupId : task.id
                
                if var existing = grouped[key] {
                    existing.events.append(event)
                    if task.timestamp > existing.representative.timestamp {
                        existing.representative = task
                    }
                    grouped[key] = existing
                } else {
                    grouped[key] = (representative: task, events: [event])
                }
            }
            
            var eventsDict = [EventTask: EventMartSummary]()
            for (_, group) in grouped {
                eventsDict[group.representative] = EventMartSummary(task: group.representative, events: group.events)
            }
            
            return eventsDict
        } catch {
            return [:]
        }
    }

    func hasRecordedEvents() -> Bool {
        do {
            var descriptor = FetchDescriptor<EventMark>()
            descriptor.fetchLimit = 1
            return try !modelContext.fetch(descriptor).isEmpty
        } catch {
            return false
        }
    }

    func fetchActiveTaskCount() -> Int {
        do {
            let predicate = #Predicate<EventTask> { task in
                task.archivedAt == nil
            }
            return try modelContext.fetch(FetchDescriptor<EventTask>(predicate: predicate)).count
        } catch {
            return 0
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
