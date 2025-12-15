import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("Day", systemImage: "calendar.day.timeline.left").tint(.black)
                }
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "sum").tint(.black)
                }
        }
    }
}

#Preview {
    MainView()
}
