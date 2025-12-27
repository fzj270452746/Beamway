//
//  ModeSelectionUIComponents.swift
//  Beamway
//
//  Reusable UI components for game mode selection screen
//

import UIKit

// MARK: - Mode Selection Card Component

/// Card component for displaying a game mode option
final class GameModeSelectionCard: UIView {

    // MARK: - Type Definitions

    /// Game mode type
    enum GameModeType {
        case singlePlayer
        case challengeMode

        var displayTitle: String {
            switch self {
            case .singlePlayer:
                return "SINGLE"
            case .challengeMode:
                return "CHALLENGE"
            }
        }

        var displaySubtitle: String {
            switch self {
            case .singlePlayer:
                return "Classic Mode"
            case .challengeMode:
                return "Expert Mode"
            }
        }

        var description: String {
            switch self {
            case .singlePlayer:
                return "Control one tile and survive as long as possible"
            case .challengeMode:
                return "Control multiple tiles with increasing difficulty"
            }
        }

        var iconName: String {
            switch self {
            case .singlePlayer:
                return "person.fill"
            case .challengeMode:
                return "bolt.fill"
            }
        }

        var primaryColor: UIColor {
            switch self {
            case .singlePlayer:
                return UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
            case .challengeMode:
                return UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
            }
        }
    }

    // MARK: - Properties

    /// Game mode type
    private let modeType: GameModeType

    /// Gradient background layer
    private let gradientLayer: CAGradientLayer

    /// Glow effect layer
    private let glowLayer: CALayer

    /// Icon container view
    private let iconContainerView: UIView

    /// Icon image view
    private let iconImageView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Subtitle label
    private let subtitleLabel: UILabel

    /// Description label
    private let descriptionLabel: UILabel

    /// Arrow indicator view
    private let arrowIndicatorView: UIImageView

    /// Card tap callback
    var onCardTapped: (() -> Void)?

    // MARK: - Initialization

    init(modeType: GameModeType) {
        self.modeType = modeType
        self.gradientLayer = CAGradientLayer()
        self.glowLayer = CALayer()
        self.iconContainerView = UIView()
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        self.subtitleLabel = UILabel()
        self.descriptionLabel = UILabel()
        self.arrowIndicatorView = UIImageView()

        super.init(frame: .zero)

        configureCardAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        glowLayer.frame = bounds.insetBy(dx: -5, dy: -5)
        glowLayer.cornerRadius = layer.cornerRadius + 5
    }

    // MARK: - Configuration

    /// Configure card appearance
    private func configureCardAppearance() {
        configureGlowEffect()
        configureGradientBackground()
        configureIconSection()
        configureTextLabels()
        configureArrowIndicator()
        configureTapGesture()
        setupConstraints()
        startArrowAnimation()
    }

    /// Configure glow effect
    private func configureGlowEffect() {
        glowLayer.backgroundColor = UIColor.clear.cgColor
        glowLayer.shadowColor = modeType.primaryColor.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowRadius = 20
        glowLayer.shadowOpacity = 0.4
        layer.insertSublayer(glowLayer, at: 0)
    }

    /// Configure gradient background
    private func configureGradientBackground() {
        gradientLayer.colors = [
            modeType.primaryColor.withAlphaComponent(0.25).cgColor,
            modeType.primaryColor.withAlphaComponent(0.08).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 25
        layer.insertSublayer(gradientLayer, at: 1)

        layer.cornerRadius = 25
        layer.borderWidth = 1.5
        layer.borderColor = modeType.primaryColor.withAlphaComponent(0.4).cgColor
    }

    /// Configure icon section
    private func configureIconSection() {
        iconContainerView.backgroundColor = modeType.primaryColor.withAlphaComponent(0.2)
        iconContainerView.layer.cornerRadius = 30
        addSubview(iconContainerView)
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.image = UIImage(systemName: modeType.iconName)
        iconImageView.tintColor = modeType.primaryColor
        iconImageView.contentMode = .scaleAspectFit
        iconContainerView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure text labels
    private func configureTextLabels() {
        subtitleLabel.text = modeType.displaySubtitle
        subtitleLabel.textColor = modeType.primaryColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = modeType.displayTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .black)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.text = modeType.description
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.numberOfLines = 2
        addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure arrow indicator
    private func configureArrowIndicator() {
        arrowIndicatorView.image = UIImage(systemName: "arrow.right.circle.fill")
        arrowIndicatorView.tintColor = modeType.primaryColor
        arrowIndicatorView.contentMode = .scaleAspectFit
        addSubview(arrowIndicatorView)
        arrowIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure tap gesture
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 60),
            iconContainerView.heightAnchor.constraint(equalToConstant: 60),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 18),
            subtitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),

            descriptionLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: arrowIndicatorView.leadingAnchor, constant: -15),

            arrowIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            arrowIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            arrowIndicatorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Animation

    /// Start arrow animation
    private func startArrowAnimation() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            self.arrowIndicatorView.transform = CGAffineTransform(translationX: 5, y: 0)
        }
    }

    // MARK: - Actions

    @objc private func cardTapped() {
        TouchFeedbackController.shared.generateButtonPressFeedback()

        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.alpha = 0.9
        }) { _ in
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5
            ) {
                self.transform = .identity
                self.alpha = 1.0
            } completion: { _ in
                self.onCardTapped?()
            }
        }
    }
}

// MARK: - Mode Selection Header Component

/// Header component for mode selection screen (UIComponents version)
final class ModeSelectionHeaderComponent: UIView {

    // MARK: - Properties

    /// Title label
    private let titleLabel: UILabel

    /// Subtitle label
    private let subtitleLabel: UILabel

    /// Back button
    private let backButton: UIButton

    /// Back button tap callback
    var onBackButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        self.subtitleLabel = UILabel()
        self.backButton = UIButton(type: .system)

        super.init(frame: frame)

        configureHeaderAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure header appearance
    private func configureHeaderAppearance() {
        backgroundColor = .clear

        configureBackButton()
        configureTitleLabel()
        configureSubtitleLabel()
        setupConstraints()
    }

    /// Configure back button
    private func configureBackButton() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        backButton.layer.cornerRadius = 22
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = "SELECT MODE"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.6
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure subtitle label
    private func configureSubtitleLabel() {
        subtitleLabel.text = "Choose your challenge"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),

            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
}

// MARK: - Tips Panel Component

/// Panel displaying gameplay tips
final class GameplayTipsPanel: UIView {

    // MARK: - Properties

    /// Tips icon view
    private let tipsIconView: UIImageView

    /// Tips label
    private let tipsLabel: UILabel

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.tipsIconView = UIImageView()
        self.tipsLabel = UILabel()

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
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        tipsIconView.image = UIImage(systemName: "lightbulb.fill")
        tipsIconView.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        tipsIconView.contentMode = .scaleAspectFit
        addSubview(tipsIconView)
        tipsIconView.translatesAutoresizingMaskIntoConstraints = false

        tipsLabel.text = "TIP: Start with Single Mode to learn the basics!"
        tipsLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        tipsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        tipsLabel.numberOfLines = 2
        addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tipsIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tipsIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tipsIconView.widthAnchor.constraint(equalToConstant: 24),
            tipsIconView.heightAnchor.constraint(equalToConstant: 24),

            tipsLabel.leadingAnchor.constraint(equalTo: tipsIconView.trailingAnchor, constant: 12),
            tipsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tipsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Update tips text
    func updateTipsText(_ text: String) {
        tipsLabel.text = text
    }
}

// MARK: - Mode Selection Animation Coordinator

/// Coordinator for mode selection screen animations (UIComponents version)
final class ModeSelectionUIAnimationCoordinator {

    // MARK: - Properties

    /// Registered views for animation
    private var animatableViews: [UIView] = []

    // MARK: - Public Methods

    /// Register views for entrance animation
    func registerViewsForAnimation(_ views: [UIView]) {
        animatableViews = views
    }

    /// Prepare views for entrance animation
    func prepareForEntranceAnimation() {
        for (index, view) in animatableViews.enumerated() {
            view.alpha = 0

            switch index {
            case 0:
                view.transform = CGAffineTransform(translationX: 0, y: -30)
            case 1:
                view.transform = CGAffineTransform(translationX: -50, y: 0)
            case 2:
                view.transform = CGAffineTransform(translationX: 50, y: 0)
            default:
                view.transform = CGAffineTransform(translationX: 0, y: 30)
            }
        }
    }

    /// Execute entrance animation sequence
    func executeEntranceAnimation() {
        for (index, view) in animatableViews.enumerated() {
            let delay = 0.1 + Double(index) * 0.1

            UIView.animate(
                withDuration: 0.5,
                delay: delay,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
}
