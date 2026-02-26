//
//  CalendarMonthView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 26/02/2024.
//

import SwiftUI

struct CalendarMonthView<DayView: View>: View {
    typealias DayContent = (Date) -> DayView
    
    @Binding var visibleMonth: Date
    let showHeader: Bool
    let dayContent: DayContent
    
    @State private var days: [Date?] = []
    
    init(
        visibleMonth: Binding<Date>,
        showHeader: Bool = true,
        @ViewBuilder dayContent: @escaping DayContent
    ) {
        self._visibleMonth = visibleMonth
        self.showHeader = showHeader
        self.dayContent = dayContent
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if showHeader {
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
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        dayContent(date)
                            .frame(height: 36)
                    } else {
                        Text("").frame(height: 36)
                    }
                }
            }
        }
        .onAppear {
            updateDays()
        }
        .onChange(of: visibleMonth) { _ in
            updateDays()
        }
    }
    
    private func updateDays() {
        days = daysForVisibleMonth()
    }
    
    private func moveMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: visibleMonth) {
            visibleMonth = newMonth
        }
    }
    
    private func daysForVisibleMonth() -> [Date?] {
        let cal = Calendar.current
        guard let monthInterval = cal.dateInterval(of: .month, for: visibleMonth),
              let monthRange = cal.range(of: .day, in: .month, for: monthInterval.start)
        else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth)
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

#Preview {
    CalendarMonthView(visibleMonth: .constant(Date())) { date in
        Text(date, format: .dateTime.day())
    }
}
