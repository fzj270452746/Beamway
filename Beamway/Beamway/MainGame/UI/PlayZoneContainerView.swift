//
//  PlayZoneContainerView.swift
//  Beamway
//
//  Play zone container view with visual styling
//

import UIKit

/// Container view representing the active play zone area
/// Handles visual styling, border animations, and glow effects
final class PlayZoneContainerView: UIView {

    // MARK: - Type Definitions

    /// Configuration for play zone visual appearance
    struct PlayZoneVisualConfiguration {
        let backgroundAlpha: CGFloat
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let borderColor: UIColor
        let dashPattern: [NSNumber]
        let glowColor: UIColor
        let glowRadius: CGFloat
        let glowOpacity: Float

        static let defaultConfiguration = PlayZoneVisualConfiguration(
            backgroundAlpha: 0.03,
            cornerRadius: 20,
            borderWidth: 2,
            borderColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.5),
            dashPattern: [8, 4],
            glowColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0),
            glowRadius: 15,
            glowOpacity: 0.3
        )
    }

    // MARK: - Properties

    /// Border shape layer for dashed outline
    private let borderShapeLayer: CAShapeLayer

    /// Visual configuration parameters
    private let visualConfiguration: PlayZoneVisualConfiguration

    /// Whether border animation is active
    private var isBorderAnimationActive: Bool = false

    /// Border animation key constant
    private let borderAnimationKey = "playZoneBorderDashAnimation"

    // MARK: - Initialization

    init(configuration: PlayZoneVisualConfiguration = .defaultConfiguration) {
        self.visualConfiguration = configuration
        self.borderShapeLayer = CAShapeLayer()

        super.init(frame: .zero)

        configurePlayZoneAppearance()
    }

    required init?(coder: NSCoder) {
        self.visualConfiguration = .defaultConfiguration
        self.borderShapeLayer = CAShapeLayer()

        super.init(coder: coder)

        configurePlayZoneAppearance()
    }

    // MARK: - Configuration

    /// Configure play zone visual appearance
    private func configurePlayZoneAppearance() {
        configureBackgroundStyle()
        configureBorderLayer()
        configureGlowEffect()
    }

    /// Configure background style
    private func configureBackgroundStyle() {
        backgroundColor = UIColor.white.withAlphaComponent(visualConfiguration.backgroundAlpha)
        clipsToBounds = true
        layer.cornerRadius = visualConfiguration.cornerRadius
    }

    /// Configure border shape layer
    private func configureBorderLayer() {
        borderShapeLayer.strokeColor = visualConfiguration.borderColor.cgColor
        borderShapeLayer.fillColor = UIColor.clear.cgColor
        borderShapeLayer.lineWidth = visualConfiguration.borderWidth
        borderShapeLayer.lineDashPattern = visualConfiguration.dashPattern

        layer.addSublayer(borderShapeLayer)
    }

    /// Configure glow effect
    private func configureGlowEffect() {
        layer.shadowColor = visualConfiguration.glowColor.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = visualConfiguration.glowRadius
        layer.shadowOpacity = visualConfiguration.glowOpacity
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        updateBorderPath()

        if !isBorderAnimationActive {
            startBorderAnimation()
        }
    }

    /// Update border path to match current bounds
    private func updateBorderPath() {
        let borderPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: visualConfiguration.cornerRadius
        )
        borderShapeLayer.path = borderPath.cgPath
        borderShapeLayer.frame = bounds
    }

    // MARK: - Border Animation

    /// Start animated dash pattern on border
    func startBorderAnimation() {
        guard !isBorderAnimationActive else { return }

        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0
        dashAnimation.toValue = 24
        dashAnimation.duration = 1.5
        dashAnimation.repeatCount = .infinity

        borderShapeLayer.add(dashAnimation, forKey: borderAnimationKey)
        isBorderAnimationActive = true
    }

    /// Stop border animation
    func stopBorderAnimation() {
        borderShapeLayer.removeAnimation(forKey: borderAnimationKey)
        isBorderAnimationActive = false
    }

    /// Pause border animation
    func pauseBorderAnimation() {
        let pausedTime = borderShapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        borderShapeLayer.speed = 0.0
        borderShapeLayer.timeOffset = pausedTime
    }

    /// Resume border animation
    func resumeBorderAnimation() {
        let pausedTime = borderShapeLayer.timeOffset
        borderShapeLayer.speed = 1.0
        borderShapeLayer.timeOffset = 0.0
        borderShapeLayer.beginTime = 0.0
        let timeSincePause = borderShapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        borderShapeLayer.beginTime = timeSincePause
    }

    // MARK: - Visual Effects

    /// Apply pulse glow effect
    func applyPulseGlowEffect(duration: TimeInterval = 0.3) {
        let originalOpacity = layer.shadowOpacity

        UIView.animate(withDuration: duration / 2, animations: {
            self.layer.shadowOpacity = min(originalOpacity * 2, 1.0)
            self.layer.shadowRadius = self.visualConfiguration.glowRadius * 1.5
        }) { _ in
            UIView.animate(withDuration: duration / 2) {
                self.layer.shadowOpacity = originalOpacity
                self.layer.shadowRadius = self.visualConfiguration.glowRadius
            }
        }
    }

    /// Apply warning flash effect
    func applyWarningFlashEffect() {
        let originalBorderColor = borderShapeLayer.strokeColor

        UIView.animate(withDuration: 0.1, animations: {
            self.borderShapeLayer.strokeColor = UIColor.systemRed.cgColor
            self.layer.shadowColor = UIColor.systemRed.cgColor
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.borderShapeLayer.strokeColor = originalBorderColor
                self.layer.shadowColor = self.visualConfiguration.glowColor.cgColor
            }
        }
    }

    /// Update border color with animation
    func updateBorderColor(_ color: UIColor, animated: Bool = true) {
        if animated {
            let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
            colorAnimation.fromValue = borderShapeLayer.strokeColor
            colorAnimation.toValue = color.cgColor
            colorAnimation.duration = 0.3
            borderShapeLayer.add(colorAnimation, forKey: "borderColorChange")
        }

        borderShapeLayer.strokeColor = color.cgColor
    }

    /// Update glow color with animation
    func updateGlowColor(_ color: UIColor, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layer.shadowColor = color.cgColor
            }
        } else {
            layer.shadowColor = color.cgColor
        }
    }

    // MARK: - Play Zone Accessors

    /// Get center point of play zone
    var playZoneCenter: CGPoint {
        return CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }

    /// Get safe bounds with padding
    func safeBoundsWithPadding(_ padding: CGFloat) -> CGRect {
        return bounds.insetBy(dx: padding, dy: padding)
    }

    /// Check if point is within play zone
    func isPointWithinPlayZone(_ point: CGPoint) -> Bool {
        return bounds.contains(point)
    }

    /// Constrain point to within play zone bounds
    func constrainPointToPlayZone(_ point: CGPoint, objectSize: CGSize) -> CGPoint {
        let halfWidth = objectSize.width / 2
        let halfHeight = objectSize.height / 2

        let constrainedX = max(halfWidth, min(bounds.width - halfWidth, point.x))
        let constrainedY = max(halfHeight, min(bounds.height - halfHeight, point.y))

        return CGPoint(x: constrainedX, y: constrainedY)
    }
}

// MARK: - Play Zone Delegate Protocol

/// Protocol for receiving play zone layout events
protocol PlayZoneLayoutDelegate: AnyObject {
    /// Called when play zone layout is complete
    func playZoneDidCompleteLayout(_ playZone: PlayZoneContainerView)

    /// Called when play zone bounds change
    func playZoneBoundsDidChange(_ playZone: PlayZoneContainerView, newBounds: CGRect)
}

// MARK: - Play Zone Layout Observer

/// Observer extension for monitoring layout changes
extension PlayZoneContainerView {

    /// Layout delegate reference (stored via associated object)
    weak var layoutDelegate: PlayZoneLayoutDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.layoutDelegate) as? PlayZoneLayoutDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.layoutDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    /// Associated object keys
    private struct AssociatedKeys {
        static var layoutDelegate = "playZoneLayoutDelegate"
    }

    /// Notify delegate of layout completion
    func notifyLayoutCompletion() {
        layoutDelegate?.playZoneDidCompleteLayout(self)
    }

    /// Notify delegate of bounds change
    func notifyBoundsChange() {
        layoutDelegate?.playZoneBoundsDidChange(self, newBounds: bounds)
    }
}
