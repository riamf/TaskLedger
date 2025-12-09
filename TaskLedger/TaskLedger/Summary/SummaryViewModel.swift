import Foundation
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var currentMonthDate: Date = DaysCalculator.dateAtStartOfMonth(from: Date())
    @DInjected(\.fetcher) private var fetcher: Fetcher

    init() {}

    func fetchData() {
        
    }
}
