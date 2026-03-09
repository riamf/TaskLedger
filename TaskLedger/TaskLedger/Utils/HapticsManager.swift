import Foundation
import UIKit

enum HapticStyle {
    case light, medium, heavy, soft, rigid
}

protocol HapticFeedbackService {
    func trigger(_ style: HapticStyle)
}

final class HapticFeedbackManager: HapticFeedbackService {
    func trigger(_ style: HapticStyle) {
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: feedbackStyle = .light
        case .medium: feedbackStyle = .medium
        case .heavy: feedbackStyle = .heavy
        case .soft: feedbackStyle = .soft
        case .rigid: feedbackStyle = .rigid
        }
        
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.prepare()
        generator.impactOccurred()
    }
}
