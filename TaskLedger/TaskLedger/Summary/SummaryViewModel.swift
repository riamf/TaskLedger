import Foundation
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date()) {
        didSet {
            currentMonthDateString = DaysCalculator.monthYearFormatter.string(from: currentMonthDate)
            
        }
    }
    @Published var currentMonthDateString: String = DaysCalculator.monthYearFormatter.string(from: Date())
    @Published var eventsDict: [EventTask: EventMartSummary] = [:]
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init() {}

    func fetchData() {
        eventsDict = fetcher.fetchSummary(for: currentMonthDate)
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
