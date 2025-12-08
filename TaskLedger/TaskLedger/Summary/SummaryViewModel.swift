import Foundation
import SwiftUI

@Observable class SummaryViewModel {
    var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date())
    
}
