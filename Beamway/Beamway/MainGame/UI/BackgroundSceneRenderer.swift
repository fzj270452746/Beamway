//
//  BackgroundSceneRenderer.swift
//  Beamway
//
//  Background scene rendering and visual effects management
//

import UIKit

/// Renderer managing background visuals and atmospheric effects
final class BackgroundSceneRenderer {

    // MARK: - Type Definitions

    /// Configuration for background scene rendering
    struct BackgroundSceneConfiguration {
        let backdropImageName: String?
        let fallbackColor: UIColor
        let gradientColors: [UIColor]
        let gradientLocations: [NSNumber]
        let gradientAlpha: CGFloat

        static let defaultConfiguration = BackgroundSceneConfiguration(
            backdropImageName: "benImage",
            fallbackColor: UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0),
            gradientColors: [
                UIColor.black.withAlphaComponent(0.6),
                UIColor.black.withAlphaComponent(0.2),
                UIColor.black.withAlphaComponent(0.4)
            ],
            gradientLocations: [0.0, 0.5, 1.0],
            gradientAlpha: 1.0
        )
    }

    // MARK: - Properties

    /// Background image view
    private let backdropImageView: UIImageView

    /// Gradient overlay view
    private let gradientOverlayView: UIView

    /// Gradient layer reference
    private let gradientLayer: CAGradientLayer

    /// Scene configuration
    private let sceneConfiguration: BackgroundSceneConfiguration

    /// Parent container reference
    private weak var parentContainerView: UIView?

    // MARK: - Initialization

    init(configuration: BackgroundSceneConfiguration = .defaultConfiguration) {
        self.sceneConfiguration = configuration
        self.backdropImageView = UIImageView()
        self.gradientOverlayView = UIView()
        self.gradientLayer = CAGradientLayer()

        configureBackdropImage()
        configureGradientOverlay()
    }

    // MARK: - Configuration

    /// Configure backdrop image view
    private func configureBackdropImage() {
        if let imageName = sceneConfiguration.backdropImageName,
           let backgroundImage = UIImage(named: imageName) {
            backdropImageView.image = backgroundImage
        } else {
            backdropImageView.backgroundColor = sceneConfiguration.fallbackColor
        }

        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true
    }

    /// Configure gradient overlay
    private func configureGradientOverlay() {
        gradientLayer.colors = sceneConfiguration.gradientColors.map { $0.cgColor }
        gradientLayer.locations = sceneConfiguration.gradientLocations
        gradientOverlayView.layer.addSublayer(gradientLayer)
    }

    // MARK: - Installation

    /// Install background scene into parent view
    func installInParentView(_ parentView: UIView) {
        self.parentContainerView = parentView

        parentView.addSubview(backdropImageView)
        parentView.addSubview(gradientOverlayView)

        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: parentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),

            gradientOverlayView.topAnchor.constraint(equalTo: parentView.topAnchor),
            gradientOverlayView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    /// Update gradient layer frame
    func updateGradientFrame(to frame: CGRect) {
        gradientLayer.frame = frame
    }

    // MARK: - Visual Effects

    /// Apply screen shake effect
    func applyScreenShakeEffect(intensity: CGFloat = 10, duration: TimeInterval = 0.3) {
        guard let container = parentContainerView else { return }

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [
            -intensity,
            intensity,
            -intensity * 0.8,
            intensity * 0.8,
            -intensity * 0.5,
            intensity * 0.5,
            0
        ]
        container.layer.add(animation, forKey: "shakeAnimation")
    }

    /// Apply flash effect
    func applyFlashEffect(color: UIColor, duration: TimeInterval = 0.2) {
        guard let container = parentContainerView else { return }

        let flashView = UIView()
        flashView.backgroundColor = color.withAlphaComponent(0.3)
        flashView.frame = container.bounds
        flashView.alpha = 0
        container.addSubview(flashView)

        UIView.animate(withDuration: duration / 2, animations: {
            flashView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: duration / 2, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }

    /// Apply pulse effect on gradient
    func applyGradientPulseEffect() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.7
        animation.duration = 0.15
        animation.autoreverses = true
        gradientLayer.add(animation, forKey: "pulseAnimation")
    }

    // MARK: - Theme Updates

    /// Update backdrop image
    func updateBackdropImage(_ imageName: String?) {
        if let name = imageName, let image = UIImage(named: name) {
            backdropImageView.image = image
            backdropImageView.backgroundColor = nil
        } else {
            backdropImageView.image = nil
            backdropImageView.backgroundColor = sceneConfiguration.fallbackColor
        }
    }

    /// Update gradient colors
    func updateGradientColors(_ colors: [UIColor], animated: Bool = true) {
        let cgColors = colors.map { $0.cgColor }

        if animated {
            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = gradientLayer.colors
            animation.toValue = cgColors
            animation.duration = 0.3
            gradientLayer.add(animation, forKey: "colorChange")
        }

        gradientLayer.colors = cgColors
    }

    // MARK: - Accessors

    /// Get backdrop image view for custom configuration
    var backdropView: UIImageView {
        return backdropImageView
    }

    /// Get gradient overlay view
    var overlayView: UIView {
        return gradientOverlayView
    }
}

// MARK: - Particle Effect Renderer

/// Renderer for particle/emitter effects in background
final class ParticleEffectRenderer {

    // MARK: - Type Definitions

    /// Particle effect configuration
    struct ParticleEffectConfiguration {
        let birthRate: Float
        let lifetime: Float
        let velocity: CGFloat
        let velocityRange: CGFloat
        let emissionLongitude: CGFloat
        let emissionRange: CGFloat
        let scale: CGFloat
        let scaleRange: CGFloat
        let alphaSpeed: Float
        let color: UIColor

        static let floatingParticles = ParticleEffectConfiguration(
            birthRate: 2,
            lifetime: 6,
            velocity: -40,
            velocityRange: 20,
            emissionLongitude: -.pi / 2,
            emissionRange: .pi / 6,
            scale: 0.08,
            scaleRange: 0.04,
            alphaSpeed: -0.15,
            color: UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.5)
        )
    }

    // MARK: - Properties

    /// Emitter layer reference
    private let emitterLayer: CAEmitterLayer

    /// Emitter cell reference
    private let emitterCell: CAEmitterCell

    /// Configuration parameters
    private let effectConfiguration: ParticleEffectConfiguration

    /// Whether effect is active
    private(set) var isEffectActive: Bool = false

    // MARK: - Initialization

    init(configuration: ParticleEffectConfiguration = .floatingParticles) {
        self.effectConfiguration = configuration
        self.emitterLayer = CAEmitterLayer()
        self.emitterCell = CAEmitterCell()

        configureEmitter()
    }

    // MARK: - Configuration

    /// Configure emitter layer and cell
    private func configureEmitter() {
        emitterLayer.emitterShape = .line
        emitterLayer.renderMode = .additive

        emitterCell.birthRate = effectConfiguration.birthRate
        emitterCell.lifetime = effectConfiguration.lifetime
        emitterCell.velocity = effectConfiguration.velocity
        emitterCell.velocityRange = effectConfiguration.velocityRange
        emitterCell.emissionLongitude = effectConfiguration.emissionLongitude
        emitterCell.emissionRange = effectConfiguration.emissionRange
        emitterCell.scale = effectConfiguration.scale
        emitterCell.scaleRange = effectConfiguration.scaleRange
        emitterCell.alphaSpeed = effectConfiguration.alphaSpeed
        emitterCell.color = effectConfiguration.color.cgColor
        emitterCell.contents = generateParticleImage()?.cgImage

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

    /// Install particle effect into parent layer
    func installInParentLayer(_ parentLayer: CALayer, screenBounds: CGRect) {
        emitterLayer.emitterPosition = CGPoint(x: screenBounds.width / 2, y: screenBounds.height + 50)
        emitterLayer.emitterSize = CGSize(width: screenBounds.width, height: 1)

        parentLayer.addSublayer(emitterLayer)
        isEffectActive = true
    }

    /// Update emitter position and size
    func updateEmitterBounds(_ bounds: CGRect) {
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height + 50)
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: 1)
    }

    // MARK: - Effect Control

    /// Start particle emission
    func startEmission() {
        emitterCell.birthRate = effectConfiguration.birthRate
        isEffectActive = true
    }

    /// Stop particle emission
    func stopEmission() {
        emitterCell.birthRate = 0
        isEffectActive = false
    }

    /// Pause particle emission
    func pauseEmission() {
        let pausedTime = emitterLayer.convertTime(CACurrentMediaTime(), from: nil)
        emitterLayer.speed = 0.0
        emitterLayer.timeOffset = pausedTime
    }

    /// Resume particle emission
    func resumeEmission() {
        let pausedTime = emitterLayer.timeOffset
        emitterLayer.speed = 1.0
        emitterLayer.timeOffset = 0.0
        emitterLayer.beginTime = 0.0
        let timeSincePause = emitterLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        emitterLayer.beginTime = timeSincePause
    }

    /// Remove emitter from parent
    func removeFromParent() {
        emitterLayer.removeFromSuperlayer()
        isEffectActive = false
    }

    // MARK: - Accessors

    /// Get emitter layer for custom configuration
    var layer: CAEmitterLayer {
        return emitterLayer
    }
}

// MARK: - Floating Decorative Elements Manager

/// Manager for floating decorative tile elements
final class FloatingDecorativeElementsManager {

    // MARK: - Properties

    /// Collection of floating element views
    private var floatingElements: [UIImageView] = []

    /// Parent container reference
    private weak var parentContainerView: UIView?

    /// Number of floating elements
    private let elementCount: Int

    /// Element size configuration
    private let elementSize: CGSize

    /// Element opacity
    private let elementOpacity: CGFloat

    // MARK: - Initialization

    init(elementCount: Int = 4, elementSize: CGSize = CGSize(width: 35, height: 50), opacity: CGFloat = 0.1) {
        self.elementCount = elementCount
        self.elementSize = elementSize
        self.elementOpacity = opacity
    }

    // MARK: - Installation

    /// Install floating elements into parent view
    func installInParentView(_ parentView: UIView, insertAbove referenceView: UIView? = nil) {
        self.parentContainerView = parentView

        for _ in 0..<elementCount {
            let elementView = createFloatingElement()

            if let reference = referenceView {
                parentView.insertSubview(elementView, aboveSubview: reference)
            } else {
                parentView.addSubview(elementView)
            }

            floatingElements.append(elementView)
            startFloatingAnimation(for: elementView)
        }
    }

    /// Create single floating element
    private func createFloatingElement() -> UIImageView {
        let elementView = UIImageView()
        let imageName = "be \(Int.random(in: 0...26))"
        elementView.image = UIImage(named: imageName)
        elementView.contentMode = .scaleAspectFit
        elementView.alpha = elementOpacity

        let screenBounds = UIScreen.main.bounds
        elementView.frame = CGRect(
            x: CGFloat.random(in: 0...screenBounds.width),
            y: CGFloat.random(in: 0...screenBounds.height),
            width: elementSize.width,
            height: elementSize.height
        )

        return elementView
    }

    // MARK: - Animation

    /// Start floating animation for element
    private func startFloatingAnimation(for element: UIImageView) {
        let randomDuration = Double.random(in: 3...5)
        let randomXOffset = CGFloat.random(in: -20...20)
        let randomYOffset = CGFloat.random(in: -30...30)

        UIView.animate(
            withDuration: randomDuration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            element.center = CGPoint(
                x: element.center.x + randomXOffset,
                y: element.center.y + randomYOffset
            )
            element.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.2...0.2))
        } completion: { [weak self] _ in
            self?.startFloatingAnimation(for: element)
        }
    }

    /// Pause all floating animations
    func pauseAllAnimations() {
        for element in floatingElements {
            element.layer.pauseAnimations()
        }
    }

    /// Resume all floating animations
    func resumeAllAnimations() {
        for element in floatingElements {
            element.layer.resumeAnimations()
        }
    }

    /// Remove all floating elements
    func removeAllElements() {
        for element in floatingElements {
            element.removeFromSuperview()
        }
        floatingElements.removeAll()
    }

    // MARK: - Accessors

    /// Get all floating element views
    var elements: [UIImageView] {
        return floatingElements
    }
}

// MARK: - CALayer Animation Extensions

private extension CALayer {
    func pauseAnimations() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func resumeAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
