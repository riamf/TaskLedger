//
//  HomeCalendarView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 30/09/2025.
//

import SwiftUI

struct HomeCalendarView: View {
    private let calendar = Calendar(identifier: .gregorian)
    private let daysInWeek = 7

    // Short weekday names starting from Monday
    private var weekdaySymbols: [String] {
        var symbols = calendar.shortStandaloneWeekdaySymbols
        let sunday = symbols.removeFirst()
        symbols.append(sunday)
        return symbols
    }

    private var days: [Date] {
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        var days: [Date] = []
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmpty = (firstWeekday + 5) % 7
        return Array(repeating: Date.distantPast, count: leadingEmpty) + days
    }

    var body: some View {
        let today = Date()
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        return VStack(spacing: 16) {
            Text(monthFormatter.string(from: today))
                .font(.title2)
                .bold()
            Text("Today: \(dayFormatter.string(from: today))")
                .font(.headline)
                .padding(.bottom, 8)
            // Day names row
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                        Color.clear.frame(height: 40)
                    } else {
                        let isToday = calendar.isDate(date, inSameDayAs: today)
                        Text(dayFormatter.string(from: date))
                            .frame(width: 40, height: 40)
                            .background(isToday ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(isToday ? .white : .primary)
                            .clipShape(Circle())
                            .border(.red, width: 2.0)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 32)
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
}
