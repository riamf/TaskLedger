import Foundation
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date()) {
        didSet {
            currentMonthDateString = DaysCalculator.monthYearFormatter.string(from: currentMonthDate).capitalized
        }
    }
    @Published var currentMonthDateString: String = DaysCalculator.monthYearFormatter.string(from: Date()).capitalized
    @Published private(set) var isBrandNewUser = false
    @Published private(set) var eventsDict: [EventTask: EventMartSummary] = [:]
    @Published private(set) var sortedTasks: [EventTask] = []
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init() {}

    func fetchData() {
        isBrandNewUser = !fetcher.hasRecordedEvents()
        eventsDict = fetcher.fetchSummary(for: currentMonthDate)
        sortedTasks = eventsDict.keys.sorted { $0.name < $1.name }
    }

    var showsSampleSummary: Bool {
        isBrandNewUser && eventsDict.isEmpty
    }
    
    func previousMonth() {
        currentMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) ?? currentMonthDate
        fetchData()
    }
    
    func nextMonth() {
        currentMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) ?? currentMonthDate
        fetchData()
    }
}
