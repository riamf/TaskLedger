import Foundation
import SwiftData

final class Fetcher {
    
    @DInjected(\.modelContext) private var modelContext: ModelContext
    
    func fetchTasks(for date: Date) -> [EventTask] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let distantFuture = Date.distantFuture
        let distantPast = Date.distantPast
        
        let predicate = #Predicate<EventTask> { task in
            ((task.archivedAt ?? distantFuture) >= startOfDay) &&
            ((task.snoozedUntil ?? distantPast) <= startOfDay)
        }
        
        do {
            let tasks = try modelContext.fetch(FetchDescriptor(predicate: predicate))

            return tasks.filter { $0.occurs(on: date, calendar: calendar) }
        } catch {
            return []
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
    
    func fetchSummary(for date: Date, mode: SummaryGroupingMode = .individual) -> [EventMartSummary] {
        let searchedMonth = DaysCalculator.monthFormatter.string(from: date)
        let searchedYear = DaysCalculator.yearFormatter.string(from: date)
        do {
            let predicate = #Predicate<EventMark>() {
                $0.month == searchedMonth && $0.year == searchedYear
            }
            let events = try modelContext.fetch(FetchDescriptor<EventMark>(predicate: predicate))

            var grouped = [String: (representative: EventTask, tasksByID: [String: EventTask], events: [EventMark])]()
            for event in events {
                guard let task = event.task else { continue }

                let key: String
                switch mode {
                case .individual:
                    key = task.id
                case .templateGroup:
                    key = task.groupId
                }

                if var existing = grouped[key] {
                    existing.events.append(event)
                    existing.tasksByID[task.id] = task
                    if task.timestamp > existing.representative.timestamp {
                        existing.representative = task
                    }
                    grouped[key] = existing
                } else {
                    grouped[key] = (
                        representative: task,
                        tasksByID: [task.id: task],
                        events: [event]
                    )
                }
            }

            return grouped.map { key, group in
                EventMartSummary(
                    summaryKey: key,
                    task: group.representative,
                    tasks: Array(group.tasksByID.values),
                    events: group.events,
                    groupingMode: mode
                )
            }
            .sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
        } catch {
            return []
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

enum SummaryGroupingMode: String, CaseIterable, Identifiable {
    case individual
    case templateGroup

    var id: String { rawValue }
}

struct EventMartSummary: Identifiable {
    let summaryKey: String
    let amountSummary: Double
    let counterSummary: Int
    let timeSummary: Int
    let events: [EventMark]
    let task: EventTask
    let tasks: [EventTask]
    let groupingMode: SummaryGroupingMode

    var id: String {
        "\(groupingMode.rawValue):\(summaryKey)"
    }

    var displayName: String {
        switch groupingMode {
        case .individual:
            return task.name
        case .templateGroup:
            let names = orderedUniqueTaskNames
            guard !names.isEmpty else { return task.name }
            return names.joined(separator: " + ")
        }
    }

    private var orderedUniqueTaskNames: [String] {
        var seen = Set<String>()
        return tasks
            .sorted {
                if $0.timestamp != $1.timestamp {
                    return $0.timestamp < $1.timestamp
                }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            .compactMap { task in
                guard seen.insert(task.name).inserted else { return nil }
                return task.name
            }
    }

    init(
        summaryKey: String,
        task: EventTask,
        tasks: [EventTask],
        events: [EventMark],
        groupingMode: SummaryGroupingMode
    ) {
        self.summaryKey = summaryKey
        self.task = task
        self.tasks = tasks
        self.events = events
        self.groupingMode = groupingMode
        amountSummary = events.reduce(0.0, { $0 + $1.amount })
        counterSummary = events.filter { $0.task?.taskType == .counter }.count
        timeSummary = events.filter { $0.task?.taskType == .time }.reduce(0, { $0 + Int($1.amount) } )
    }

    func replacingEvents(_ updatedEvents: [EventMark]) -> EventMartSummary {
        EventMartSummary(
            summaryKey: summaryKey,
            task: task,
            tasks: tasks,
            events: updatedEvents,
            groupingMode: groupingMode
        )
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
