import Foundation
import SwiftData
import SwiftUI

final class CalendarViewModel: ObservableObject {
    var tasks: [EventTask] = []
    @Published var selectedDate: Date
    
    @DInjected(\.modelContext) private var modelContext: ModelContext
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    private func fetchData() -> [EventTask] {
        do {
            let descriptor = FetchDescriptor<EventTask>(sortBy: [])
            let fetched = try modelContext.fetch(descriptor)
            return fetched
        } catch {
            return []
        }
    }
}

final class CalendarTaskSummaryViewModel: ObservableObject {
    
    let task: EventTask
    init(task: EventTask) {
        self.task = task
    }
    
    
    func sameMonthPredicate(for task: EventTask) -> Predicate<EventMark> {
        let idk = task.id
        return #Predicate<EventMark> {
            $0.task?.id == idk
        }
    }
}

