import Foundation
import SwiftData

final class Fetcher {
    
    @DInjected(\.modelContext) private var modelContext: ModelContext
    
    func fetchTasks(for date: Date) -> [EventTask] {
        let dayNumber = DaysCalculator.dayNumberInWeekFrom(date)
        
        do {
            let tasks = try modelContext.fetch(FetchDescriptor<EventTask>())
            return tasks.filter { task in
                task.days.contains(dayNumber)
                || (
                    task.taskFixedDate != nil
                    && DaysCalculator.equalDatesDayMonthYear(task.taskFixedDate!, date2: date)
                )
            }
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
