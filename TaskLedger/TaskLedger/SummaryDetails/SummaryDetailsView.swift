import SwiftUI

struct SummaryDetailsView: View {
    private let eventTask: EventTask
    
    init(eventTask: EventTask) {
        self.eventTask = eventTask
    }
    
    var body: some View {
        Text("Summary Details View")
    }
}

#Preview {
    let et = EventTask.example()
    SummaryDetailsView(eventTask: et)
}
