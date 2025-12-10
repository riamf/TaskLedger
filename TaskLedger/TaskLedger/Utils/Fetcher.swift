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
    
    func fetchSummary(for date: Date) {
        let searchedMonth = DaysCalculator.monthFormatter.string(from: date)
        let searchedYear = DaysCalculator.yearFormatter.string(from: date)
        do {
            let predicate = #Predicate<EventMark>() {
                $0.month == searchedMonth && $0.year == searchedYear
            }
            let events = try modelContext.fetch(FetchDescriptor<EventMark>(predicate: predicate))
            let uniqueTasks = Set(events.map { $0.task })
            
            
        } catch {
            return []
        }
    }
}
