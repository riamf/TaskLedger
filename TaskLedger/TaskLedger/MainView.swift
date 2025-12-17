import SwiftUI

struct MainView: View {
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
        .tint(.black)
    }
}

#Preview {
    MainView()
}
