import SwiftUI

struct SummaryDetailsView: View {
    @StateObject private var viewModel: SummaryDetailsViewModel
    @DInjected(\.analytics) private var analytics: AnalyticsService

    init(eventSummary: EventMartSummary, visibleMonth: Date = Date()) {
        _viewModel = StateObject(wrappedValue: SummaryDetailsViewModel(
            eventSummary: eventSummary,
            visibleMonth: visibleMonth
        ))
    }

    private struct DayParams: Identifiable {
        let id = UUID()
        let date: Date
    }

    @State private var selectedDayParams: DayParams?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                
                // Calendar with bordered background
                CalendarMonthView(visibleMonth: $viewModel.visibleMonth) { date in
                    let data = viewModel.dailyCountsDict[Calendar.current.startOfDay(for: date)]
                    
                    // Day Cell
                    Button {
                        analytics.logHeatmapDayTap(hasActivity: data != nil)
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

                if viewModel.dailyCounts.isEmpty {
                    Text("no_data_available")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.dailyCounts) { point in
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
                CustomToolbarView(task: viewModel.eventSummary.task)
            }
        }
        .onChange(of: viewModel.visibleMonth) { _, _ in
            viewModel.onVisibleMonthChanged()
        }
        .sheet(item: $selectedDayParams, onDismiss: {
            viewModel.refreshData()
        }) { params in
             DayView(currentDate: params.date, showAddButton: false)
        }
    }
    
    private var summaryFooter: some View {
        HStack {
            Text("total_label")
                .font(.headline)
            Spacer()
            
            switch viewModel.eventSummary.task.taskType {
            case .counter:
                Text("\(viewModel.filteredEvents.count)")
                    .font(.headline)
            case .cost, .income:
                let amount = viewModel.filteredEvents.reduce(0.0) { $0 + $1.amount }
                Text(MoneyFormatter.formatter.string(from: NSNumber(value: amount)) ?? "")
                    .font(.headline)
            case .time:
                let seconds = viewModel.filteredEvents.reduce(0) { $0 + Int($1.amount) }
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
