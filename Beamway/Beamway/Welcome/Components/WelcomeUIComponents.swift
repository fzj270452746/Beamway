//
//  WelcomeUIComponents.swift
//  Beamway
//
//  Reusable UI components for welcome screen
//

import UIKit

// MARK: - Type Aliases for Compatibility

/// Alias for statistics tile component (used by GreetingPanelController)
typealias MetricsTilePanel = StatisticsTileComponent

/// Alias for daily quest panel (used by GreetingPanelController)
typealias DailyQuestPanel = DailyChallengePanel

/// Alias for badge preview panel (used by GreetingPanelController)
typealias BadgePreviewPanel = AchievementProgressPanel

/// Alias for radiant action button (used by GreetingPanelController)
typealias RadiantActionButton = GlowingActionButton

/// Alias for rounded navigation button (used by GreetingPanelController)
typealias RoundedNavigationButton = NavigationTabButton

// MARK: - Statistics Tile Component

/// Tile component displaying a single statistic with icon and value
final class StatisticsTileComponent: UIView {

    // MARK: - Type Definitions

    /// Configuration for statistics tile appearance
    struct TileConfiguration {
        let iconSystemName: String
        let titleText: String
        let iconTintColor: UIColor
        let cornerRadius: CGFloat
        let backgroundAlpha: CGFloat
        let borderAlpha: CGFloat

        static func standardConfiguration(icon: String, title: String) -> TileConfiguration {
            return TileConfiguration(
                iconSystemName: icon,
                titleText: title,
                iconTintColor: VisualThemeConfiguration.shared.colorPalette.primaryNeonCyan,
                cornerRadius: 15,
                backgroundAlpha: 0.08,
                borderAlpha: 0.15
            )
        }
    }

    // MARK: - Properties

    /// Icon image view
    private let iconImageView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Value label
    private let valueLabel: UILabel

    /// Configuration reference
    private let tileConfiguration: TileConfiguration

    // MARK: - Initialization

    init(configuration: TileConfiguration, initialValue: String = "0") {
        self.tileConfiguration = configuration
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        self.valueLabel = UILabel()

        super.init(frame: .zero)

        configureAppearance(initialValue: initialValue)
    }

    convenience init(iconName: String, title: String, initialValue: String = "0") {
        let config = TileConfiguration.standardConfiguration(icon: iconName, title: title)
        self.init(configuration: config, initialValue: initialValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure tile appearance
    private func configureAppearance(initialValue: String) {
        backgroundColor = UIColor.white.withAlphaComponent(tileConfiguration.backgroundAlpha)
        layer.cornerRadius = tileConfiguration.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(tileConfiguration.borderAlpha).cgColor

        configureIconView()
        configureTitleLabel()
        configureValueLabel(initialValue: initialValue)
        setupConstraints()
    }

    /// Configure icon image view
    private func configureIconView() {
        iconImageView.image = UIImage(systemName: tileConfiguration.iconSystemName)
        iconImageView.tintColor = tileConfiguration.iconTintColor
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = tileConfiguration.titleText
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure value label
    private func configureValueLabel(initialValue: String) {
        valueLabel.text = initialValue
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Compatibility Initializers

    /// Compatibility initializer with figure parameter (used by GreetingPanelController)
    convenience init(symbol: String, heading: String, figure: String) {
        self.init(iconName: symbol, title: heading, initialValue: figure)
    }

    // MARK: - Public Methods

    /// Alias for updateValue (compatibility with GreetingPanelController)
    func refreshFigure(_ newValue: String) {
        updateValue(newValue, animated: true)
    }

    /// Update displayed value with animation
    func updateValue(_ newValue: String, animated: Bool = true) {
        if animated {
            UIView.transition(with: valueLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.valueLabel.text = newValue
            }
        } else {
            valueLabel.text = newValue
        }
    }

    /// Get current displayed value
    var currentValue: String {
        return valueLabel.text ?? ""
    }
}

// MARK: - Daily Challenge Panel Component

/// Panel component for daily challenge feature
final class DailyChallengePanel: UIView {

    // MARK: - Properties

    /// Gradient background layer
    private let gradientLayer: CAGradientLayer

    /// Flame icon view
    private let flameIconView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Description label
    private let descriptionLabel: UILabel

    /// Countdown timer label
    private let countdownLabel: UILabel

    /// Play button
    private let playButton: UIButton

    /// Countdown timer
    private var countdownTimer: Timer?

    /// Play button tap callback
    var onPlayButtonTapped: (() -> Void)?

    /// Alias for onPlayButtonTapped (compatibility with GreetingPanelController)
    var onCommenceTouched: (() -> Void)? {
        get { onPlayButtonTapped }
        set { onPlayButtonTapped = newValue }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.gradientLayer = CAGradientLayer()
        self.flameIconView = UIImageView()
        self.titleLabel = UILabel()
        self.descriptionLabel = UILabel()
        self.countdownLabel = UILabel()
        self.playButton = UIButton(type: .system)

        super.init(frame: frame)

        configurePanelAppearance()
        startCountdownTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Configuration

    /// Configure panel appearance
    private func configurePanelAppearance() {
        configureGradientBackground()
        configureFlameIcon()
        configureTitleLabel()
        configureDescriptionLabel()
        configureCountdownLabel()
        configurePlayButton()
        setupConstraints()
    }

    /// Configure gradient background
    private func configureGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.4).cgColor,
            UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.4).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 0)

        layer.cornerRadius = 18
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.5).cgColor
    }

    /// Configure flame icon
    private func configureFlameIcon() {
        flameIconView.image = UIImage(systemName: "flame.fill")
        flameIconView.tintColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        flameIconView.contentMode = .scaleAspectFit
        addSubview(flameIconView)
        flameIconView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = "DAILY CHALLENGE"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure description label
    private func configureDescriptionLabel() {
        descriptionLabel.text = "Survive 60 seconds to earn bonus!"
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure countdown label
    private func configureCountdownLabel() {
        countdownLabel.text = "Resets in 00:00:00"
        countdownLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        countdownLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure play button
    private func configurePlayButton() {
        playButton.setTitle("PLAY", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        playButton.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        playButton.layer.cornerRadius = 15
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            flameIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            flameIconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -5),
            flameIconView.widthAnchor.constraint(equalToConstant: 30),
            flameIconView.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: flameIconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            countdownLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            countdownLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),

            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 70),
            playButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

    // MARK: - Timer Management

    /// Start countdown timer
    private func startCountdownTimer() {
        updateCountdownDisplay()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdownDisplay()
        }
    }

    /// Update countdown display
    private func updateCountdownDisplay() {
        let calendar = Calendar.current
        let now = Date()
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) {
            let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: tomorrow)
            countdownLabel.text = String(
                format: "Resets in %02d:%02d:%02d",
                components.hour ?? 0,
                components.minute ?? 0,
                components.second ?? 0
            )
        }
    }

    // MARK: - Actions

    @objc private func playButtonTapped() {
        onPlayButtonTapped?()
    }

    // MARK: - Cleanup

    deinit {
        countdownTimer?.invalidate()
    }
}

// MARK: - Achievement Progress Panel

/// Panel displaying achievement progress and badges
final class AchievementProgressPanel: UIView {

    // MARK: - Properties

    /// Title label
    private let titleLabel: UILabel

    /// Progress bar
    private let progressBar: UIProgressView

    /// Progress description label
    private let progressDescriptionLabel: UILabel

    /// Badge icons stack
    private let badgeIconsStack: UIStackView

    /// Badge icon views
    private var badgeIconViews: [UIImageView] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        self.progressBar = UIProgressView(progressViewStyle: .default)
        self.progressDescriptionLabel = UILabel()
        self.badgeIconsStack = UIStackView()

        super.init(frame: frame)

        configurePanelAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure panel appearance
    private func configurePanelAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        configureTitleLabel()
        configureProgressBar()
        configureProgressDescription()
        configureBadgeIcons()
        setupConstraints()
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = "Next Achievement"
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure progress bar
    private func configureProgressBar() {
        progressBar.progressTintColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        progressBar.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        progressBar.layer.cornerRadius = 3
        progressBar.clipsToBounds = true
        addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure progress description label
    private func configureProgressDescription() {
        progressDescriptionLabel.text = "Play 5 games - 0/5"
        progressDescriptionLabel.textColor = .white
        progressDescriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addSubview(progressDescriptionLabel)
        progressDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure badge icons
    private func configureBadgeIcons() {
        let iconNames = ["star.fill", "bolt.fill", "crown.fill"]

        for iconName in iconNames {
            let badgeIcon = UIImageView(image: UIImage(systemName: iconName))
            badgeIcon.tintColor = UIColor.white.withAlphaComponent(0.2)
            badgeIcon.contentMode = .scaleAspectFit
            badgeIcon.translatesAutoresizingMaskIntoConstraints = false

            badgeIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
            badgeIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true

            badgeIconsStack.addArrangedSubview(badgeIcon)
            badgeIconViews.append(badgeIcon)
        }

        badgeIconsStack.axis = .horizontal
        badgeIconsStack.spacing = 8
        addSubview(badgeIconsStack)
        badgeIconsStack.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            progressDescriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            progressDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            progressBar.topAnchor.constraint(equalTo: progressDescriptionLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            progressBar.trailingAnchor.constraint(equalTo: badgeIconsStack.leadingAnchor, constant: -15),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            badgeIconsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeIconsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }

    // MARK: - Public Methods

    /// Update achievement progress display
    func updateProgress(gamesPlayed: Int, highScore: Int) {
        let goldColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)

        if gamesPlayed < 5 {
            progressDescriptionLabel.text = "Play 5 games - \(gamesPlayed)/5"
            progressBar.progress = Float(gamesPlayed) / 5.0
        } else if gamesPlayed < 20 {
            progressDescriptionLabel.text = "Play 20 games - \(gamesPlayed)/20"
            progressBar.progress = Float(gamesPlayed) / 20.0
            badgeIconViews[0].tintColor = goldColor
        } else if highScore < 50 {
            progressDescriptionLabel.text = "Score 50 points - \(highScore)/50"
            progressBar.progress = Float(highScore) / 50.0
            badgeIconViews[0].tintColor = goldColor
            badgeIconViews[1].tintColor = goldColor
        } else {
            progressDescriptionLabel.text = "All achievements unlocked!"
            progressBar.progress = 1.0
            for badge in badgeIconViews {
                badge.tintColor = goldColor
            }
        }
    }

    /// Alias for updateProgress (compatibility with GreetingPanelController)
    func refreshAdvancement(matchesCompleted: Int, peakPoints: Int) {
        updateProgress(gamesPlayed: matchesCompleted, highScore: peakPoints)
    }
}

// MARK: - Glowing Action Button

/// Button with glowing effect and gradient background
final class GlowingActionButton: UIButton {

    // MARK: - Properties

    /// Glow effect layer
    private let glowLayer: CALayer

    /// Gradient background layer
    private let gradientLayer: CAGradientLayer

    /// Primary button color
    private let primaryColor: UIColor

    /// Pulse animation key
    private let pulseAnimationKey = "glowPulseAnimation"

    // MARK: - Initialization

    init(title: String, primaryColor: UIColor) {
        self.primaryColor = primaryColor
        self.glowLayer = CALayer()
        self.gradientLayer = CAGradientLayer()

        super.init(frame: .zero)

        configureButtonAppearance(title: title)
    }

    /// Compatibility initializer (used by GreetingPanelController)
    convenience init(caption: String, dominantHue: UIColor) {
        self.init(title: caption, primaryColor: dominantHue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        glowLayer.frame = bounds.insetBy(dx: -10, dy: -10)
        glowLayer.cornerRadius = layer.cornerRadius + 5
    }

    // MARK: - Configuration

    /// Configure button appearance
    private func configureButtonAppearance(title: String) {
        configureGlowLayer()
        configureGradientLayer()
        configureButtonStyle(title: title)
        configureTouchAnimations()
        startPulseAnimation()
    }

    /// Configure glow effect layer
    private func configureGlowLayer() {
        glowLayer.backgroundColor = primaryColor.withAlphaComponent(0.3).cgColor
        glowLayer.shadowColor = primaryColor.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowRadius = 15
        glowLayer.shadowOpacity = 0.8
        layer.insertSublayer(glowLayer, at: 0)
    }

    /// Configure gradient background layer
    private func configureGradientLayer() {
        gradientLayer.colors = [
            primaryColor.cgColor,
            primaryColor.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 1)
    }

    /// Configure button style
    private func configureButtonStyle(title: String) {
        layer.cornerRadius = 18
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        layer.shadowColor = primaryColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.5
    }

    /// Configure touch animations
    private func configureTouchAnimations() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    /// Start pulse animation
    private func startPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 15
        pulse.toValue = 25
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: pulseAnimationKey)
    }

    // MARK: - Touch Handlers

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.9
        }
    }

    @objc private func touchUp() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - Navigation Tab Button

/// Compact navigation button for bottom tab bar
final class NavigationTabButton: UIControl {

    // MARK: - Properties

    /// Icon image view
    private let iconImageView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    // MARK: - Initialization

    init(iconName: String, title: String) {
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        self.visualTheme = VisualThemeConfiguration.shared

        super.init(frame: .zero)

        configureButtonAppearance(iconName: iconName, title: title)
    }

    /// Compatibility initializer (used by GreetingPanelController)
    convenience init(symbol: String, heading: String) {
        self.init(iconName: symbol, title: heading)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure button appearance
    private func configureButtonAppearance(iconName: String, title: String) {
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 50),
            heightAnchor.constraint(equalToConstant: 50),

            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 3),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Touch Handlers

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.iconImageView.tintColor = self.visualTheme.colorPalette.primaryNeonCyan
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
            self.iconImageView.tintColor = .white
        }
    }
}
