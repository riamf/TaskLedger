import SwiftUI
import Charts

struct SummaryDetailsView: View {
    private let eventSummary: EventMartSummary

    init(eventSummary: EventMartSummary) {
        self.eventSummary = eventSummary
    }

    private struct PointData: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let color: Color
    }

    // Aggregate events into daily counts and assign a deterministic color per point
    private var dailyCounts: [PointData] {
        let grouped = Dictionary(grouping: eventSummary.events) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.map { key, values in
            // Deterministic hue based on the day's timestamp to avoid color flicker
            let seconds = Int(key.timeIntervalSince1970)
            let hueComponent = Double((seconds & 0xFF)) / 255.0 // 0..1
            let color = Color(hue: hueComponent, saturation: 0.6, brightness: 0.85)
            return PointData(date: key, count: values.count, color: color)
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        // Use a VStack with the chart on top and a vertical list of dates below.
        VStack(alignment: .leading, spacing: 12) {
            // Chart with bordered background
            Chart(dailyCounts) { point in
                LineMark(
                    x: .value("Day", point.date),
                    y: .value("Count", point.count)
                )
                PointMark(
                    x: .value("Day", point.date),
                    y: .value("Count", point.count)
                )
                .foregroundStyle(point.color)
                .symbolSize(60)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 160)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    .background(Color(UIColor.systemBackground).cornerRadius(10))
            )

            // Dates list below the chart (vertical rows)
            if dailyCounts.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                CustomToolbarView(task: eventSummary.task)
            }
        }
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
