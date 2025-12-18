import Foundation
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date())
    @Published var eventsDict: [EventTask: EventMartSummary] = [:]
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init() {}

    func fetchData() {
        eventsDict = fetcher.fetchSummary(for: currentMonthDate)
    }
}
