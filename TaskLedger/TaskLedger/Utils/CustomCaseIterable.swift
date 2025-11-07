import Foundation

protocol CustomCaseIterable: Hashable {
    static var allValuesSamples: [any CustomCaseIterable] { get }
    static var allNames: [String] { get }
    var name: String { get }
}
