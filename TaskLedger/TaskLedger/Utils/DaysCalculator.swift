//
//  DaysCalculator.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 26/10/2025.
//
import Foundation

fileprivate func dateFormatterFactory(_ format: String) -> DateFormatter {
    let df = DateFormatter()
    df.dateFormat = format
    return df
}

struct DaysCalculator {
    static let dayNameFormatter = dateFormatterFactory("EEEE")
    static let monthFormatter = dateFormatterFactory("MM")
    static let dayNumberFormatter = dateFormatterFactory("dd")
    static let yearFormatter = dateFormatterFactory("yyyy")
    static let hourFormatter = dateFormatterFactory("HH")
    static let minuteFormatter = dateFormatterFactory("mm")
    static let compDateFormatter = dateFormatterFactory("yyyy-MM-dd")
    
    static func todayNumberInWeek() -> Int {
        return dayNumberInWeekFrom(Date())
    }
    
    static func dayName(from number: Int) -> String {
        guard number < Calendar.current.shortWeekdaySymbols.count, number >= 0 else {
            return ""
        }
        return Calendar.current.shortWeekdaySymbols[number]
    }
    
    static func dayNumberInWeekFrom(_ date: Date) -> Int {
        let dayName = dayNameFormatter.string(from: date)
        return Calendar.current.weekdaySymbols.firstIndex(of: dayName) ?? -1
    }
    
    static func dayNumberForName(_ name: String) -> Int? {
        return Calendar.current.weekdaySymbols.firstIndex(of: name)
    }
}

