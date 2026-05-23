import SwiftUI
import SwiftData

@main
struct TaskLedgerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        DI.instance.analytics.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EventTask.self,
            EventMark.self
        ])
        let modelConfiguration: ModelConfiguration
        if UITestingConfiguration.useInMemoryStore {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
        }
        
        do {
            let container =  try ModelContainer(for: schema, configurations: [modelConfiguration])
            DI.instance.initalize(modelContext: container.mainContext)
            DI.instance.analytics.updateTotalTasksCount(DI.instance.fetcher.fetchActiveTaskCount())
            DI.instance.notifications.syncNotifications(
                for: DI.instance.fetcher.fetchTasksWithNotifications(),
                referenceDate: Date()
            )
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    syncNotifications()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                syncNotifications()
            }
        }
    }

    private func syncNotifications() {
        DI.instance.notifications.syncNotifications(
            for: DI.instance.fetcher.fetchTasksWithNotifications(),
            referenceDate: Date()
        )
    }
}
