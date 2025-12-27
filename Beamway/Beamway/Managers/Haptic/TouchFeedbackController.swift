//
//  TouchFeedbackController.swift
//  Beamway
//
//  Haptic feedback and touch response management
//

import UIKit

/// Controller managing haptic feedback and touch response throughout the application
/// Provides consistent tactile feedback for user interactions
final class TouchFeedbackController {

    // MARK: - Singleton Access

    /// Shared controller instance
    static let shared = TouchFeedbackController()

    // MARK: - Properties

    /// Impact feedback generator for collision effects
    private let impactFeedbackGenerator: UIImpactFeedbackGenerator

    /// Selection feedback generator for UI selections
    private let selectionFeedbackGenerator: UISelectionFeedbackGenerator

    /// Notification feedback generator for status notifications
    private let notificationFeedbackGenerator: UINotificationFeedbackGenerator

    /// Whether haptic feedback is enabled
    private(set) var isHapticFeedbackEnabled: Bool

    /// Haptic intensity multiplier (0.0 to 1.0)
    private var hapticIntensityMultiplier: CGFloat = 1.0

    /// Last feedback timestamp for rate limiting
    private var lastFeedbackTimestamp: Date?

    /// Minimum interval between feedbacks
    private let minimumFeedbackInterval: TimeInterval = 0.05

    // MARK: - Initialization

    private init() {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.notificationFeedbackGenerator = UINotificationFeedbackGenerator()

        // Check device capability
        self.isHapticFeedbackEnabled = ApplicationEnvironment.shared.supportsHapticFeedback

        prepareAllGenerators()
    }

    // MARK: - Generator Preparation

    /// Prepare all feedback generators for immediate response
    private func prepareAllGenerators() {
        guard isHapticFeedbackEnabled else { return }

        impactFeedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }

    // MARK: - Configuration

    /// Enable or disable haptic feedback
    func setHapticFeedbackEnabled(_ enabled: Bool) {
        isHapticFeedbackEnabled = enabled && ApplicationEnvironment.shared.supportsHapticFeedback

        if isHapticFeedbackEnabled {
            prepareAllGenerators()
        }
    }

    /// Set haptic intensity multiplier
    func setHapticIntensity(_ intensity: CGFloat) {
        hapticIntensityMultiplier = max(0.0, min(1.0, intensity))
    }

    // MARK: - Impact Feedback

    /// Generate light impact feedback
    func generateLightImpactFeedback() {
        generateImpactFeedback(style: .light)
    }

    /// Generate medium impact feedback
    func generateMediumImpactFeedback() {
        generateImpactFeedback(style: .medium)
    }

    /// Generate heavy impact feedback
    func generateHeavyImpactFeedback() {
        generateImpactFeedback(style: .heavy)
    }

    /// Generate rigid impact feedback
    func generateRigidImpactFeedback() {
        generateImpactFeedback(style: .rigid)
    }

    /// Generate soft impact feedback
    func generateSoftImpactFeedback() {
        generateImpactFeedback(style: .soft)
    }

    /// Generate impact feedback with specific style
    private func generateImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard canGenerateFeedback() else { return }

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: hapticIntensityMultiplier)

        recordFeedbackTimestamp()
    }

    // MARK: - Selection Feedback

    /// Generate selection changed feedback
    func generateSelectionChangedFeedback() {
        guard canGenerateFeedback() else { return }

        selectionFeedbackGenerator.selectionChanged()
        selectionFeedbackGenerator.prepare()

        recordFeedbackTimestamp()
    }

    // MARK: - Notification Feedback

    /// Generate success notification feedback
    func generateSuccessNotificationFeedback() {
        generateNotificationFeedback(type: .success)
    }

    /// Generate warning notification feedback
    func generateWarningNotificationFeedback() {
        generateNotificationFeedback(type: .warning)
    }

    /// Generate error notification feedback
    func generateErrorNotificationFeedback() {
        generateNotificationFeedback(type: .error)
    }

    /// Generate notification feedback with specific type
    private func generateNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard canGenerateFeedback() else { return }

        notificationFeedbackGenerator.notificationOccurred(type)
        notificationFeedbackGenerator.prepare()

        recordFeedbackTimestamp()
    }

    // MARK: - Game-Specific Feedback

    /// Generate feedback for successful dodge
    func generateDodgeSuccessFeedback() {
        generateLightImpactFeedback()
    }

    /// Generate feedback for collision/hit
    func generateCollisionFeedback() {
        generateHeavyImpactFeedback()
    }

    /// Generate feedback for game over
    func generateGameOverFeedback() {
        generateErrorNotificationFeedback()
    }

    /// Generate feedback for level up
    func generateLevelUpFeedback() {
        generateSuccessNotificationFeedback()
    }

    /// Generate feedback for combo increase
    func generateComboIncreaseFeedback(comboLevel: Int) {
        if comboLevel >= 10 {
            generateMediumImpactFeedback()
        } else {
            generateLightImpactFeedback()
        }
    }

    /// Generate feedback for button press
    func generateButtonPressFeedback() {
        generateLightImpactFeedback()
    }

    /// Generate feedback for button release
    func generateButtonReleaseFeedback() {
        generateSelectionChangedFeedback()
    }

    /// Generate feedback for tile drag start
    func generateTileDragStartFeedback() {
        generateLightImpactFeedback()
    }

    /// Generate feedback for tile drag end
    func generateTileDragEndFeedback() {
        generateSoftImpactFeedback()
    }

    // MARK: - Rate Limiting

    /// Check if feedback can be generated based on rate limiting
    private func canGenerateFeedback() -> Bool {
        guard isHapticFeedbackEnabled else { return false }

        if let lastTimestamp = lastFeedbackTimestamp {
            let timeSinceLastFeedback = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastFeedback < minimumFeedbackInterval {
                return false
            }
        }

        return true
    }

    /// Record current timestamp for rate limiting
    private func recordFeedbackTimestamp() {
        lastFeedbackTimestamp = Date()
    }

    // MARK: - Custom Feedback Patterns

    /// Generate custom feedback pattern
    func generateCustomFeedbackPattern(_ pattern: HapticFeedbackPattern) {
        guard isHapticFeedbackEnabled else { return }

        DispatchQueue.global(qos: .userInteractive).async {
            for (index, step) in pattern.steps.enumerated() {
                let delay = pattern.delays[safe: index] ?? 0

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    switch step {
                    case .lightImpact:
                        self.generateLightImpactFeedback()
                    case .mediumImpact:
                        self.generateMediumImpactFeedback()
                    case .heavyImpact:
                        self.generateHeavyImpactFeedback()
                    case .selection:
                        self.generateSelectionChangedFeedback()
                    case .success:
                        self.generateSuccessNotificationFeedback()
                    case .warning:
                        self.generateWarningNotificationFeedback()
                    case .error:
                        self.generateErrorNotificationFeedback()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

/// Haptic feedback pattern definition
struct HapticFeedbackPattern {
    let steps: [HapticFeedbackStep]
    let delays: [TimeInterval]

    static let doubleTap = HapticFeedbackPattern(
        steps: [.lightImpact, .lightImpact],
        delays: [0, 0.1]
    )

    static let celebration = HapticFeedbackPattern(
        steps: [.mediumImpact, .lightImpact, .success],
        delays: [0, 0.15, 0.3]
    )

    static let warning = HapticFeedbackPattern(
        steps: [.heavyImpact, .warning],
        delays: [0, 0.2]
    )

    static let countdown = HapticFeedbackPattern(
        steps: [.lightImpact, .lightImpact, .lightImpact, .heavyImpact],
        delays: [0, 1.0, 2.0, 3.0]
    )
}

/// Haptic feedback step enumeration
enum HapticFeedbackStep {
    case lightImpact
    case mediumImpact
    case heavyImpact
    case selection
    case success
    case warning
    case error
}

// MARK: - Array Extension

fileprivate extension Array {
    /// Safe subscript access
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Touch Responder Protocol

/// Protocol for views that provide touch feedback
protocol TouchFeedbackResponder {
    /// Generate feedback for touch began
    func generateTouchBeganFeedback()

    /// Generate feedback for touch ended
    func generateTouchEndedFeedback()

    /// Generate feedback for touch cancelled
    func generateTouchCancelledFeedback()
}

extension TouchFeedbackResponder {
    func generateTouchBeganFeedback() {
        TouchFeedbackController.shared.generateButtonPressFeedback()
    }

    func generateTouchEndedFeedback() {
        TouchFeedbackController.shared.generateButtonReleaseFeedback()
    }

    func generateTouchCancelledFeedback() {
        // No feedback on cancellation by default
    }
}
