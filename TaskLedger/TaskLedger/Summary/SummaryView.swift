import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        Text("Summary View")
    }
}
