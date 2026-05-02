import SwiftUI


struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var onboarding = DI.instance.onboarding
    
    var body: some View {
        Group {
            if onboarding.shouldShowAppIntroduction {
                FirstRunOnboardingView {
                    onboarding.completeAppIntroduction()
                }
            } else {
                mainTabs
            }
        }
    }

    private var mainTabs: some View {
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
