//
//  FooterControlsConfigurator.swift
//  Beamway
//
//  Configures the footer control buttons for game screens
//

import UIKit

/// Configurator for footer control buttons
final class FooterControlsConfigurator {

    // MARK: - Constants

    private struct ControlsConstants {
        static let containerHeight: CGFloat = 60
        static let horizontalPadding: CGFloat = 25
        static let bottomPadding: CGFloat = 15
        static let buttonSize: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 25
        static let borderWidth: CGFloat = 1.5
    }

    // MARK: - Properties

    private let footerControlsHolder: UIView
    private let exitAction: UIButton
    private let suspendAction: UIButton

    // MARK: - Initialization

    init(footerControlsHolder: UIView, exitAction: UIButton, suspendAction: UIButton) {
        self.footerControlsHolder = footerControlsHolder
        self.exitAction = exitAction
        self.suspendAction = suspendAction
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureContainer(in: parentView)
        configureExitButton()
        configureSuspendButton()
        setupConstraints()
    }

    private func configureContainer(in parentView: UIView) {
        footerControlsHolder.backgroundColor = .clear
        parentView.addSubview(footerControlsHolder)
        footerControlsHolder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            footerControlsHolder.bottomAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -ControlsConstants.bottomPadding
            ),
            footerControlsHolder.leadingAnchor.constraint(
                equalTo: parentView.leadingAnchor,
                constant: ControlsConstants.horizontalPadding
            ),
            footerControlsHolder.trailingAnchor.constraint(
                equalTo: parentView.trailingAnchor,
                constant: -ControlsConstants.horizontalPadding
            ),
            footerControlsHolder.heightAnchor.constraint(equalToConstant: ControlsConstants.containerHeight)
        ])
    }

    private func configureExitButton() {
        exitAction.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitAction.tintColor = .white
        exitAction.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        exitAction.layer.cornerRadius = ControlsConstants.buttonCornerRadius
        exitAction.layer.borderWidth = ControlsConstants.borderWidth
        exitAction.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
        footerControlsHolder.addSubview(exitAction)
        exitAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSuspendButton() {
        suspendAction.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        suspendAction.tintColor = .white
        suspendAction.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        suspendAction.layer.cornerRadius = ControlsConstants.buttonCornerRadius
        suspendAction.layer.borderWidth = ControlsConstants.borderWidth
        suspendAction.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        footerControlsHolder.addSubview(suspendAction)
        suspendAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            exitAction.leadingAnchor.constraint(equalTo: footerControlsHolder.leadingAnchor),
            exitAction.centerYAnchor.constraint(equalTo: footerControlsHolder.centerYAnchor),
            exitAction.widthAnchor.constraint(equalToConstant: ControlsConstants.buttonSize),
            exitAction.heightAnchor.constraint(equalToConstant: ControlsConstants.buttonSize),

            suspendAction.trailingAnchor.constraint(equalTo: footerControlsHolder.trailingAnchor),
            suspendAction.centerYAnchor.constraint(equalTo: footerControlsHolder.centerYAnchor),
            suspendAction.widthAnchor.constraint(equalToConstant: ControlsConstants.buttonSize),
            suspendAction.heightAnchor.constraint(equalToConstant: ControlsConstants.buttonSize)
        ])
    }
}

/// Factory for creating different control button styles
final class ControlButtonFactory {

    // MARK: - Button Styles

    enum ButtonStyle {
        case exit
        case pause
        case play
        case settings
        case back

        var iconName: String {
            switch self {
            case .exit:
                return "xmark"
            case .pause:
                return "pause.fill"
            case .play:
                return "play.fill"
            case .settings:
                return "gearshape.fill"
            case .back:
                return "chevron.left"
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .exit:
                return UIColor.systemRed.withAlphaComponent(0.3)
            case .pause, .play:
                return UIColor.white.withAlphaComponent(0.15)
            case .settings:
                return UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.3)
            case .back:
                return UIColor.white.withAlphaComponent(0.1)
            }
        }

        var borderColor: UIColor {
            switch self {
            case .exit:
                return UIColor.systemRed.withAlphaComponent(0.5)
            case .pause, .play:
                return UIColor.white.withAlphaComponent(0.3)
            case .settings:
                return UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.5)
            case .back:
                return UIColor.white.withAlphaComponent(0.2)
            }
        }
    }

    // MARK: - Factory Methods

    static func createButton(style: ButtonStyle, size: CGFloat = 50) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: style.iconName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = style.backgroundColor
        button.layer.cornerRadius = size / 2
        button.layer.borderWidth = 1.5
        button.layer.borderColor = style.borderColor.cgColor

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])

        return button
    }

    static func addPressAnimation(to button: UIButton) {
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private static func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private static func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
}

/// Controller for managing control button states
final class ControlButtonStateManager {

    // MARK: - Properties

    private weak var pauseButton: UIButton?
    private var isPaused: Bool = false

    // MARK: - Initialization

    init(pauseButton: UIButton) {
        self.pauseButton = pauseButton
    }

    // MARK: - State Management

    func togglePauseState() -> Bool {
        isPaused.toggle()
        updatePauseButtonAppearance()
        return isPaused
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        updatePauseButtonAppearance()
    }

    private func updatePauseButtonAppearance() {
        guard let button = pauseButton else { return }

        let iconName = isPaused ? "play.fill" : "pause.fill"
        button.setImage(UIImage(systemName: iconName), for: .normal)

        UIView.animate(withDuration: 0.2) {
            button.backgroundColor = self.isPaused
                ? UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.3)
                : UIColor.white.withAlphaComponent(0.15)
        }
    }

    func disableControls(_ disabled: Bool) {
        pauseButton?.isEnabled = !disabled
        pauseButton?.alpha = disabled ? 0.5 : 1.0
    }
}
