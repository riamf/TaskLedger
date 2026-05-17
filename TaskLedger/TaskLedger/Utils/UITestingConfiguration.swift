import Foundation

enum UITestingConfiguration {
    private static let launchArguments = ProcessInfo.processInfo.arguments

    static let isEnabled = launchArguments.contains("UI-TESTING")
    static let useInMemoryStore = launchArguments.contains("UI-TESTING-IN-MEMORY-STORE")
    static let skipOnboarding = launchArguments.contains("UI-TESTING-SKIP-ONBOARDING")
}
