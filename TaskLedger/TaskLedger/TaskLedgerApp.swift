import SwiftUI
import SwiftData

@main
struct TaskLedgerApp: App {
    @Environment(\.modelContext) private var modelContext
    
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
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
