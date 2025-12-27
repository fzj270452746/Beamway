//
//  GameOverPresentationController.swift
//  Beamway
//
//  Controls the presentation and interaction of the game over screen
//

import UIKit

/// Controller for game over screen presentation
final class GameOverPresentationController {

    // MARK: - Constants

    private struct LayoutConstants {
        static let containerWidth: CGFloat = 300
        static let containerHeight: CGFloat = 320
        static let containerCornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 200
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 25
    }

    // MARK: - Properties

    private weak var parentView: UIView?
    private var overlayView: UIView?
    private var containerView: UIView?

    private var onPlayAgainCallback: (() -> Void)?
    private var onMainMenuCallback: (() -> Void)?

    // MARK: - Initialization

    init(parentView: UIView) {
        self.parentView = parentView
    }

    // MARK: - Presentation

    func present(
        score: Int,
        mode: String,
        onPlayAgain: @escaping () -> Void,
        onMainMenu: @escaping () -> Void
    ) {
        guard let view = parentView else { return }

        self.onPlayAgainCallback = onPlayAgain
        self.onMainMenuCallback = onMainMenu

        // Create overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay.alpha = 0
        view.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.overlayView = overlay

        // Create container
        let container = createContainer()
        overlay.addSubview(container)
        self.containerView = container

        // Add content
        let gameOverLabel = createGameOverLabel()
        container.addSubview(gameOverLabel)

        let scoreLabel = createScoreLabel(score: score)
        container.addSubview(scoreLabel)

        let modeLabel = createModeLabel(mode: mode)
        container.addSubview(modeLabel)

        let playAgainButton = createPlayAgainButton()
        container.addSubview(playAgainButton)

        let menuButton = createMenuButton()
        container.addSubview(menuButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: LayoutConstants.containerWidth),
            container.heightAnchor.constraint(equalToConstant: LayoutConstants.containerHeight),

            gameOverLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            gameOverLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            scoreLabel.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            modeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            modeLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            playAgainButton.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 30),
            playAgainButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playAgainButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonWidth),
            playAgainButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight),

            menuButton.topAnchor.constraint(equalTo: playAgainButton.bottomAnchor, constant: 12),
            menuButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonWidth),
            menuButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight)
        ])

        // Animate in
        animatePresentation()
    }

    private func createContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = LayoutConstants.containerCornerRadius
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.5).cgColor
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        container.alpha = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    private func createGameOverLabel() -> UILabel {
        let label = UILabel()
        label.text = "GAME OVER"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 36, weight: .black)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createScoreLabel(score: Int) -> UILabel {
        let label = UILabel()
        label.text = "Score: \(score)"
        label.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createModeLabel(mode: String) -> UILabel {
        let label = UILabel()
        label.text = mode
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createPlayAgainButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("PLAY AGAIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
        button.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        button.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createMenuButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("MAIN MENU", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func animatePresentation() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView?.alpha = 1
        }

        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.containerView?.alpha = 1
            self.containerView?.transform = .identity
        }
    }

    // MARK: - Dismissal

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView?.alpha = 0
            self.containerView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView?.alpha = 0
        }) { _ in
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
            self.containerView = nil
        }
    }

    // MARK: - Actions

    @objc private func playAgainTapped() {
        onPlayAgainCallback?()
    }

    @objc private func menuTapped() {
        onMainMenuCallback?()
    }
}
