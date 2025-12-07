import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("Day", systemImage: "sun.max")
                }
            
        }
    }
}

#Preview {
    MainView()
}
