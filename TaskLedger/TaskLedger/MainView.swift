import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("Day", systemImage: "calendar.day.timeline.left")
                }

            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.fill")
                }
        }
        .tint(colorScheme == .light ? .black : .white)
    }
}


#Preview {
    MainView()
}
