//
//  GameHUDManager.swift
//  Beamway
//
//  Manages the heads-up display elements during gameplay
//  Including score, lives, level, timer, and combo displays
//

import UIKit

/// Manager for game HUD elements
final class GameHUDManager {

    // MARK: - Constants

    private struct HUDConstants {
        static let hudHeight: CGFloat = 100
        static let containerCornerRadius: CGFloat = 15
        static let scoreContainerWidth: CGFloat = 110
        static let scoreContainerHeight: CGFloat = 55
        static let livesContainerWidth: CGFloat = 110
        static let livesContainerHeight: CGFloat = 55
        static let levelContainerWidth: CGFloat = 70
        static let levelContainerHeight: CGFloat = 35
        static let timerContainerWidth: CGFloat = 90
        static let timerContainerHeight: CGFloat = 55
        static let comboContainerWidth: CGFloat = 80
        static let comboContainerHeight: CGFloat = 40
    }

    // MARK: - Properties

    private let sessionCategory: SessionCategory

    // Container Views
    private let topDisplayHolder: UIView
    private let scoreContainer: UIView
    private let livesContainer: UIView
    private let levelContainer: UIView
    private let timerContainer: UIView
    private let comboContainer: UIView

    // Score Display
    private let scoreIcon: UIImageView
    private let scoreLabel: UILabel
    private let scoreTitleLabel: UILabel

    // Lives Display
    private var heartIcons: [UIImageView] = []

    // Level Display
    private let levelIcon: UIImageView
    private let levelLabel: UILabel

    // Timer Display
    private let timerIcon: UIImageView
    private let timerLabel: UILabel

    // Combo Display
    private let comboLabel: UILabel

    // Timer
    private var chronometerTimer: Timer?
    private var elapsedTime: TimeInterval = 0

    // State
    private var currentScore: Int = 0
    private var currentLives: Int = 3
    private var currentLevel: Int = 1
    private var currentCombo: Int = 0

    // MARK: - Initialization

    init(sessionCategory: SessionCategory) {
        self.sessionCategory = sessionCategory

        topDisplayHolder = UIView()
        scoreContainer = UIView()
        livesContainer = UIView()
        levelContainer = UIView()
        timerContainer = UIView()
        comboContainer = UIView()

        scoreIcon = UIImageView()
        scoreLabel = UILabel()
        scoreTitleLabel = UILabel()

        levelIcon = UIImageView()
        levelLabel = UILabel()

        timerIcon = UIImageView()
        timerLabel = UILabel()

        comboLabel = UILabel()
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureTopDisplayHolder(in: parentView)
        configureScoreDisplay()
        configureLivesDisplay()

        if sessionCategory == .competitive {
            configureLevelDisplay()
        }

        configureTimerDisplay()
        configureComboDisplay(in: parentView)
    }

    private func configureTopDisplayHolder(in parentView: UIView) {
        topDisplayHolder.backgroundColor = .clear
        parentView.addSubview(topDisplayHolder)
        topDisplayHolder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topDisplayHolder.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            topDisplayHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 15),
            topDisplayHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -15),
            topDisplayHolder.heightAnchor.constraint(equalToConstant: HUDConstants.hudHeight)
        ])
    }

    private func configureScoreDisplay() {
        scoreContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scoreContainer.layer.cornerRadius = HUDConstants.containerCornerRadius
        scoreContainer.layer.borderWidth = 1
        scoreContainer.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.5).cgColor
        topDisplayHolder.addSubview(scoreContainer)
        scoreContainer.translatesAutoresizingMaskIntoConstraints = false

        scoreIcon.image = UIImage(systemName: "star.fill")
        scoreIcon.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        scoreIcon.contentMode = .scaleAspectFit
        scoreContainer.addSubview(scoreIcon)
        scoreIcon.translatesAutoresizingMaskIntoConstraints = false

        scoreLabel.text = "0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        scoreContainer.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        scoreTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        scoreContainer.addSubview(scoreTitleLabel)
        scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scoreContainer.leadingAnchor.constraint(equalTo: topDisplayHolder.leadingAnchor),
            scoreContainer.topAnchor.constraint(equalTo: topDisplayHolder.topAnchor),
            scoreContainer.widthAnchor.constraint(equalToConstant: HUDConstants.scoreContainerWidth),
            scoreContainer.heightAnchor.constraint(equalToConstant: HUDConstants.scoreContainerHeight),

            scoreIcon.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 12),
            scoreIcon.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            scoreIcon.widthAnchor.constraint(equalToConstant: 20),
            scoreIcon.heightAnchor.constraint(equalToConstant: 20),

            scoreLabel.leadingAnchor.constraint(equalTo: scoreIcon.trailingAnchor, constant: 8),
            scoreLabel.topAnchor.constraint(equalTo: scoreContainer.topAnchor, constant: 8),

            scoreTitleLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            scoreTitleLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: -2)
        ])
    }

    private func configureLivesDisplay() {
        livesContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        livesContainer.layer.cornerRadius = HUDConstants.containerCornerRadius
        livesContainer.layer.borderWidth = 1
        livesContainer.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
        topDisplayHolder.addSubview(livesContainer)
        livesContainer.translatesAutoresizingMaskIntoConstraints = false

        let heartsStack = UIStackView()
        heartsStack.axis = .horizontal
        heartsStack.spacing = 6
        heartsStack.distribution = .fillEqually

        for i in 0..<3 {
            let heartView = UIImageView()
            heartView.image = UIImage(systemName: "heart.fill")
            heartView.tintColor = .systemRed
            heartView.contentMode = .scaleAspectFit
            heartView.tag = i
            heartsStack.addArrangedSubview(heartView)
            heartIcons.append(heartView)

            heartView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            heartView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }

        livesContainer.addSubview(heartsStack)
        heartsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            livesContainer.centerXAnchor.constraint(equalTo: topDisplayHolder.centerXAnchor),
            livesContainer.topAnchor.constraint(equalTo: topDisplayHolder.topAnchor),
            livesContainer.widthAnchor.constraint(equalToConstant: HUDConstants.livesContainerWidth),
            livesContainer.heightAnchor.constraint(equalToConstant: HUDConstants.livesContainerHeight),

            heartsStack.centerXAnchor.constraint(equalTo: livesContainer.centerXAnchor),
            heartsStack.centerYAnchor.constraint(equalTo: livesContainer.centerYAnchor)
        ])
    }

    private func configureLevelDisplay() {
        levelContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        levelContainer.layer.cornerRadius = HUDConstants.containerCornerRadius
        levelContainer.layer.borderWidth = 1
        levelContainer.layer.borderColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.5).cgColor
        topDisplayHolder.addSubview(levelContainer)
        levelContainer.translatesAutoresizingMaskIntoConstraints = false

        levelIcon.image = UIImage(systemName: "bolt.fill")
        levelIcon.tintColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
        levelIcon.contentMode = .scaleAspectFit
        levelContainer.addSubview(levelIcon)
        levelIcon.translatesAutoresizingMaskIntoConstraints = false

        levelLabel.text = "1"
        levelLabel.textColor = .white
        levelLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        levelContainer.addSubview(levelLabel)
        levelLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            levelContainer.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor),
            levelContainer.topAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: 8),
            levelContainer.widthAnchor.constraint(equalToConstant: HUDConstants.levelContainerWidth),
            levelContainer.heightAnchor.constraint(equalToConstant: HUDConstants.levelContainerHeight),

            levelIcon.leadingAnchor.constraint(equalTo: levelContainer.leadingAnchor, constant: 10),
            levelIcon.centerYAnchor.constraint(equalTo: levelContainer.centerYAnchor),
            levelIcon.widthAnchor.constraint(equalToConstant: 16),
            levelIcon.heightAnchor.constraint(equalToConstant: 16),

            levelLabel.leadingAnchor.constraint(equalTo: levelIcon.trailingAnchor, constant: 6),
            levelLabel.centerYAnchor.constraint(equalTo: levelContainer.centerYAnchor)
        ])
    }

    private func configureTimerDisplay() {
        timerContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        timerContainer.layer.cornerRadius = HUDConstants.containerCornerRadius
        timerContainer.layer.borderWidth = 1
        timerContainer.layer.borderColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.5).cgColor
        topDisplayHolder.addSubview(timerContainer)
        timerContainer.translatesAutoresizingMaskIntoConstraints = false

        timerIcon.image = UIImage(systemName: "clock.fill")
        timerIcon.tintColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
        timerIcon.contentMode = .scaleAspectFit
        timerContainer.addSubview(timerIcon)
        timerIcon.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.text = "0:00"
        timerLabel.textColor = .white
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        timerContainer.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timerContainer.trailingAnchor.constraint(equalTo: topDisplayHolder.trailingAnchor),
            timerContainer.topAnchor.constraint(equalTo: topDisplayHolder.topAnchor),
            timerContainer.widthAnchor.constraint(equalToConstant: HUDConstants.timerContainerWidth),
            timerContainer.heightAnchor.constraint(equalToConstant: HUDConstants.timerContainerHeight),

            timerIcon.leadingAnchor.constraint(equalTo: timerContainer.leadingAnchor, constant: 12),
            timerIcon.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor),
            timerIcon.widthAnchor.constraint(equalToConstant: 18),
            timerIcon.heightAnchor.constraint(equalToConstant: 18),

            timerLabel.leadingAnchor.constraint(equalTo: timerIcon.trailingAnchor, constant: 6),
            timerLabel.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor)
        ])
    }

    private func configureComboDisplay(in parentView: UIView) {
        comboContainer.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.9)
        comboContainer.layer.cornerRadius = 20
        comboContainer.alpha = 0
        comboContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        parentView.addSubview(comboContainer)
        comboContainer.translatesAutoresizingMaskIntoConstraints = false

        comboLabel.text = "x1"
        comboLabel.textColor = .white
        comboLabel.font = UIFont.systemFont(ofSize: 24, weight: .black)
        comboLabel.textAlignment = .center
        comboContainer.addSubview(comboLabel)
        comboLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            comboContainer.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            comboContainer.topAnchor.constraint(equalTo: topDisplayHolder.bottomAnchor, constant: 10),
            comboContainer.widthAnchor.constraint(equalToConstant: HUDConstants.comboContainerWidth),
            comboContainer.heightAnchor.constraint(equalToConstant: HUDConstants.comboContainerHeight),

            comboLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            comboLabel.centerYAnchor.constraint(equalTo: comboContainer.centerYAnchor)
        ])
    }

    // MARK: - Update Methods

    func updateScore(_ score: Int) {
        currentScore = score
        animateScoreUpdate()
    }

    private func animateScoreUpdate() {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeOut) {
            self.scoreLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        animator.addCompletion { _ in
            UIView.animate(withDuration: 0.1) {
                self.scoreLabel.transform = .identity
            }
        }
        animator.startAnimation()

        scoreLabel.text = "\(currentScore)"
    }

    func updateLives(_ lives: Int) {
        currentLives = max(0, lives)
        animateLivesUpdate()
    }

    private func animateLivesUpdate() {
        for (index, iconView) in heartIcons.enumerated() {
            if index < currentLives {
                iconView.isHidden = false
                iconView.alpha = 1.0
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    iconView.alpha = 0.0
                    iconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }) { _ in
                    iconView.isHidden = true
                    iconView.transform = .identity
                }
            }
        }
    }

    func updateLevel(_ level: Int) {
        currentLevel = level
        levelLabel.text = "\(currentLevel)"
    }

    func updateCombo(_ combo: Int) {
        currentCombo = combo

        if combo > 0 {
            showCombo()
        } else {
            hideCombo()
        }
    }

    private func showCombo() {
        comboLabel.text = "x\(currentCombo)"

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            self.comboContainer.alpha = 1
            self.comboContainer.transform = .identity
        }

        // Auto-hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, self.currentCombo == self.currentCombo else { return }
            UIView.animate(withDuration: 0.3) {
                self.comboContainer.alpha = 0
                self.comboContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }
    }

    private func hideCombo() {
        UIView.animate(withDuration: 0.2) {
            self.comboContainer.alpha = 0
        }
    }

    // MARK: - Timer Methods

    func startChronometer(onTick: @escaping () -> Void) {
        chronometerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.updateTimerDisplay()
            onTick()
        }
    }

    func stopChronometer() {
        chronometerTimer?.invalidate()
        chronometerTimer = nil
    }

    private func updateTimerDisplay() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Reset

    func resetDisplay() {
        currentScore = 0
        currentLives = 3
        currentLevel = 1
        currentCombo = 0
        elapsedTime = 0

        scoreLabel.text = "0"
        timerLabel.text = "0:00"
        levelLabel.text = "1"

        for iconView in heartIcons {
            iconView.isHidden = false
            iconView.alpha = 1.0
            iconView.transform = .identity
        }

        comboContainer.alpha = 0
        comboContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
}
