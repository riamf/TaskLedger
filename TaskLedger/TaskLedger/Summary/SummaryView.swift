import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.eventsDict.keys.sorted(by: { $0.name < $1.name }), id: \.self) { eventTask in
                
            }
        }
    }
}
