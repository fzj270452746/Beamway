//
//  PauseOverlayController.swift
//  Beamway
//
//  Controls the pause overlay display during gameplay
//

import UIKit

/// Controller for pause overlay presentation
final class PauseOverlayController {

    // MARK: - Constants

    private struct OverlayConstants {
        static let overlayTag: Int = 999
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Properties

    private weak var parentView: UIView?
    private var overlayView: UIView?

    // MARK: - Initialization

    init(parentView: UIView) {
        self.parentView = parentView
    }

    // MARK: - Presentation

    func show() {
        guard let view = parentView else { return }

        let pauseOverlay = UIView()
        pauseOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        pauseOverlay.tag = OverlayConstants.overlayTag
        view.addSubview(pauseOverlay)
        pauseOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pauseOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            pauseOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pauseOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pauseOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Pause text
        let pauseLabel = UILabel()
        pauseLabel.text = "PAUSED"
        pauseLabel.textColor = .white
        pauseLabel.font = UIFont.systemFont(ofSize: 48, weight: .black)
        pauseLabel.textAlignment = .center

        // Add glow effect
        pauseLabel.layer.shadowColor = UIColor.white.cgColor
        pauseLabel.layer.shadowOffset = .zero
        pauseLabel.layer.shadowRadius = 15
        pauseLabel.layer.shadowOpacity = 0.5

        pauseOverlay.addSubview(pauseLabel)
        pauseLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pauseLabel.centerXAnchor.constraint(equalTo: pauseOverlay.centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: pauseOverlay.centerYAnchor)
        ])

        // Instructions text
        let tapLabel = UILabel()
        tapLabel.text = "Tap pause button to resume"
        tapLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        tapLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tapLabel.textAlignment = .center
        pauseOverlay.addSubview(tapLabel)
        tapLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tapLabel.centerXAnchor.constraint(equalTo: pauseOverlay.centerXAnchor),
            tapLabel.topAnchor.constraint(equalTo: pauseLabel.bottomAnchor, constant: 20)
        ])

        // Add decorative elements
        addDecorativeElements(to: pauseOverlay)

        // Animate in
        pauseOverlay.alpha = 0
        UIView.animate(withDuration: OverlayConstants.animationDuration) {
            pauseOverlay.alpha = 1
        }

        self.overlayView = pauseOverlay
    }

    private func addDecorativeElements(to overlay: UIView) {
        // Add subtle animated border
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.3).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [10, 5]

        let borderPath = UIBezierPath(
            roundedRect: overlay.bounds.insetBy(dx: 30, dy: 100),
            cornerRadius: 20
        )
        borderLayer.path = borderPath.cgPath
        overlay.layer.addSublayer(borderLayer)

        // Animate dash pattern
        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0
        dashAnimation.toValue = 30
        dashAnimation.duration = 2.0
        dashAnimation.repeatCount = .infinity
        borderLayer.add(dashAnimation, forKey: "dashAnimation")
    }

    // MARK: - Dismissal

    func dismiss() {
        guard let view = parentView,
              let pauseOverlay = view.viewWithTag(OverlayConstants.overlayTag) else { return }

        UIView.animate(withDuration: OverlayConstants.animationDuration, animations: {
            pauseOverlay.alpha = 0
        }) { _ in
            pauseOverlay.removeFromSuperview()
        }

        self.overlayView = nil
    }

    // MARK: - State

    var isVisible: Bool {
        return overlayView != nil
    }
}
