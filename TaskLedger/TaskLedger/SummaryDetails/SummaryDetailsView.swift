import SwiftUI

struct SummaryDetailsView: View {
    @State private var eventSummary: EventMartSummary
    @State private var visibleMonth: Date
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init(eventSummary: EventMartSummary, visibleMonth: Date = Date()) {
        self.eventSummary = eventSummary
        self.visibleMonth = visibleMonth
    }

    private struct PointData: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let color: Color
    }

    private struct DayParams: Identifiable {
        let id = UUID()
        let date: Date
    }

    @State private var selectedDayParams: DayParams?

    private var filteredEvents: [EventMark] {
        let calendar = Calendar.current
        return eventSummary.events.filter { event in
            calendar.isDate(event.date, equalTo: visibleMonth, toGranularity: .month)
        }
    }

    private var dailyCounts: [PointData] {
        let grouped = Dictionary(grouping: filteredEvents) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.map { key, values in
            return PointData(date: key, count: values.count, color: eventSummary.task.taskType.color)
        }
        .sorted { $0.date < $1.date }
    }
    
    private var dailyCountsDict: [Date: PointData] {
        Dictionary(uniqueKeysWithValues: dailyCounts.map { ($0.date, $0) })
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                
                // Calendar with bordered background
                CalendarMonthView(visibleMonth: $visibleMonth) { date in
                    let data = dailyCountsDict[Calendar.current.startOfDay(for: date)]
                    
                    // Day Cell
                    Button {
                        selectedDayParams = DayParams(date: date)
                    } label: {
                        ZStack {
                            if let color = data?.color {
                                Circle()
                                    .fill(color)
                            }
                            
                            Text(date, format: .dateTime.day())
                                .font(.system(size: 14, weight: data != nil ? .bold : .regular))
                                .foregroundColor(data != nil ? .white : .primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        .background(Color(UIColor.systemBackground).cornerRadius(10))
                )
                .padding(.horizontal)

                if dailyCounts.isEmpty {
                    Text("No data available")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(dailyCounts) { point in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(point.color)
                                        .frame(width: 12, height: 12)

                                    Text(point.date, format: .dateTime.month().day())
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Text("\(point.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.vertical)

            summaryFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                CustomToolbarView(task: eventSummary.task)
            }
        }
        .onChange(of: visibleMonth) { newDate in
            refreshData(for: newDate)
        }
        .sheet(item: $selectedDayParams, onDismiss: {
            refreshData()
        }) { params in
             DayView(viewModel: .init(currentDate: params.date), showAddButton: false)
        }
    }
    
    private var summaryFooter: some View {
        HStack {
            Text("Total")
                .font(.headline)
            Spacer()
            
            let currentEvents = filteredEvents
            
            switch eventSummary.task.taskType {
            case .counter:
                let count = currentEvents.count
                Text("\(count)")
                    .font(.headline)
            case .cost, .income:
                let amount = currentEvents.reduce(0.0) { $0 + $1.amount }
                Text(MoneyFormatter.formatter.string(from: NSNumber(value: amount)) ?? "")
                    .font(.headline)
            case .time:
                let seconds = currentEvents.reduce(0) { $0 + Int($1.amount) }
                let duration = Duration.seconds(seconds)
                Text(duration.formatted(.time(pattern: .hourMinuteSecond)))
                    .font(.headline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func refreshData(for date: Date? = nil) {
        let dateToFetch = date ?? visibleMonth
        let newSummary = fetcher.fetchSummary(for: dateToFetch)
        eventSummary = newSummary[eventSummary.task] ?? eventSummary
    }

}


struct CustomToolbarView: View {
    let task: EventTask
    var body: some View {
        HStack {
            TaskTypeCircleIcon(task: task)
            Text(task.name)
        }
    }
}
