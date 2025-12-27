//
//  WelcomeScreenAnimationCoordinator.swift
//  Beamway
//
//  Animation coordination for welcome screen transitions
//

import UIKit

/// Coordinator managing welcome screen entrance and exit animations
final class WelcomeScreenAnimationCoordinator {

    // MARK: - Type Definitions

    /// Animation sequence configuration
    struct AnimationSequenceConfiguration {
        let initialDelay: TimeInterval
        let staggerInterval: TimeInterval
        let animationDuration: TimeInterval
        let springDamping: CGFloat
        let initialSpringVelocity: CGFloat

        static let standardEntrance = AnimationSequenceConfiguration(
            initialDelay: 0.1,
            staggerInterval: 0.1,
            animationDuration: 0.5,
            springDamping: 0.8,
            initialSpringVelocity: 0.5
        )
    }

    /// Initial transform type for entrance animations
    enum InitialTransformType {
        case translateFromTop(offset: CGFloat)
        case translateFromBottom(offset: CGFloat)
        case translateFromLeft(offset: CGFloat)
        case translateFromRight(offset: CGFloat)
        case scaleDown(factor: CGFloat)
        case combined(translation: CGPoint, scale: CGFloat)

        var transform: CGAffineTransform {
            switch self {
            case .translateFromTop(let offset):
                return CGAffineTransform(translationX: 0, y: -offset)
            case .translateFromBottom(let offset):
                return CGAffineTransform(translationX: 0, y: offset)
            case .translateFromLeft(let offset):
                return CGAffineTransform(translationX: -offset, y: 0)
            case .translateFromRight(let offset):
                return CGAffineTransform(translationX: offset, y: 0)
            case .scaleDown(let factor):
                return CGAffineTransform(scaleX: factor, y: factor)
            case .combined(let translation, let scale):
                return CGAffineTransform(scaleX: scale, y: scale)
                    .translatedBy(x: translation.x, y: translation.y)
            }
        }
    }

    // MARK: - Properties

    /// Animation configuration
    private let animationConfiguration: AnimationSequenceConfiguration

    /// Registered animated views with their configurations
    private var registeredViews: [(view: UIView, transform: InitialTransformType, delay: TimeInterval)] = []

    // MARK: - Initialization

    init(configuration: AnimationSequenceConfiguration = .standardEntrance) {
        self.animationConfiguration = configuration
    }

    // MARK: - View Registration

    /// Register view for entrance animation
    func registerViewForAnimation(
        _ view: UIView,
        initialTransform: InitialTransformType,
        customDelay: TimeInterval? = nil
    ) {
        let delay = customDelay ?? (animationConfiguration.initialDelay + Double(registeredViews.count) * animationConfiguration.staggerInterval)
        registeredViews.append((view, initialTransform, delay))
    }

    /// Register multiple views with default staggered delays
    func registerViewsForStaggeredAnimation(_ views: [(view: UIView, transform: InitialTransformType)]) {
        for (index, item) in views.enumerated() {
            let delay = animationConfiguration.initialDelay + Double(index) * animationConfiguration.staggerInterval
            registeredViews.append((item.view, item.transform, delay))
        }
    }

    // MARK: - Animation Execution

    /// Prepare all registered views for entrance animation
    func prepareForEntranceAnimation() {
        for item in registeredViews {
            item.view.alpha = 0
            item.view.transform = item.transform.transform
        }
    }

    /// Execute entrance animation sequence
    func executeEntranceAnimationSequence(completion: (() -> Void)? = nil) {
        guard !registeredViews.isEmpty else {
            completion?()
            return
        }

        let totalDuration = registeredViews.last?.delay ?? 0 + animationConfiguration.animationDuration

        for item in registeredViews {
            UIView.animate(
                withDuration: animationConfiguration.animationDuration,
                delay: item.delay,
                usingSpringWithDamping: animationConfiguration.springDamping,
                initialSpringVelocity: animationConfiguration.initialSpringVelocity
            ) {
                item.view.alpha = 1
                item.view.transform = .identity
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            completion?()
        }
    }

    /// Execute exit animation sequence
    func executeExitAnimationSequence(completion: @escaping () -> Void) {
        let reversedViews = registeredViews.reversed()
        let exitDuration: TimeInterval = 0.3

        for (index, item) in reversedViews.enumerated() {
            let delay = Double(index) * 0.05

            UIView.animate(
                withDuration: exitDuration,
                delay: delay,
                options: .curveEaseIn
            ) {
                item.view.alpha = 0
                item.view.transform = item.transform.transform
            }
        }

        let totalDuration = Double(registeredViews.count) * 0.05 + exitDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            completion()
        }
    }

    // MARK: - Individual Animations

    /// Animate single view entrance
    func animateSingleViewEntrance(
        _ view: UIView,
        from transform: InitialTransformType,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        view.alpha = 0
        view.transform = transform.transform

        UIView.animate(
            withDuration: animationConfiguration.animationDuration,
            delay: delay,
            usingSpringWithDamping: animationConfiguration.springDamping,
            initialSpringVelocity: animationConfiguration.initialSpringVelocity
        ) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    /// Animate single view exit
    func animateSingleViewExit(
        _ view: UIView,
        to transform: InitialTransformType,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            view.alpha = 0
            view.transform = transform.transform
        } completion: { _ in
            completion?()
        }
    }

    // MARK: - Cleanup

    /// Clear all registered views
    func clearRegisteredViews() {
        registeredViews.removeAll()
    }
}

// MARK: - Title Glow Animation Controller

/// Controller for title label glow animation effect
final class TitleGlowAnimationController {

    // MARK: - Properties

    /// Target label for glow effect
    private weak var targetLabel: UILabel?

    /// Glow animation key
    private let glowAnimationKey = "titleGlowAnimation"

    /// Base shadow radius
    private let baseShadowRadius: CGFloat

    /// Peak shadow radius
    private let peakShadowRadius: CGFloat

    /// Animation duration
    private let animationDuration: TimeInterval

    // MARK: - Initialization

    init(
        baseShadowRadius: CGFloat = 20,
        peakShadowRadius: CGFloat = 30,
        animationDuration: TimeInterval = 2.0
    ) {
        self.baseShadowRadius = baseShadowRadius
        self.peakShadowRadius = peakShadowRadius
        self.animationDuration = animationDuration
    }

    // MARK: - Configuration

    /// Configure target label for glow effect
    func configureTargetLabel(_ label: UILabel, glowColor: UIColor) {
        self.targetLabel = label

        label.layer.shadowColor = glowColor.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = baseShadowRadius
        label.layer.shadowOpacity = 0.8
    }

    // MARK: - Animation Control

    /// Start continuous glow animation
    func startGlowAnimation() {
        guard let label = targetLabel else { return }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            label.layer.shadowRadius = self.peakShadowRadius
            label.layer.shadowOpacity = 1.0
        }
    }

    /// Stop glow animation
    func stopGlowAnimation() {
        guard let label = targetLabel else { return }

        label.layer.removeAllAnimations()
        label.layer.shadowRadius = baseShadowRadius
        label.layer.shadowOpacity = 0.8
    }

    /// Pulse glow effect once
    func pulseGlowEffect(completion: (() -> Void)? = nil) {
        guard let label = targetLabel else {
            completion?()
            return
        }

        UIView.animate(
            withDuration: animationDuration / 4,
            delay: 0,
            options: .curveEaseOut
        ) {
            label.layer.shadowRadius = self.peakShadowRadius * 1.5
            label.layer.shadowOpacity = 1.0
        } completion: { _ in
            UIView.animate(withDuration: self.animationDuration / 4) {
                label.layer.shadowRadius = self.baseShadowRadius
                label.layer.shadowOpacity = 0.8
            } completion: { _ in
                completion?()
            }
        }
    }
}

// MARK: - Floating Elements Animation Controller

/// Controller managing floating decorative element animations
final class FloatingElementsAnimationController {

    // MARK: - Type Definitions

    /// Floating element configuration
    struct FloatingElementConfiguration {
        let elementCount: Int
        let elementSize: CGSize
        let opacity: CGFloat
        let driftSpeed: CGFloat
        let rotationRange: ClosedRange<CGFloat>

        static let standard = FloatingElementConfiguration(
            elementCount: 5,
            elementSize: CGSize(width: 40, height: 57),
            opacity: 0.15,
            driftSpeed: 0.3,
            rotationRange: -0.2...0.2
        )
    }

    // MARK: - Properties

    /// Floating element views
    private var floatingElements: [UIImageView] = []

    /// Animation timer
    private var animationTimer: Timer?

    /// Configuration
    private let configuration: FloatingElementConfiguration

    /// Parent container reference
    private weak var parentContainer: UIView?

    /// Whether animation is active
    private(set) var isAnimationActive: Bool = false

    // MARK: - Initialization

    init(configuration: FloatingElementConfiguration = .standard) {
        self.configuration = configuration
    }

    // MARK: - Setup

    /// Setup floating elements in parent container
    func setupFloatingElements(in container: UIView, aboveView referenceView: UIView? = nil) {
        self.parentContainer = container

        for _ in 0..<configuration.elementCount {
            let element = createFloatingElement()

            if let reference = referenceView {
                container.insertSubview(element, aboveSubview: reference)
            } else {
                container.addSubview(element)
            }

            floatingElements.append(element)
        }
    }

    /// Create single floating element
    private func createFloatingElement() -> UIImageView {
        let elementView = UIImageView()
        let imageName = "be \(Int.random(in: 0...26))"
        elementView.image = UIImage(named: imageName)
        elementView.contentMode = .scaleAspectFit
        elementView.alpha = configuration.opacity

        let screenBounds = UIScreen.main.bounds
        elementView.frame = CGRect(
            x: CGFloat.random(in: 0...screenBounds.width),
            y: CGFloat.random(in: 0...screenBounds.height),
            width: configuration.elementSize.width,
            height: configuration.elementSize.height
        )

        return elementView
    }

    // MARK: - Animation Control

    /// Start floating animation
    func startAnimation() {
        guard !isAnimationActive else { return }

        isAnimationActive = true
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { [weak self] _ in
            self?.updateElementPositions()
        }
    }

    /// Stop floating animation
    func stopAnimation() {
        isAnimationActive = false
        animationTimer?.invalidate()
        animationTimer = nil
    }

    /// Update element positions for drift effect
    private func updateElementPositions() {
        let screenBounds = UIScreen.main.bounds

        for element in floatingElements {
            var position = element.center
            position.y += configuration.driftSpeed
            position.x += CGFloat.random(in: -0.2...0.2)

            element.transform = element.transform.rotated(by: 0.002)

            if position.y > screenBounds.height + 50 {
                position.y = -50
                position.x = CGFloat.random(in: 0...screenBounds.width)
                element.image = UIImage(named: "be \(Int.random(in: 0...26))")
            }

            element.center = position
        }
    }

    // MARK: - Cleanup

    /// Remove all floating elements
    func removeAllElements() {
        stopAnimation()

        for element in floatingElements {
            element.removeFromSuperview()
        }
        floatingElements.removeAll()
    }

    deinit {
        stopAnimation()
    }
}

// MARK: - Particle Effect Animation Controller

/// Controller for particle emitter effects on welcome screen
final class WelcomeParticleEffectController {

    // MARK: - Properties

    /// Emitter layer
    private let emitterLayer: CAEmitterLayer

    /// Emitter cell
    private let emitterCell: CAEmitterCell

    /// Particle color
    private let particleColor: UIColor

    // MARK: - Initialization

    init(particleColor: UIColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.6)) {
        self.particleColor = particleColor
        self.emitterLayer = CAEmitterLayer()
        self.emitterCell = CAEmitterCell()

        configureEmitter()
    }

    // MARK: - Configuration

    /// Configure emitter
    private func configureEmitter() {
        emitterCell.birthRate = 3
        emitterCell.lifetime = 8
        emitterCell.velocity = 50
        emitterCell.velocityRange = 30
        emitterCell.emissionLongitude = .pi
        emitterCell.emissionRange = .pi / 4
        emitterCell.scale = 0.1
        emitterCell.scaleRange = 0.05
        emitterCell.alphaSpeed = -0.1
        emitterCell.color = particleColor.cgColor
        emitterCell.contents = generateParticleImage()?.cgImage

        emitterLayer.emitterShape = .line
        emitterLayer.renderMode = .additive
        emitterLayer.emitterCells = [emitterCell]
    }

    /// Generate particle image
    private func generateParticleImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: 10, y: 10),
            startRadius: 0,
            endCenter: CGPoint(x: 10, y: 10),
            endRadius: 10,
            options: []
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: - Installation

    /// Install emitter in parent layer
    func installInParentLayer(_ parentLayer: CALayer, screenBounds: CGRect) {
        emitterLayer.emitterPosition = CGPoint(x: screenBounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: screenBounds.width, height: 1)
        parentLayer.addSublayer(emitterLayer)
    }

    /// Update emitter bounds
    func updateBounds(_ bounds: CGRect) {
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: 1)
    }

    // MARK: - Control

    /// Start particle emission
    func startEmission() {
        emitterCell.birthRate = 3
    }

    /// Stop particle emission
    func stopEmission() {
        emitterCell.birthRate = 0
    }

    /// Remove from parent
    func removeFromParent() {
        emitterLayer.removeFromSuperlayer()
    }
}
