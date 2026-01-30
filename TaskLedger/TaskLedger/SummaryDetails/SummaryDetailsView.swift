import SwiftUI
import Charts

struct SummaryDetailsView: View {
    private let eventSummary: EventMartSummary
    
    init(eventSummary: EventMartSummary) {
        self.eventSummary = eventSummary
    }
    
    var body: some View {
        Chart(eventSummary.events, id: \.date) { event in
            PointMark(
                x: .value("Day", event.date),
                y: .value("Value", "X")
            )
            
        }
    }
}
//
//#Preview {
//    
//}
