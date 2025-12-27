//
//  MotionEffectsCoordinator.swift
//  Beamway
//
//  Animation and motion effects coordination system
//

import UIKit

/// Coordinator managing all animation and motion effects throughout the application
/// Provides centralized animation timing, sequencing, and effect management
final class MotionEffectsCoordinator {

    // MARK: - Singleton Access

    /// Shared coordinator instance
    static let shared = MotionEffectsCoordinator()

    // MARK: - Properties

    /// Active animation references for cancellation
    private var activeAnimationIdentifiers: Set<String> = []

    /// Animation queue for sequential execution
    private var animationExecutionQueue: [QueuedAnimationItem] = []

    /// Whether queue execution is currently in progress
    private var isExecutingQueue: Bool = false

    /// Default animation configuration
    private let defaultAnimationConfiguration: MotionEffectConfiguration

    /// Maximum concurrent animations allowed
    private let maximumConcurrentAnimations: Int

    // MARK: - Initialization

    private init() {
        self.defaultAnimationConfiguration = MotionEffectConfiguration.standardConfiguration
        self.maximumConcurrentAnimations = ApplicationEnvironment.shared.hardwareClassification.maxConcurrentAnimations
    }

    // MARK: - Standard Motion Effects

    /// Execute scale pulse animation on view
    func executeScalePulseEffect(on targetView: UIView,
                                  scaleMultiplier: CGFloat = 1.2,
                                  duration: TimeInterval = 0.15,
                                  completion: (() -> Void)? = nil) {
        let animationIdentifier = generateAnimationIdentifier()
        activeAnimationIdentifiers.insert(animationIdentifier)

        let pulseAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            targetView.transform = CGAffineTransform(scaleX: scaleMultiplier, y: scaleMultiplier)
        }

        pulseAnimator.addCompletion { [weak self] _ in
            UIView.animate(withDuration: duration * 0.6) {
                targetView.transform = .identity
            } completion: { _ in
                self?.activeAnimationIdentifiers.remove(animationIdentifier)
                completion?()
            }
        }

        pulseAnimator.startAnimation()
    }

    /// Execute spring entrance animation
    func executeSpringEntranceEffect(on targetView: UIView,
                                      fromTransform initialTransform: CGAffineTransform,
                                      delay: TimeInterval = 0,
                                      dampingRatio: CGFloat = 0.8,
                                      duration: TimeInterval = 0.5,
                                      completion: (() -> Void)? = nil) {
        let animationIdentifier = generateAnimationIdentifier()
        activeAnimationIdentifiers.insert(animationIdentifier)

        targetView.transform = initialTransform
        targetView.alpha = 0

        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            targetView.transform = .identity
            targetView.alpha = 1
        } completion: { [weak self] _ in
            self?.activeAnimationIdentifiers.remove(animationIdentifier)
            completion?()
        }
    }

    /// Execute fade transition effect
    func executeFadeTransitionEffect(on targetView: UIView,
                                      targetAlpha: CGFloat,
                                      duration: TimeInterval = 0.3,
                                      delay: TimeInterval = 0,
                                      completion: (() -> Void)? = nil) {
        let animationIdentifier = generateAnimationIdentifier()
        activeAnimationIdentifiers.insert(animationIdentifier)

        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
            targetView.alpha = targetAlpha
        } completion: { [weak self] _ in
            self?.activeAnimationIdentifiers.remove(animationIdentifier)
            completion?()
        }
    }

    /// Execute shake/vibration effect
    func executeShakeVibrationEffect(on targetView: UIView,
                                      intensity: CGFloat = 10,
                                      duration: TimeInterval = 0.5,
                                      completion: (() -> Void)? = nil) {
        let animationIdentifier = generateAnimationIdentifier()
        activeAnimationIdentifiers.insert(animationIdentifier)

        let horizontalShake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        horizontalShake.timingFunction = CAMediaTimingFunction(name: .linear)
        horizontalShake.duration = duration
        horizontalShake.values = [
            -intensity, intensity, -intensity, intensity,
            -intensity * 0.5, intensity * 0.5, -intensity * 0.5, intensity * 0.5, 0
        ]

        let verticalShake = CAKeyframeAnimation(keyPath: "transform.translation.y")
        verticalShake.timingFunction = CAMediaTimingFunction(name: .linear)
        verticalShake.duration = duration
        verticalShake.values = [
            -intensity * 0.5, intensity * 0.5, -intensity * 0.5, intensity * 0.5,
            -intensity * 0.3, intensity * 0.3, -intensity * 0.3, intensity * 0.3, 0
        ]

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.activeAnimationIdentifiers.remove(animationIdentifier)
            completion?()
        }

        targetView.layer.add(horizontalShake, forKey: "horizontalShake")
        targetView.layer.add(verticalShake, forKey: "verticalShake")

        CATransaction.commit()
    }

    /// Execute glow pulse effect on layer
    func executeGlowPulseEffect(on targetLayer: CALayer,
                                 glowColor: UIColor,
                                 baseRadius: CGFloat = 15,
                                 peakRadius: CGFloat = 25,
                                 duration: TimeInterval = 1.5) {
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = baseRadius
        glowAnimation.toValue = peakRadius
        glowAnimation.duration = duration
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        targetLayer.shadowColor = glowColor.cgColor
        targetLayer.shadowOffset = .zero
        targetLayer.shadowOpacity = 0.8
        targetLayer.shadowRadius = baseRadius

        targetLayer.add(glowAnimation, forKey: "glowPulse")
    }

    /// Execute border dash animation
    func executeBorderDashAnimation(on shapeLayer: CAShapeLayer,
                                     dashLength: CGFloat = 8,
                                     gapLength: CGFloat = 4,
                                     duration: TimeInterval = 1.5) {
        shapeLayer.lineDashPattern = [NSNumber(value: Float(dashLength)), NSNumber(value: Float(gapLength))]

        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0
        dashAnimation.toValue = dashLength + gapLength
        dashAnimation.duration = duration
        dashAnimation.repeatCount = .infinity

        shapeLayer.add(dashAnimation, forKey: "dashAnimation")
    }

    // MARK: - Composite Motion Sequences

    /// Execute entrance animation sequence for multiple views
    func executeStaggeredEntranceSequence(views: [UIView],
                                           staggerDelay: TimeInterval = 0.1,
                                           initialTransformGenerator: ((Int) -> CGAffineTransform)? = nil,
                                           completion: (() -> Void)? = nil) {
        let viewCount = views.count
        var completedCount = 0

        for (index, view) in views.enumerated() {
            let initialTransform: CGAffineTransform
            if let generator = initialTransformGenerator {
                initialTransform = generator(index)
            } else {
                initialTransform = CGAffineTransform(translationX: 0, y: 30)
            }

            let delay = TimeInterval(index) * staggerDelay

            executeSpringEntranceEffect(
                on: view,
                fromTransform: initialTransform,
                delay: delay
            ) {
                completedCount += 1
                if completedCount == viewCount {
                    completion?()
                }
            }
        }
    }

    /// Execute impact effect sequence (for collision)
    func executeImpactEffectSequence(on targetView: UIView,
                                      flashView: UIView? = nil,
                                      completion: (() -> Void)? = nil) {
        // Scale flash
        UIView.animate(withDuration: 0.1) {
            targetView.alpha = 0.5
            targetView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                targetView.alpha = 1.0
                targetView.transform = .identity
            }
        }

        // Screen shake
        executeShakeVibrationEffect(on: targetView.superview ?? targetView)

        // Flash overlay if provided
        if let flash = flashView {
            flash.alpha = 0
            UIView.animate(withDuration: 0.1) {
                flash.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    flash.alpha = 0
                } completion: { _ in
                    completion?()
                }
            }
        } else {
            completion?()
        }
    }

    // MARK: - Animation Queue Management

    /// Add animation to execution queue
    func queueAnimation(_ animationItem: QueuedAnimationItem) {
        animationExecutionQueue.append(animationItem)

        if !isExecutingQueue {
            processAnimationQueue()
        }
    }

    /// Process queued animations sequentially
    private func processAnimationQueue() {
        guard !animationExecutionQueue.isEmpty else {
            isExecutingQueue = false
            return
        }

        isExecutingQueue = true
        let nextItem = animationExecutionQueue.removeFirst()

        nextItem.animationBlock { [weak self] in
            self?.processAnimationQueue()
        }
    }

    /// Clear animation queue
    func clearAnimationQueue() {
        animationExecutionQueue.removeAll()
        isExecutingQueue = false
    }

    // MARK: - Animation Cancellation

    /// Cancel all active animations
    func cancelAllActiveAnimations() {
        activeAnimationIdentifiers.removeAll()
        clearAnimationQueue()
    }

    // MARK: - Utility Methods

    /// Generate unique animation identifier
    private func generateAnimationIdentifier() -> String {
        return UUID().uuidString
    }

    /// Check if animations are currently active
    var hasActiveAnimations: Bool {
        return !activeAnimationIdentifiers.isEmpty || isExecutingQueue
    }
}

// MARK: - Supporting Types

/// Motion effect configuration structure
struct MotionEffectConfiguration {
    let defaultDuration: TimeInterval
    let defaultDampingRatio: CGFloat
    let defaultSpringVelocity: CGFloat
    let defaultCurve: UIView.AnimationCurve

    static let standardConfiguration = MotionEffectConfiguration(
        defaultDuration: 0.3,
        defaultDampingRatio: 0.8,
        defaultSpringVelocity: 0.5,
        defaultCurve: .easeInOut
    )

    static let quickConfiguration = MotionEffectConfiguration(
        defaultDuration: 0.15,
        defaultDampingRatio: 0.7,
        defaultSpringVelocity: 0.8,
        defaultCurve: .easeOut
    )

    static let dramaticConfiguration = MotionEffectConfiguration(
        defaultDuration: 0.5,
        defaultDampingRatio: 0.5,
        defaultSpringVelocity: 0.3,
        defaultCurve: .easeInOut
    )
}

/// Queued animation item structure
struct QueuedAnimationItem {
    let identifier: String
    let animationBlock: (@escaping () -> Void) -> Void

    init(identifier: String = UUID().uuidString, animationBlock: @escaping (@escaping () -> Void) -> Void) {
        self.identifier = identifier
        self.animationBlock = animationBlock
    }
}

// MARK: - Layer Animation Extensions

extension CALayer {

    /// Remove all animations with fade out
    func removeAllAnimationsWithFadeOut(duration: TimeInterval = 0.2) {
        let currentOpacity = presentation()?.opacity ?? opacity

        removeAllAnimations()

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = currentOpacity
        fadeAnimation.toValue = opacity
        fadeAnimation.duration = duration
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        add(fadeAnimation, forKey: "fadeOutRemoval")
    }

    /// Pause all layer animations
    func pauseAllAnimations() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    /// Resume all layer animations
    func resumeAllAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

// MARK: - View Animation Convenience Extensions

extension UIView {

    /// Execute bounce animation
    func executeBounceAnimation(scale: CGFloat = 0.9, duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(withDuration: duration * 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                self.transform = .identity
            }
        }
    }

    /// Execute rotation animation
    func executeRotationAnimation(angle: CGFloat, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = self.transform.rotated(by: angle)
        }, completion: { _ in
            completion?()
        })
    }

    /// Execute slide in animation from direction
    func executeSlideInAnimation(from direction: SlideDirection, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let screenBounds = UIScreen.main.bounds
        var startTransform: CGAffineTransform

        switch direction {
        case .fromTop:
            startTransform = CGAffineTransform(translationX: 0, y: -screenBounds.height)
        case .fromBottom:
            startTransform = CGAffineTransform(translationX: 0, y: screenBounds.height)
        case .fromLeft:
            startTransform = CGAffineTransform(translationX: -screenBounds.width, y: 0)
        case .fromRight:
            startTransform = CGAffineTransform(translationX: screenBounds.width, y: 0)
        }

        transform = startTransform

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
}

/// Slide direction enumeration
enum SlideDirection {
    case fromTop
    case fromBottom
    case fromLeft
    case fromRight
}
