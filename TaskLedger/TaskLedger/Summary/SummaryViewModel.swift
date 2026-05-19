import Foundation
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date()) {
        didSet {
            currentMonthDateString = DaysCalculator.monthYearFormatter.string(from: currentMonthDate).capitalized
        }
    }
    @Published var currentMonthDateString: String = DaysCalculator.monthYearFormatter.string(from: Date()).capitalized
    @Published var groupingMode: SummaryGroupingMode = .individual {
        didSet {
            fetchData()
        }
    }
    @Published private(set) var isBrandNewUser = false
    @Published private(set) var showsGroupingModePicker = false
    @Published private(set) var summaries: [EventMartSummary] = []
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init() {}

    func fetchData() {
        isBrandNewUser = !fetcher.hasRecordedEvents()
        let individualSummaries = fetcher.fetchSummary(for: currentMonthDate, mode: .individual)
        let groupedSummaries = fetcher.fetchSummary(for: currentMonthDate, mode: .templateGroup)
        let hasCollapsedTemplateGroups = groupedSummaries.contains { $0.tasks.count > 1 }

        showsGroupingModePicker = hasCollapsedTemplateGroups

        if !hasCollapsedTemplateGroups, groupingMode == .templateGroup {
            groupingMode = .individual
            return
        }

        summaries = groupingMode == .templateGroup ? groupedSummaries : individualSummaries
    }

    var showsSampleSummary: Bool {
        isBrandNewUser && summaries.isEmpty
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
