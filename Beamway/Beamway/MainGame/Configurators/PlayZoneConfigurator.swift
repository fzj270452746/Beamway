//
//  PlayZoneConfigurator.swift
//  Beamway
//
//  Configures the play zone area where game elements are displayed
//

import UIKit

/// Configurator for play zone setup
final class PlayZoneConfigurator {

    // MARK: - Constants

    private struct PlayZoneConstants {
        static let cornerRadius: CGFloat = 20
        static let borderLineWidth: CGFloat = 2
        static let shadowRadius: CGFloat = 15
        static let shadowOpacity: Float = 0.3
        static let topSpacing: CGFloat = 120
        static let bottomSpacing: CGFloat = 90
        static let sideSpacing: CGFloat = 15
        static let dashPattern: [NSNumber] = [8, 4]
    }

    // MARK: - Properties

    private let playZonePanel: UIView
    private let playZoneBorderStratum: CAShapeLayer

    // MARK: - Initialization

    init(playZonePanel: UIView, playZoneBorderStratum: CAShapeLayer) {
        self.playZonePanel = playZonePanel
        self.playZoneBorderStratum = playZoneBorderStratum
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configurePlayZoneAppearance()
        configurePlayZoneBorder()
        configurePlayZoneGlow()
        addPlayZoneToView(parentView)
    }

    private func configurePlayZoneAppearance() {
        playZonePanel.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        playZonePanel.clipsToBounds = true
        playZonePanel.layer.cornerRadius = PlayZoneConstants.cornerRadius
    }

    private func configurePlayZoneBorder() {
        playZoneBorderStratum.strokeColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.5).cgColor
        playZoneBorderStratum.fillColor = UIColor.clear.cgColor
        playZoneBorderStratum.lineWidth = PlayZoneConstants.borderLineWidth
        playZoneBorderStratum.lineDashPattern = PlayZoneConstants.dashPattern
        playZonePanel.layer.addSublayer(playZoneBorderStratum)
    }

    private func configurePlayZoneGlow() {
        playZonePanel.layer.shadowColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0).cgColor
        playZonePanel.layer.shadowOffset = .zero
        playZonePanel.layer.shadowRadius = PlayZoneConstants.shadowRadius
        playZonePanel.layer.shadowOpacity = PlayZoneConstants.shadowOpacity
    }

    private func addPlayZoneToView(_ parentView: UIView) {
        parentView.addSubview(playZonePanel)
        playZonePanel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playZonePanel.topAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.topAnchor,
                constant: PlayZoneConstants.topSpacing
            ),
            playZonePanel.leadingAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.leadingAnchor,
                constant: PlayZoneConstants.sideSpacing
            ),
            playZonePanel.trailingAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -PlayZoneConstants.sideSpacing
            ),
            playZonePanel.bottomAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -PlayZoneConstants.bottomSpacing
            )
        ])
    }
}

/// Border animation controller for play zone
final class PlayZoneBorderAnimator {

    // MARK: - Constants

    private struct AnimationConstants {
        static let dashAnimationKey = "dashAnimation"
        static let glowAnimationKey = "glowAnimation"
        static let dashFromValue: CGFloat = 0
        static let dashToValue: CGFloat = 24
        static let dashDuration: TimeInterval = 1.5
    }

    // MARK: - Properties

    private weak var borderLayer: CAShapeLayer?
    private weak var playZoneLayer: CALayer?

    // MARK: - Initialization

    init(borderLayer: CAShapeLayer, playZoneLayer: CALayer) {
        self.borderLayer = borderLayer
        self.playZoneLayer = playZoneLayer
    }

    // MARK: - Animation Control

    func startDashAnimation() {
        guard let layer = borderLayer else { return }

        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = AnimationConstants.dashFromValue
        animation.toValue = AnimationConstants.dashToValue
        animation.duration = AnimationConstants.dashDuration
        animation.repeatCount = .infinity
        layer.add(animation, forKey: AnimationConstants.dashAnimationKey)
    }

    func stopDashAnimation() {
        borderLayer?.removeAnimation(forKey: AnimationConstants.dashAnimationKey)
    }

    func pulseGlow(duration: TimeInterval = 0.5) {
        guard let layer = playZoneLayer else { return }

        let currentOpacity = layer.shadowOpacity

        let animation = CAKeyframeAnimation(keyPath: "shadowOpacity")
        animation.values = [currentOpacity, 0.6, currentOpacity]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = duration
        layer.add(animation, forKey: AnimationConstants.glowAnimationKey)
    }

    func updateBorderPath(for bounds: CGRect) {
        guard let layer = borderLayer else { return }

        let borderPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 20
        )
        layer.path = borderPath.cgPath
        layer.frame = bounds
    }
}

/// Factory for creating different play zone styles
final class PlayZoneStyleFactory {

    // MARK: - Style Types

    enum PlayZoneStyle {
        case standard
        case intense
        case calm
        case challenge

        var borderColor: UIColor {
            switch self {
            case .standard:
                return UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.5)
            case .intense:
                return UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.5)
            case .calm:
                return UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.5)
            case .challenge:
                return UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.5)
            }
        }

        var glowColor: UIColor {
            switch self {
            case .standard:
                return UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
            case .intense:
                return UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
            case .calm:
                return UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
            case .challenge:
                return UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
            }
        }

        var backgroundColor: UIColor {
            return UIColor.white.withAlphaComponent(0.03)
        }
    }

    // MARK: - Factory Methods

    static func applyStyle(_ style: PlayZoneStyle, to playZone: UIView, borderLayer: CAShapeLayer) {
        playZone.backgroundColor = style.backgroundColor
        borderLayer.strokeColor = style.borderColor.cgColor
        playZone.layer.shadowColor = style.glowColor.cgColor
    }

    static func transitionStyle(
        from oldStyle: PlayZoneStyle,
        to newStyle: PlayZoneStyle,
        playZone: UIView,
        borderLayer: CAShapeLayer,
        duration: TimeInterval = 0.5
    ) {
        UIView.animate(withDuration: duration) {
            playZone.backgroundColor = newStyle.backgroundColor
        }

        let borderAnimation = CABasicAnimation(keyPath: "strokeColor")
        borderAnimation.fromValue = oldStyle.borderColor.cgColor
        borderAnimation.toValue = newStyle.borderColor.cgColor
        borderAnimation.duration = duration
        borderLayer.strokeColor = newStyle.borderColor.cgColor
        borderLayer.add(borderAnimation, forKey: "borderColorTransition")

        let glowAnimation = CABasicAnimation(keyPath: "shadowColor")
        glowAnimation.fromValue = oldStyle.glowColor.cgColor
        glowAnimation.toValue = newStyle.glowColor.cgColor
        glowAnimation.duration = duration
        playZone.layer.shadowColor = newStyle.glowColor.cgColor
        playZone.layer.add(glowAnimation, forKey: "glowColorTransition")
    }
}
