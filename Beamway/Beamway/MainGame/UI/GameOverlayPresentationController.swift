//
//  GameOverlayPresentationController.swift
//  Beamway
//
//  Overlay presentation management for game UI
//

import UIKit

/// Controller managing game overlay presentations (pause, game over, level up)
final class GameOverlayPresentationController {

    // MARK: - Type Definitions

    /// Overlay type enumeration
    enum OverlayType: Hashable {
        case pause
        case gameOver
        case levelUp
        case countdown
        case custom(tag: Int)

        var overlayTag: Int {
            switch self {
            case .pause:
                return 999
            case .gameOver:
                return 998
            case .levelUp:
                return 997
            case .countdown:
                return 996
            case .custom(let tag):
                return tag
            }
        }
    }

    /// Overlay animation configuration
    struct OverlayAnimationConfiguration {
        let fadeInDuration: TimeInterval
        let fadeOutDuration: TimeInterval
        let scaleAnimationDuration: TimeInterval
        let springDamping: CGFloat
        let initialVelocity: CGFloat

        static let standard = OverlayAnimationConfiguration(
            fadeInDuration: 0.3,
            fadeOutDuration: 0.2,
            scaleAnimationDuration: 0.4,
            springDamping: 0.7,
            initialVelocity: 0.5
        )
    }

    // MARK: - Properties

    /// Parent container view for overlays
    private weak var parentContainerView: UIView?

    /// Animation configuration
    private let animationConfiguration: OverlayAnimationConfiguration

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    /// Currently active overlays
    private var activeOverlays: [OverlayType: UIView] = [:]

    /// Button action callbacks
    var onPlayAgainTapped: (() -> Void)?
    var onMainMenuTapped: (() -> Void)?
    var onResumeTapped: (() -> Void)?

    // MARK: - Initialization

    init(configuration: OverlayAnimationConfiguration = .standard) {
        self.animationConfiguration = configuration
        self.visualTheme = VisualThemeConfiguration.shared
    }

    // MARK: - Configuration

    /// Configure with parent container view
    func configureWithContainer(_ containerView: UIView) {
        self.parentContainerView = containerView
    }

    // MARK: - Pause Overlay

    /// Present pause overlay
    func presentPauseOverlay() {
        guard let container = parentContainerView else { return }

        let pauseOverlay = createOverlayBackdrop(alpha: 0.7)
        pauseOverlay.tag = OverlayType.pause.overlayTag

        let pauseLabel = createTitleLabel(text: "PAUSED", fontSize: 48)
        pauseOverlay.addSubview(pauseLabel)

        let instructionLabel = createSubtitleLabel(text: "Tap pause button to resume")
        pauseOverlay.addSubview(instructionLabel)

        container.addSubview(pauseOverlay)
        configureOverlayConstraints(pauseOverlay, in: container)

        NSLayoutConstraint.activate([
            pauseLabel.centerXAnchor.constraint(equalTo: pauseOverlay.centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: pauseOverlay.centerYAnchor),

            instructionLabel.centerXAnchor.constraint(equalTo: pauseOverlay.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: pauseLabel.bottomAnchor, constant: 20)
        ])

        animateOverlayIn(pauseOverlay)
        activeOverlays[.pause] = pauseOverlay
    }

    /// Dismiss pause overlay
    func dismissPauseOverlay(completion: (() -> Void)? = nil) {
        dismissOverlay(type: .pause, completion: completion)
    }

    // MARK: - Game Over Overlay

    /// Present game over overlay with session result
    func presentGameOverOverlay(result: SessionResultDataModel) {
        guard let container = parentContainerView else { return }

        let overlayView = createOverlayBackdrop(alpha: 0.85)
        overlayView.tag = OverlayType.gameOver.overlayTag

        let containerCard = createGameOverContainerCard()
        overlayView.addSubview(containerCard)

        let gameOverLabel = createTitleLabel(text: "GAME OVER", fontSize: 36)
        containerCard.addSubview(gameOverLabel)

        let scoreLabel = createScoreLabel(score: result.sessionScoreValue)
        containerCard.addSubview(scoreLabel)

        let modeLabel = createModeLabel(category: result.playedGameCategory)
        containerCard.addSubview(modeLabel)

        let statsStack = createStatsStackView(result: result)
        containerCard.addSubview(statsStack)

        let playAgainButton = createPrimaryActionButton(title: "PLAY AGAIN")
        playAgainButton.addTarget(self, action: #selector(playAgainButtonTapped), for: .touchUpInside)
        containerCard.addSubview(playAgainButton)

        let menuButton = createSecondaryActionButton(title: "MAIN MENU")
        menuButton.addTarget(self, action: #selector(mainMenuButtonTapped), for: .touchUpInside)
        containerCard.addSubview(menuButton)

        container.addSubview(overlayView)
        configureOverlayConstraints(overlayView, in: container)

        NSLayoutConstraint.activate([
            containerCard.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            containerCard.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            containerCard.widthAnchor.constraint(equalToConstant: 300),

            gameOverLabel.topAnchor.constraint(equalTo: containerCard.topAnchor, constant: 30),
            gameOverLabel.centerXAnchor.constraint(equalTo: containerCard.centerXAnchor),

            scoreLabel.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: containerCard.centerXAnchor),

            modeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            modeLabel.centerXAnchor.constraint(equalTo: containerCard.centerXAnchor),

            statsStack.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 20),
            statsStack.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: 30),
            statsStack.trailingAnchor.constraint(equalTo: containerCard.trailingAnchor, constant: -30),

            playAgainButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 25),
            playAgainButton.centerXAnchor.constraint(equalTo: containerCard.centerXAnchor),
            playAgainButton.widthAnchor.constraint(equalToConstant: 200),
            playAgainButton.heightAnchor.constraint(equalToConstant: 50),

            menuButton.topAnchor.constraint(equalTo: playAgainButton.bottomAnchor, constant: 12),
            menuButton.centerXAnchor.constraint(equalTo: containerCard.centerXAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 200),
            menuButton.heightAnchor.constraint(equalToConstant: 50),
            menuButton.bottomAnchor.constraint(equalTo: containerCard.bottomAnchor, constant: -25)
        ])

        animateGameOverIn(overlayView, containerCard: containerCard)
        activeOverlays[.gameOver] = overlayView
    }

    /// Dismiss game over overlay
    func dismissGameOverOverlay(completion: (() -> Void)? = nil) {
        dismissOverlay(type: .gameOver, completion: completion)
    }

    // MARK: - Level Up Overlay

    /// Present level up notification
    func presentLevelUpNotification(level: Int) {
        guard let container = parentContainerView else { return }

        let levelUpLabel = UILabel()
        levelUpLabel.text = "LEVEL UP!"
        levelUpLabel.textColor = visualTheme.colorPalette.tertiaryPurpleAccent
        levelUpLabel.font = UIFont.systemFont(ofSize: 36, weight: .black)
        levelUpLabel.textAlignment = .center
        levelUpLabel.alpha = 0
        levelUpLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        levelUpLabel.tag = OverlayType.levelUp.overlayTag

        container.addSubview(levelUpLabel)
        levelUpLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            levelUpLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            levelUpLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            levelUpLabel.alpha = 1
            levelUpLabel.transform = .identity
        } completion: { _ in
            UIView.animate(
                withDuration: 0.3,
                delay: 0.8,
                options: .curveEaseOut
            ) {
                levelUpLabel.alpha = 0
                levelUpLabel.transform = CGAffineTransform(translationX: 0, y: -50)
            } completion: { _ in
                levelUpLabel.removeFromSuperview()
            }
        }

        activeOverlays[.levelUp] = levelUpLabel
    }

    // MARK: - Damage Flash Overlay

    /// Present damage flash effect
    func presentDamageFlash(belowView: UIView? = nil) {
        guard let container = parentContainerView else { return }

        let damageView = UIView()
        damageView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        damageView.frame = container.bounds
        damageView.alpha = 0

        if let referenceView = belowView {
            container.insertSubview(damageView, belowSubview: referenceView)
        } else {
            container.addSubview(damageView)
        }

        UIView.animate(withDuration: 0.1, animations: {
            damageView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                damageView.alpha = 0
            }) { _ in
                damageView.removeFromSuperview()
            }
        }
    }

    // MARK: - View Factory Methods

    /// Create overlay backdrop view
    private func createOverlayBackdrop(alpha: CGFloat) -> UIView {
        let backdrop = UIView()
        backdrop.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        backdrop.alpha = 0
        return backdrop
    }

    /// Create title label
    private func createTitleLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Create subtitle label
    private func createSubtitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Create score label
    private func createScoreLabel(score: Int) -> UILabel {
        let label = UILabel()
        label.text = "Score: \(score)"
        label.textColor = visualTheme.colorPalette.goldHighlightTint
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Create mode label
    private func createModeLabel(category: GameCategoryDescriptor) -> UILabel {
        let label = UILabel()
        label.text = category.displayName
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Create game over container card
    private func createGameOverContainerCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        card.layer.cornerRadius = 25
        card.layer.borderWidth = 2
        card.layer.borderColor = visualTheme.colorPalette.primaryNeonCyan.withAlphaComponent(0.5).cgColor
        card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        card.alpha = 0
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    /// Create stats stack view
    private func createStatsStackView(result: SessionResultDataModel) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        let timeLabel = createStatItem(
            icon: "clock.fill",
            value: result.formattedSessionDuration,
            color: visualTheme.colorPalette.primaryNeonCyan
        )

        let comboLabel = createStatItem(
            icon: "flame.fill",
            value: "x\(result.sessionPeakCombo)",
            color: visualTheme.colorPalette.secondaryOrangeAccent
        )

        stack.addArrangedSubview(timeLabel)
        stack.addArrangedSubview(comboLabel)

        return stack
    }

    /// Create individual stat item view
    private func createStatItem(icon: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            valueLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            container.heightAnchor.constraint(equalToConstant: 30)
        ])

        return container
    }

    /// Create primary action button
    private func createPrimaryActionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = visualTheme.colorPalette.primaryNeonCyan
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    /// Create secondary action button
    private func createSecondaryActionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    // MARK: - Layout Helpers

    /// Configure overlay full-screen constraints
    private func configureOverlayConstraints(_ overlay: UIView, in container: UIView) {
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: container.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: - Animation Methods

    /// Animate overlay fade in
    private func animateOverlayIn(_ overlay: UIView) {
        UIView.animate(withDuration: animationConfiguration.fadeInDuration) {
            overlay.alpha = 1
        }
    }

    /// Animate game over overlay entrance
    private func animateGameOverIn(_ overlay: UIView, containerCard: UIView) {
        UIView.animate(withDuration: animationConfiguration.fadeInDuration) {
            overlay.alpha = 1
        }

        UIView.animate(
            withDuration: animationConfiguration.scaleAnimationDuration,
            delay: 0.1,
            usingSpringWithDamping: animationConfiguration.springDamping,
            initialSpringVelocity: animationConfiguration.initialVelocity
        ) {
            containerCard.alpha = 1
            containerCard.transform = .identity
        }
    }

    /// Dismiss overlay with animation
    private func dismissOverlay(type: OverlayType, completion: (() -> Void)?) {
        guard let overlay = activeOverlays[type] else {
            completion?()
            return
        }

        UIView.animate(
            withDuration: animationConfiguration.fadeOutDuration,
            animations: {
                overlay.alpha = 0
            }
        ) { _ in
            overlay.removeFromSuperview()
            self.activeOverlays[type] = nil
            completion?()
        }
    }

    // MARK: - Button Actions

    @objc private func playAgainButtonTapped() {
        onPlayAgainTapped?()
    }

    @objc private func mainMenuButtonTapped() {
        onMainMenuTapped?()
    }

    @objc private func resumeButtonTapped() {
        onResumeTapped?()
    }

    // MARK: - Utility Methods

    /// Check if specific overlay is currently presented
    func isOverlayPresented(_ type: OverlayType) -> Bool {
        return activeOverlays[type] != nil
    }

    /// Dismiss all active overlays
    func dismissAllOverlays() {
        for (type, _) in activeOverlays {
            dismissOverlay(type: type, completion: nil)
        }
    }
}
