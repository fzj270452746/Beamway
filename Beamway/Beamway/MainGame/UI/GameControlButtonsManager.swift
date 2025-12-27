//
//  GameControlButtonsManager.swift
//  Beamway
//
//  Control buttons management for game interface
//

import UIKit

/// Protocol for control button action callbacks
protocol GameControlButtonsDelegate: AnyObject {
    /// Called when exit button is tapped
    func controlButtonsManagerDidTapExit(_ manager: GameControlButtonsManager)

    /// Called when pause button is tapped
    func controlButtonsManagerDidTapPause(_ manager: GameControlButtonsManager)

    /// Called when pause state changes
    func controlButtonsManager(_ manager: GameControlButtonsManager, didChangePauseState isPaused: Bool)
}

/// Manager for game control buttons (exit, pause)
final class GameControlButtonsManager {

    // MARK: - Type Definitions

    /// Configuration for control button appearance
    struct ControlButtonConfiguration {
        let buttonSize: CGFloat
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let iconSize: CGFloat

        static let standard = ControlButtonConfiguration(
            buttonSize: 50,
            cornerRadius: 25,
            borderWidth: 1.5,
            iconSize: 24
        )
    }

    // MARK: - Properties

    /// Container view for control buttons
    private let controlsContainerView: UIView

    /// Exit button reference
    private let exitControlButton: UIButton

    /// Pause button reference
    private let pauseControlButton: UIButton

    /// Configuration parameters
    private let buttonConfiguration: ControlButtonConfiguration

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    /// Touch feedback controller
    private let touchFeedback: TouchFeedbackController

    /// Delegate reference
    weak var delegate: GameControlButtonsDelegate?

    /// Current pause state
    private(set) var isCurrentlyPaused: Bool = false

    // MARK: - Initialization

    init(configuration: ControlButtonConfiguration = .standard) {
        self.buttonConfiguration = configuration
        self.visualTheme = VisualThemeConfiguration.shared
        self.touchFeedback = TouchFeedbackController.shared

        self.controlsContainerView = UIView()
        self.exitControlButton = UIButton(type: .system)
        self.pauseControlButton = UIButton(type: .system)

        configureButtonAppearance()
    }

    // MARK: - Configuration

    /// Configure button visual appearance
    private func configureButtonAppearance() {
        configureExitButton()
        configurePauseButton()
        configureContainerView()
    }

    /// Configure exit button
    private func configureExitButton() {
        exitControlButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitControlButton.tintColor = .white
        exitControlButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        exitControlButton.layer.cornerRadius = buttonConfiguration.cornerRadius
        exitControlButton.layer.borderWidth = buttonConfiguration.borderWidth
        exitControlButton.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor

        exitControlButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        exitControlButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        exitControlButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    /// Configure pause button
    private func configurePauseButton() {
        pauseControlButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        pauseControlButton.tintColor = .white
        pauseControlButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        pauseControlButton.layer.cornerRadius = buttonConfiguration.cornerRadius
        pauseControlButton.layer.borderWidth = buttonConfiguration.borderWidth
        pauseControlButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        pauseControlButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        pauseControlButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        pauseControlButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    /// Configure container view
    private func configureContainerView() {
        controlsContainerView.backgroundColor = .clear
        controlsContainerView.addSubview(exitControlButton)
        controlsContainerView.addSubview(pauseControlButton)

        exitControlButton.translatesAutoresizingMaskIntoConstraints = false
        pauseControlButton.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - View Installation

    /// Install control buttons into parent view with constraints
    func installInParentView(_ parentView: UIView) {
        parentView.addSubview(controlsContainerView)
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controlsContainerView.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            controlsContainerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 25),
            controlsContainerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -25),
            controlsContainerView.heightAnchor.constraint(equalToConstant: 60),

            exitControlButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor),
            exitControlButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            exitControlButton.widthAnchor.constraint(equalToConstant: buttonConfiguration.buttonSize),
            exitControlButton.heightAnchor.constraint(equalToConstant: buttonConfiguration.buttonSize),

            pauseControlButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            pauseControlButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            pauseControlButton.widthAnchor.constraint(equalToConstant: buttonConfiguration.buttonSize),
            pauseControlButton.heightAnchor.constraint(equalToConstant: buttonConfiguration.buttonSize)
        ])
    }

    // MARK: - Button Actions

    @objc private func exitButtonTapped() {
        touchFeedback.generateButtonPressFeedback()
        animateButtonTap(exitControlButton)
        delegate?.controlButtonsManagerDidTapExit(self)
    }

    @objc private func pauseButtonTapped() {
        touchFeedback.generateButtonPressFeedback()
        animateButtonTap(pauseControlButton)
        togglePauseState()
        delegate?.controlButtonsManagerDidTapPause(self)
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    // MARK: - Pause State Management

    /// Toggle pause state
    private func togglePauseState() {
        isCurrentlyPaused.toggle()
        updatePauseButtonAppearance()
        delegate?.controlButtonsManager(self, didChangePauseState: isCurrentlyPaused)
    }

    /// Set pause state programmatically
    func setPauseState(_ isPaused: Bool) {
        guard isPaused != isCurrentlyPaused else { return }
        isCurrentlyPaused = isPaused
        updatePauseButtonAppearance()
    }

    /// Update pause button appearance based on state
    private func updatePauseButtonAppearance() {
        let iconName = isCurrentlyPaused ? "play.fill" : "pause.fill"
        pauseControlButton.setImage(UIImage(systemName: iconName), for: .normal)

        UIView.animate(withDuration: 0.2) {
            if self.isCurrentlyPaused {
                self.pauseControlButton.backgroundColor = self.visualTheme.colorPalette.primaryNeonCyan.withAlphaComponent(0.3)
                self.pauseControlButton.layer.borderColor = self.visualTheme.colorPalette.primaryNeonCyan.withAlphaComponent(0.5).cgColor
            } else {
                self.pauseControlButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
                self.pauseControlButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            }
        }
    }

    // MARK: - Animation

    /// Animate button tap effect
    private func animateButtonTap(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5
            ) {
                button.transform = .identity
            }
        }
    }

    // MARK: - Button State Management

    /// Enable or disable all control buttons
    func setControlsEnabled(_ enabled: Bool) {
        exitControlButton.isEnabled = enabled
        pauseControlButton.isEnabled = enabled

        UIView.animate(withDuration: 0.2) {
            self.exitControlButton.alpha = enabled ? 1.0 : 0.5
            self.pauseControlButton.alpha = enabled ? 1.0 : 0.5
        }
    }

    /// Hide or show control buttons
    func setControlsHidden(_ hidden: Bool, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.controlsContainerView.alpha = hidden ? 0 : 1
            }
        } else {
            controlsContainerView.alpha = hidden ? 0 : 1
        }
    }

    /// Set exit button enabled state
    func setExitButtonEnabled(_ enabled: Bool) {
        exitControlButton.isEnabled = enabled
        exitControlButton.alpha = enabled ? 1.0 : 0.5
    }

    /// Set pause button enabled state
    func setPauseButtonEnabled(_ enabled: Bool) {
        pauseControlButton.isEnabled = enabled
        pauseControlButton.alpha = enabled ? 1.0 : 0.5
    }

    // MARK: - Accessors

    /// Get container view for custom layout
    var containerView: UIView {
        return controlsContainerView
    }

    /// Get exit button for custom configuration
    var exitButton: UIButton {
        return exitControlButton
    }

    /// Get pause button for custom configuration
    var pauseButton: UIButton {
        return pauseControlButton
    }
}

// MARK: - Exit Confirmation Handler

/// Extension for handling exit confirmation dialog
extension GameControlButtonsManager {

    /// Present exit confirmation alert
    func presentExitConfirmation(
        from viewController: UIViewController,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Exit Game",
            message: "Are you sure you want to exit? Your progress will be saved.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            onCancel()
        })

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
            onConfirm()
        })

        viewController.present(alert, animated: true)
    }
}
