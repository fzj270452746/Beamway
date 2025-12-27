//
//  SessionHeadsUpDisplayManager.swift
//  Beamway
//
//  HUD management and display coordination for game sessions
//

import UIKit

/// Enumeration defining available HUD component types
enum HeadsUpDisplayComponentType {
    case scoreIndicator
    case healthIndicator
    case levelIndicator
    case chronometer
    case comboIndicator
}

/// Comprehensive manager for session HUD display elements
/// Handles all heads-up display rendering, updates, and animations
final class SessionHeadsUpDisplayManager {

    // MARK: - Type Definitions

    /// HUD update completion handler
    typealias HUDUpdateCompletionHandler = () -> Void

    /// HUD animation configuration
    struct HUDAnimationConfiguration {
        let updateDuration: TimeInterval
        let scalePulseFactor: CGFloat
        let fadeTransitionDuration: TimeInterval
        let springDampingRatio: CGFloat

        static let standard = HUDAnimationConfiguration(
            updateDuration: 0.15,
            scalePulseFactor: 1.2,
            fadeTransitionDuration: 0.3,
            springDampingRatio: 0.6
        )
    }

    // MARK: - Properties

    /// Parent container view for all HUD elements
    private weak var containerDisplayView: UIView?

    /// Score display component holder
    private let scoreComponentHolder: UIView

    /// Score icon display
    private let scoreIconDisplay: UIImageView

    /// Score value label
    private let scoreValueLabel: UILabel

    /// Score title label
    private let scoreTitleLabel: UILabel

    /// Health display component holder
    private let healthComponentHolder: UIView

    /// Health icon collection
    private var healthIconCollection: [UIImageView]

    /// Health icons stack
    private let healthIconsStack: UIStackView

    /// Level display component holder
    private let levelComponentHolder: UIView

    /// Level icon display
    private let levelIconDisplay: UIImageView

    /// Level value label
    private let levelValueLabel: UILabel

    /// Chronometer display component holder
    private let chronometerComponentHolder: UIView

    /// Chronometer icon display
    private let chronometerIconDisplay: UIImageView

    /// Chronometer value label
    private let chronometerValueLabel: UILabel

    /// Combo streak display holder
    private let comboStreakHolder: UIView

    /// Combo streak label
    private let comboStreakLabel: UILabel

    /// Current displayed score value
    private var displayedScoreValue: Int = 0

    /// Current displayed health value
    private var displayedHealthValue: Int = 3

    /// Maximum health capacity
    private let maximumHealthCapacity: Int = 3

    /// Current displayed level value
    private var displayedLevelValue: Int = 1

    /// Current displayed elapsed seconds
    private var displayedElapsedSeconds: TimeInterval = 0

    /// Current combo streak value
    private var currentComboStreakValue: Int = 0

    /// Peak combo streak achieved
    private var peakComboStreakValue: Int = 0

    /// Animation configuration
    private let animationConfiguration: HUDAnimationConfiguration

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    /// Component visibility states
    private var componentVisibilityStates: [HeadsUpDisplayComponentType: Bool] = [:]

    // MARK: - Initialization

    init(animationConfiguration: HUDAnimationConfiguration = .standard) {
        self.animationConfiguration = animationConfiguration
        self.visualTheme = VisualThemeConfiguration.shared

        // Initialize score component
        self.scoreComponentHolder = UIView()
        self.scoreIconDisplay = UIImageView()
        self.scoreValueLabel = UILabel()
        self.scoreTitleLabel = UILabel()

        // Initialize health component
        self.healthComponentHolder = UIView()
        self.healthIconCollection = []
        self.healthIconsStack = UIStackView()

        // Initialize level component
        self.levelComponentHolder = UIView()
        self.levelIconDisplay = UIImageView()
        self.levelValueLabel = UILabel()

        // Initialize chronometer component
        self.chronometerComponentHolder = UIView()
        self.chronometerIconDisplay = UIImageView()
        self.chronometerValueLabel = UILabel()

        // Initialize combo streak component
        self.comboStreakHolder = UIView()
        self.comboStreakLabel = UILabel()

        // Set default visibility states
        componentVisibilityStates = [
            .scoreIndicator: true,
            .healthIndicator: true,
            .levelIndicator: false,
            .chronometer: true,
            .comboIndicator: true
        ]
    }

    // MARK: - Configuration

    /// Configure HUD manager with container view and session parameters
    func configureHUDManager(containerView: UIView, sessionConfiguration: GameSessionConfiguration) {
        self.containerDisplayView = containerView

        // Configure visibility based on session type
        let isCompetitiveMode = sessionConfiguration.categoryType == .competitiveMultiBlock
        componentVisibilityStates[.levelIndicator] = isCompetitiveMode

        constructAllHUDComponents()
        applyLayoutConstraintsToComponents()
        initializeDisplayValues()
    }

    /// Construct all HUD components
    private func constructAllHUDComponents() {
        constructScoreDisplayComponent()
        constructHealthDisplayComponent()
        constructLevelDisplayComponent()
        constructChronometerComponent()
        constructComboStreakComponent()
    }

    // MARK: - Component Construction

    /// Construct score display component
    private func constructScoreDisplayComponent() {
        guard let container = containerDisplayView else { return }

        scoreComponentHolder.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scoreComponentHolder.layer.cornerRadius = 15
        scoreComponentHolder.layer.borderWidth = 1
        scoreComponentHolder.layer.borderColor = visualTheme.colorPalette.goldHighlightTint.withAlphaComponent(0.5).cgColor
        container.addSubview(scoreComponentHolder)
        scoreComponentHolder.translatesAutoresizingMaskIntoConstraints = false

        scoreIconDisplay.image = UIImage(systemName: "star.fill")
        scoreIconDisplay.tintColor = visualTheme.colorPalette.goldHighlightTint
        scoreIconDisplay.contentMode = .scaleAspectFit
        scoreComponentHolder.addSubview(scoreIconDisplay)
        scoreIconDisplay.translatesAutoresizingMaskIntoConstraints = false

        scoreValueLabel.text = "0"
        scoreValueLabel.textColor = visualTheme.colorPalette.textPrimaryWhite
        scoreValueLabel.font = visualTheme.typographyStyles.scoreDisplayStyle.createFont()
        scoreComponentHolder.addSubview(scoreValueLabel)
        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.textColor = visualTheme.colorPalette.textTertiaryDim
        scoreTitleLabel.font = visualTheme.typographyStyles.microTextStyle.createFont()
        scoreComponentHolder.addSubview(scoreTitleLabel)
        scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Construct health display component
    private func constructHealthDisplayComponent() {
        guard let container = containerDisplayView else { return }

        healthComponentHolder.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        healthComponentHolder.layer.cornerRadius = 15
        healthComponentHolder.layer.borderWidth = 1
        healthComponentHolder.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
        container.addSubview(healthComponentHolder)
        healthComponentHolder.translatesAutoresizingMaskIntoConstraints = false

        healthIconsStack.axis = .horizontal
        healthIconsStack.spacing = 6
        healthIconsStack.distribution = .fillEqually
        healthComponentHolder.addSubview(healthIconsStack)
        healthIconsStack.translatesAutoresizingMaskIntoConstraints = false

        // Create health icons
        for index in 0..<maximumHealthCapacity {
            let heartIconView = UIImageView()
            heartIconView.image = UIImage(systemName: "heart.fill")
            heartIconView.tintColor = .systemRed
            heartIconView.contentMode = .scaleAspectFit
            heartIconView.tag = index
            healthIconsStack.addArrangedSubview(heartIconView)
            healthIconCollection.append(heartIconView)

            heartIconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            heartIconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }
    }

    /// Construct level display component
    private func constructLevelDisplayComponent() {
        guard let container = containerDisplayView else { return }

        levelComponentHolder.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        levelComponentHolder.layer.cornerRadius = 15
        levelComponentHolder.layer.borderWidth = 1
        levelComponentHolder.layer.borderColor = visualTheme.colorPalette.tertiaryPurpleAccent.withAlphaComponent(0.5).cgColor
        levelComponentHolder.isHidden = !(componentVisibilityStates[.levelIndicator] ?? false)
        container.addSubview(levelComponentHolder)
        levelComponentHolder.translatesAutoresizingMaskIntoConstraints = false

        levelIconDisplay.image = UIImage(systemName: "bolt.fill")
        levelIconDisplay.tintColor = visualTheme.colorPalette.tertiaryPurpleAccent
        levelIconDisplay.contentMode = .scaleAspectFit
        levelComponentHolder.addSubview(levelIconDisplay)
        levelIconDisplay.translatesAutoresizingMaskIntoConstraints = false

        levelValueLabel.text = "1"
        levelValueLabel.textColor = visualTheme.colorPalette.textPrimaryWhite
        levelValueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        levelComponentHolder.addSubview(levelValueLabel)
        levelValueLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Construct chronometer display component
    private func constructChronometerComponent() {
        guard let container = containerDisplayView else { return }

        chronometerComponentHolder.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        chronometerComponentHolder.layer.cornerRadius = 15
        chronometerComponentHolder.layer.borderWidth = 1
        chronometerComponentHolder.layer.borderColor = visualTheme.colorPalette.primaryNeonCyan.withAlphaComponent(0.5).cgColor
        container.addSubview(chronometerComponentHolder)
        chronometerComponentHolder.translatesAutoresizingMaskIntoConstraints = false

        chronometerIconDisplay.image = UIImage(systemName: "clock.fill")
        chronometerIconDisplay.tintColor = visualTheme.colorPalette.primaryNeonCyan
        chronometerIconDisplay.contentMode = .scaleAspectFit
        chronometerComponentHolder.addSubview(chronometerIconDisplay)
        chronometerIconDisplay.translatesAutoresizingMaskIntoConstraints = false

        chronometerValueLabel.text = "0:00"
        chronometerValueLabel.textColor = visualTheme.colorPalette.textPrimaryWhite
        chronometerValueLabel.font = visualTheme.typographyStyles.timerDisplayStyle.createFont()
        chronometerComponentHolder.addSubview(chronometerValueLabel)
        chronometerValueLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Construct combo streak display component
    private func constructComboStreakComponent() {
        guard let container = containerDisplayView else { return }

        comboStreakHolder.backgroundColor = visualTheme.colorPalette.secondaryOrangeAccent.withAlphaComponent(0.9)
        comboStreakHolder.layer.cornerRadius = 20
        comboStreakHolder.alpha = 0
        comboStreakHolder.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        container.addSubview(comboStreakHolder)
        comboStreakHolder.translatesAutoresizingMaskIntoConstraints = false

        comboStreakLabel.text = "x1"
        comboStreakLabel.textColor = visualTheme.colorPalette.textPrimaryWhite
        comboStreakLabel.font = UIFont.systemFont(ofSize: 24, weight: .black)
        comboStreakLabel.textAlignment = .center
        comboStreakHolder.addSubview(comboStreakLabel)
        comboStreakLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Layout Constraints

    /// Apply layout constraints to all HUD components
    private func applyLayoutConstraintsToComponents() {
        guard let container = containerDisplayView else { return }

        NSLayoutConstraint.activate([
            // Score component constraints
            scoreComponentHolder.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scoreComponentHolder.topAnchor.constraint(equalTo: container.topAnchor),
            scoreComponentHolder.widthAnchor.constraint(equalToConstant: 110),
            scoreComponentHolder.heightAnchor.constraint(equalToConstant: 55),

            scoreIconDisplay.leadingAnchor.constraint(equalTo: scoreComponentHolder.leadingAnchor, constant: 12),
            scoreIconDisplay.centerYAnchor.constraint(equalTo: scoreComponentHolder.centerYAnchor),
            scoreIconDisplay.widthAnchor.constraint(equalToConstant: 20),
            scoreIconDisplay.heightAnchor.constraint(equalToConstant: 20),

            scoreValueLabel.leadingAnchor.constraint(equalTo: scoreIconDisplay.trailingAnchor, constant: 8),
            scoreValueLabel.topAnchor.constraint(equalTo: scoreComponentHolder.topAnchor, constant: 8),

            scoreTitleLabel.leadingAnchor.constraint(equalTo: scoreValueLabel.leadingAnchor),
            scoreTitleLabel.topAnchor.constraint(equalTo: scoreValueLabel.bottomAnchor, constant: -2),

            // Health component constraints
            healthComponentHolder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            healthComponentHolder.topAnchor.constraint(equalTo: container.topAnchor),
            healthComponentHolder.widthAnchor.constraint(equalToConstant: 110),
            healthComponentHolder.heightAnchor.constraint(equalToConstant: 55),

            healthIconsStack.centerXAnchor.constraint(equalTo: healthComponentHolder.centerXAnchor),
            healthIconsStack.centerYAnchor.constraint(equalTo: healthComponentHolder.centerYAnchor),

            // Chronometer component constraints
            chronometerComponentHolder.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chronometerComponentHolder.topAnchor.constraint(equalTo: container.topAnchor),
            chronometerComponentHolder.widthAnchor.constraint(equalToConstant: 90),
            chronometerComponentHolder.heightAnchor.constraint(equalToConstant: 55),

            chronometerIconDisplay.leadingAnchor.constraint(equalTo: chronometerComponentHolder.leadingAnchor, constant: 12),
            chronometerIconDisplay.centerYAnchor.constraint(equalTo: chronometerComponentHolder.centerYAnchor),
            chronometerIconDisplay.widthAnchor.constraint(equalToConstant: 18),
            chronometerIconDisplay.heightAnchor.constraint(equalToConstant: 18),

            chronometerValueLabel.leadingAnchor.constraint(equalTo: chronometerIconDisplay.trailingAnchor, constant: 6),
            chronometerValueLabel.centerYAnchor.constraint(equalTo: chronometerComponentHolder.centerYAnchor),

            // Level component constraints
            levelComponentHolder.leadingAnchor.constraint(equalTo: scoreComponentHolder.leadingAnchor),
            levelComponentHolder.topAnchor.constraint(equalTo: scoreComponentHolder.bottomAnchor, constant: 8),
            levelComponentHolder.widthAnchor.constraint(equalToConstant: 70),
            levelComponentHolder.heightAnchor.constraint(equalToConstant: 35),

            levelIconDisplay.leadingAnchor.constraint(equalTo: levelComponentHolder.leadingAnchor, constant: 10),
            levelIconDisplay.centerYAnchor.constraint(equalTo: levelComponentHolder.centerYAnchor),
            levelIconDisplay.widthAnchor.constraint(equalToConstant: 16),
            levelIconDisplay.heightAnchor.constraint(equalToConstant: 16),

            levelValueLabel.leadingAnchor.constraint(equalTo: levelIconDisplay.trailingAnchor, constant: 6),
            levelValueLabel.centerYAnchor.constraint(equalTo: levelComponentHolder.centerYAnchor),

            // Combo streak component constraints
            comboStreakHolder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            comboStreakHolder.topAnchor.constraint(equalTo: healthComponentHolder.bottomAnchor, constant: 10),
            comboStreakHolder.widthAnchor.constraint(equalToConstant: 80),
            comboStreakHolder.heightAnchor.constraint(equalToConstant: 40),

            comboStreakLabel.centerXAnchor.constraint(equalTo: comboStreakHolder.centerXAnchor),
            comboStreakLabel.centerYAnchor.constraint(equalTo: comboStreakHolder.centerYAnchor)
        ])
    }

    /// Initialize display values to defaults
    private func initializeDisplayValues() {
        displayedScoreValue = 0
        displayedHealthValue = maximumHealthCapacity
        displayedLevelValue = 1
        displayedElapsedSeconds = 0
        currentComboStreakValue = 0
        peakComboStreakValue = 0

        scoreValueLabel.text = "0"
        levelValueLabel.text = "1"
        chronometerValueLabel.text = "0:00"
    }

    // MARK: - Display Updates

    /// Update score display with animation
    func updateScoreDisplay(newScore: Int, animated: Bool = true) {
        let previousScore = displayedScoreValue
        displayedScoreValue = newScore
        scoreValueLabel.text = "\(newScore)"

        if animated && newScore > previousScore {
            executeScorePulseAnimation()
        }
    }

    /// Execute score pulse animation
    private func executeScorePulseAnimation() {
        let animator = UIViewPropertyAnimator(
            duration: animationConfiguration.updateDuration,
            curve: .easeOut
        ) {
            self.scoreValueLabel.transform = CGAffineTransform(
                scaleX: self.animationConfiguration.scalePulseFactor,
                y: self.animationConfiguration.scalePulseFactor
            )
        }

        animator.addCompletion { _ in
            UIView.animate(withDuration: self.animationConfiguration.updateDuration * 0.6) {
                self.scoreValueLabel.transform = .identity
            }
        }

        animator.startAnimation()
    }

    /// Update health display with animation
    func updateHealthDisplay(newHealth: Int, animated: Bool = true) {
        let previousHealth = displayedHealthValue
        displayedHealthValue = max(0, min(newHealth, maximumHealthCapacity))

        for (index, iconView) in healthIconCollection.enumerated() {
            if index < displayedHealthValue {
                iconView.isHidden = false
                iconView.alpha = 1.0
            } else {
                if animated {
                    UIView.animate(withDuration: animationConfiguration.fadeTransitionDuration, animations: {
                        iconView.alpha = 0.0
                        iconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    }) { _ in
                        iconView.isHidden = true
                        iconView.transform = .identity
                    }
                } else {
                    iconView.isHidden = true
                }
            }
        }

        // Animate the lost heart if health decreased
        if animated && newHealth < previousHealth && previousHealth > 0 {
            executeHealthLostAnimation(healthIndex: previousHealth - 1)
        }
    }

    /// Execute health lost animation on specific heart
    private func executeHealthLostAnimation(healthIndex: Int) {
        guard healthIndex < healthIconCollection.count else { return }
        let iconToAnimate = healthIconCollection[healthIndex]

        UIView.animate(withDuration: 0.2, animations: {
            iconToAnimate.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            iconToAnimate.tintColor = .white
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                iconToAnimate.transform = .identity
                iconToAnimate.tintColor = .systemRed
            }
        }
    }

    /// Update level display with animation
    func updateLevelDisplay(newLevel: Int, animated: Bool = true) {
        let previousLevel = displayedLevelValue
        displayedLevelValue = newLevel
        levelValueLabel.text = "\(newLevel)"

        if animated && newLevel > previousLevel {
            executeLevelUpAnimation()
        }
    }

    /// Execute level up animation
    private func executeLevelUpAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            self.levelComponentHolder.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.levelComponentHolder.transform = .identity
            }
        }
    }

    /// Update chronometer display
    func updateChronometerDisplay(elapsedSeconds: TimeInterval) {
        displayedElapsedSeconds = elapsedSeconds
        chronometerValueLabel.text = elapsedSeconds.formattedMinutesSeconds
    }

    /// Update combo streak display
    func updateComboStreakDisplay(newStreak: Int) {
        currentComboStreakValue = newStreak

        if newStreak > peakComboStreakValue {
            peakComboStreakValue = newStreak
        }

        comboStreakLabel.text = "x\(newStreak)"

        if newStreak > 0 {
            showComboStreakIndicator()
        } else {
            hideComboStreakIndicator()
        }
    }

    /// Show combo streak indicator with animation
    private func showComboStreakIndicator() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: animationConfiguration.springDampingRatio,
            initialSpringVelocity: 0.5
        ) {
            self.comboStreakHolder.alpha = 1
            self.comboStreakHolder.transform = .identity
        }

        // Schedule auto-hide
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.fadeOutComboStreakIfUnchanged()
        }
    }

    /// Hide combo streak indicator with animation
    private func hideComboStreakIndicator() {
        UIView.animate(withDuration: animationConfiguration.fadeTransitionDuration) {
            self.comboStreakHolder.alpha = 0
            self.comboStreakHolder.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }

    /// Fade out combo streak if value hasn't changed
    private func fadeOutComboStreakIfUnchanged() {
        guard comboStreakHolder.alpha > 0 else { return }
        hideComboStreakIndicator()
    }

    /// Reset combo streak to zero
    func resetComboStreak() {
        currentComboStreakValue = 0
        hideComboStreakIndicator()
    }

    // MARK: - Component Visibility

    /// Set visibility for specific HUD component
    func setComponentVisibility(_ componentType: HeadsUpDisplayComponentType, visible: Bool, animated: Bool = true) {
        componentVisibilityStates[componentType] = visible

        let targetView: UIView?
        switch componentType {
        case .scoreIndicator:
            targetView = scoreComponentHolder
        case .healthIndicator:
            targetView = healthComponentHolder
        case .levelIndicator:
            targetView = levelComponentHolder
        case .chronometer:
            targetView = chronometerComponentHolder
        case .comboIndicator:
            targetView = comboStreakHolder
        }

        guard let view = targetView else { return }

        if animated {
            UIView.animate(withDuration: animationConfiguration.fadeTransitionDuration) {
                view.alpha = visible ? 1.0 : 0.0
            } completion: { _ in
                view.isHidden = !visible
            }
        } else {
            view.isHidden = !visible
            view.alpha = visible ? 1.0 : 0.0
        }
    }

    // MARK: - Accessors

    /// Get current displayed score value
    var currentDisplayedScore: Int {
        return displayedScoreValue
    }

    /// Get current displayed health value
    var currentDisplayedHealth: Int {
        return displayedHealthValue
    }

    /// Get current displayed level value
    var currentDisplayedLevel: Int {
        return displayedLevelValue
    }

    /// Get peak combo streak achieved
    var achievedPeakComboStreak: Int {
        return peakComboStreakValue
    }
}
