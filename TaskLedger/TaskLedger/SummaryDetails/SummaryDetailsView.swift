import SwiftUI

struct SummaryDetailsView: View {
    private let eventSummary: EventMartSummary
    @State private var visibleMonth: Date = Date()

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
    
    // Quick lookup to map specific dates to data for the calendar grid
    private var dailyCountsDict: [Date: PointData] {
        Dictionary(uniqueKeysWithValues: dailyCounts.map { ($0.date, $0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Calendar with bordered background
            VStack(spacing: 12) {
                // Calendar Header: Prev | Month Name | Next
                HStack {
                    Button(action: { moveMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                    Spacer()
                    Text(visibleMonth, format: .dateTime.month(.wide).year())
                        .font(.headline)
                    Spacer()
                    Button(action: { moveMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                }
                
                // Calendar Grid
                let days = daysForVisibleMonth()
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    // Weekday Labels
                    ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    // Days
                    ForEach(days.indices, id: \.self) { index in
                        if let date = days[index] {
                            let data = dailyCountsDict[date]
                            
                            // Day Cell
                            ZStack {
                                if let color = data?.color {
                                    Circle()
                                        .fill(color)
                                }
                                
                                Text(date, format: .dateTime.day())
                                    .font(.system(size: 14, weight: data != nil ? .bold : .regular))
                                    .foregroundColor(data != nil ? .white : .primary)
                            }
                            .frame(height: 36)
                        } else {
                            // Empty cell helper
                            Text("").frame(height: 36)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    .background(Color(UIColor.systemBackground).cornerRadius(10))
            )
            .padding(.horizontal)

            // Dates list below the calendar (vertical rows)
            if dailyCounts.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
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
                .frame(maxHeight: .infinity) // Allow list to fill remaining space
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.vertical) // Top/bottom padding for the whole view
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                CustomToolbarView(task: eventSummary.task)
            }
        }
    }
    
    // MARK: - Calendar Helpers
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: visibleMonth) {
            visibleMonth = newDate
        }
    }
    
    // Generate dates for the grid (including nil for offset days)
    private func daysForVisibleMonth() -> [Date?] {
        let cal = Calendar.current
        guard let monthInterval = cal.dateInterval(of: .month, for: visibleMonth),
              let monthRange = cal.range(of: .day, in: .month, for: monthInterval.start)
        else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth)
        // Calculate offset (assuming Sunday is 1, so offset is weekday-1)
        let offset = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for dayOffset in 0..<monthRange.count {
            if let date = cal.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
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
