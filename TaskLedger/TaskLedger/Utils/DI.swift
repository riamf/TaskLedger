import Foundation
import SwiftData

@dynamicMemberLookup
final class DI {
    static let instance = DI()
    private(set) var modelContext: ModelContext!
    private(set) var fetcher = Fetcher()
    private(set) var haptics: HapticFeedbackService = HapticFeedbackManager()
    private(set) var notifications: NotificationService = NotificationManager()
    private(set) var calendar: Calendar = .current
    private init() {}
    
    func initalize(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<DI, T>) -> T {
        self[keyPath: keyPath] as T
    }
}

@propertyWrapper
struct DInjected<T> {
    let keyPath: KeyPath<DI, T>
    
    init(_ keyPath: KeyPath<DI, T>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T {
        get {
            DI.instance[keyPath: keyPath]
        }
        set { }
    }
}
