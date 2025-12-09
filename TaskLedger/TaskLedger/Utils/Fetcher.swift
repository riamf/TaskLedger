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
        
    }
}
