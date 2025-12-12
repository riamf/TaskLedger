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
    
    func fetchSummary(for date: Date) -> [EventTask: [EventMark]] {
        let searchedMonth = DaysCalculator.monthFormatter.string(from: date)
        let searchedYear = DaysCalculator.yearFormatter.string(from: date)
        do {
            let predicate = #Predicate<EventMark>() {
                $0.month == searchedMonth && $0.year == searchedYear
            }
            let events = try modelContext.fetch(FetchDescriptor<EventMark>(predicate: predicate))
            var eventsDict = [EventTask: [EventMark]]()
            events.forEach { event in
                guard let task = event.task else { return }
                eventsDict[task] = (eventsDict[task] ?? []) + [event]
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
    
    init(events: [EventMark]) {
        amountSummary = events.reduce(0.0, { $0 + $1.amount })
        counterSummary = events.filter { $0.task?.taskType == .counter }.count
        timeSummary = events.filter { $0.task?.taskType == .time }.reduce(0, { $0 + Int($1.amount) } )
    }
}
