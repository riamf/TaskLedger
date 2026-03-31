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
    static let monthYearFormatter = dateFormatterFactory("LLLL yyyy")
    
    @DInjected(\.calendar) private static var calendar: Calendar
    
    static func todayNumberInWeek() -> Int {
        return dayNumberInWeekFrom(Date())
    }
    
    static func dayName(from number: Int) -> String {
        guard number < calendar.shortWeekdaySymbols.count, number >= 0 else {
            return ""
        }
        return calendar.shortWeekdaySymbols[number]
    }
    
    static func dayNumberInWeekFrom(_ date: Date) -> Int {
        let dayName = dayNameFormatter.string(from: date)
        return calendar.weekdaySymbols.firstIndex(of: dayName) ?? -1
    }
    
    static func dayNumberForName(_ name: String) -> Int? {
        return calendar.weekdaySymbols.firstIndex(of: name)
    }
    
    static func equalDatesDayMonthYear(_ date1: Date, date2: Date) -> Bool {
        return compDateFormatter.string(from: date1) == compDateFormatter.string(from: date2)
    }
    
    static func dateAtStartOfMonth(from date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}
