import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("tab_day_title", systemImage: "calendar.day.timeline.left")
                }

            SummaryView()
                .tabItem {
                    Label("tab_summary_title", systemImage: "chart.bar.fill")
                }
        }
        .tint(colorScheme == .light ? .black : .white)
    }
}


#Preview {
    MainView()
}
