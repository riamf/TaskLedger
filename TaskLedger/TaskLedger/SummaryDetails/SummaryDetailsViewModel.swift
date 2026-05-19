import SwiftUI

@MainActor
class SummaryDetailsViewModel: ObservableObject {

    struct PointData: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let color: Color
    }

    @DInjected(\.fetcher) private var fetcher: Fetcher

    @Published private(set) var eventSummary: EventMartSummary
    @Published var visibleMonth: Date

    @Published private(set) var filteredEvents: [EventMark] = []
    @Published private(set) var dailyCounts: [PointData] = []
    @Published private(set) var dailyCountsDict: [Date: PointData] = [:]
    @Published private(set) var scheduledDays: Set<Date> = []

    private let trackedSummaryKey: String
    private let trackedGroupingMode: SummaryGroupingMode

    init(eventSummary: EventMartSummary, visibleMonth: Date = Date()) {
        self.eventSummary = eventSummary
        self.visibleMonth = visibleMonth
        trackedSummaryKey = eventSummary.summaryKey
        trackedGroupingMode = eventSummary.groupingMode
        recomputeDerived()
    }

    func onVisibleMonthChanged() {
        refreshData(for: visibleMonth)
    }

    func refreshData(for date: Date? = nil) {
        let dateToFetch = date ?? visibleMonth
        let newSummaries = fetcher.fetchSummary(for: dateToFetch, mode: trackedGroupingMode)
        eventSummary = matchingSummary(in: newSummaries)
            ?? eventSummary.replacingEvents([])
        recomputeDerived()
    }

    private func matchingSummary(in summaries: [EventMartSummary]) -> EventMartSummary? {
        summaries.first(where: {
            $0.groupingMode == trackedGroupingMode && $0.summaryKey == trackedSummaryKey
        })
    }

    private func recomputeDerived() {
        let calendar = Calendar.current
        let filtered = eventSummary.events.filter {
            calendar.isDate($0.date, equalTo: visibleMonth, toGranularity: .month)
        }
        filteredEvents = filtered

        let grouped = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        let counts = grouped.map { key, values in
            PointData(date: key, count: values.count, color: eventSummary.task.taskType.color)
        }.sorted { $0.date < $1.date }

        dailyCounts = counts
        dailyCountsDict = Dictionary(uniqueKeysWithValues: counts.map { ($0.date, $0) })

        scheduledDays = scheduledDaysForVisibleMonth(calendar: calendar)
    }

    private func scheduledDaysForVisibleMonth(calendar: Calendar) -> Set<Date> {
        guard let monthRange = calendar.range(of: .day, in: .month, for: visibleMonth),
              let monthStart = calendar.dateInterval(of: .month, for: visibleMonth)?.start
        else {
            return []
        }

        let today = calendar.startOfDay(for: Date())

        return Set(monthRange.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else {
                return nil
            }

            let startOfDay = calendar.startOfDay(for: date)
            guard startOfDay <= today else {
                return nil
            }
            guard eventSummary.tasks.contains(where: { $0.occurs(on: startOfDay, calendar: calendar) }) else {
                return nil
            }

            return startOfDay
        })
    }
}
