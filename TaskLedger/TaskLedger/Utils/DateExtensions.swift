import Foundation

extension Date {
  
  var minute: String {
    DaysCalculator.minuteFormatter.string(from: self)
  }
  
  var hour: String {
    DaysCalculator.hourFormatter.string(from: self)
  }
  
  var day: String {
    DaysCalculator.dayNameFormatter.string(from: self)
  }
  
  var month: String {
    DaysCalculator.monthFormatter.string(from: self)
  }
  
  var year: String {
    DaysCalculator.yearFormatter.string(from: self)
  }
  
  func isThisMonth() -> Bool {
    let currentMonth = DaysCalculator.monthFormatter.string(from: Date())
    let month = DaysCalculator.monthFormatter.string(from: self)
    return currentMonth == month
  }
}
