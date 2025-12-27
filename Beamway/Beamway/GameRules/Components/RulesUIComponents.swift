//
//  RulesUIComponents.swift
//  Beamway
//
//  Reusable UI components for game rules screen
//

import UIKit

// MARK: - Rules Section Card Component

/// Card component for displaying a rules section with icon, title, and bullet points
final class RulesSectionCard: UIView {

    // MARK: - Type Definitions

    /// Configuration for rules section card
    struct RulesSectionConfiguration {
        let iconName: String
        let iconColor: UIColor
        let title: String
        let rules: [String]

        static let howToPlay = RulesSectionConfiguration(
            iconName: "gamecontroller.fill",
            iconColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0),
            title: "HOW TO PLAY",
            rules: [
                "Drag mahjong tiles to dodge incoming arrows",
                "Arrows come from all four sides of the screen",
                "Each dodged arrow gives you 1 point",
                "You have 3 lives - don't get hit!"
            ]
        )

        static let gameModes = RulesSectionConfiguration(
            iconName: "switch.2",
            iconColor: UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0),
            title: "GAME MODES",
            rules: [
                "Single Mode: Control one tile throughout",
                "Challenge Mode: Control multiple tiles",
                "Difficulty increases as you progress",
                "Higher scores unlock achievements"
            ]
        )

        static let scoring = RulesSectionConfiguration(
            iconName: "star.fill",
            iconColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            title: "SCORING",
            rules: [
                "+1 point for each dodged arrow",
                "Build combos for extra excitement",
                "Level up every 10 points in Challenge",
                "Records are saved automatically"
            ]
        )

        static let proTips = RulesSectionConfiguration(
            iconName: "lightbulb.fill",
            iconColor: UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0),
            title: "PRO TIPS",
            rules: [
                "Stay near the center for more options",
                "Watch all four edges at once",
                "Small movements are safer",
                "Practice makes perfect!"
            ]
        )
    }

    // MARK: - Properties

    /// Section configuration
    private let sectionConfiguration: RulesSectionConfiguration

    /// Icon image view
    private let iconImageView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Rules stack view
    private let rulesStackView: UIStackView

    // MARK: - Initialization

    init(configuration: RulesSectionConfiguration) {
        self.sectionConfiguration = configuration
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        self.rulesStackView = UIStackView()

        super.init(frame: .zero)

        configureCardAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure card appearance
    private func configureCardAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = sectionConfiguration.iconColor.withAlphaComponent(0.3).cgColor

        configureIconView()
        configureTitleLabel()
        configureRulesStack()
        setupConstraints()
    }

    /// Configure icon view
    private func configureIconView() {
        iconImageView.image = UIImage(systemName: sectionConfiguration.iconName)
        iconImageView.tintColor = sectionConfiguration.iconColor
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = sectionConfiguration.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure rules stack view
    private func configureRulesStack() {
        rulesStackView.axis = .vertical
        rulesStackView.spacing = 12

        for ruleText in sectionConfiguration.rules {
            let ruleRow = RuleBulletPointView(
                text: ruleText,
                bulletColor: sectionConfiguration.iconColor
            )
            rulesStackView.addArrangedSubview(ruleRow)
        }

        addSubview(rulesStackView)
        rulesStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),

            rulesStackView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 18),
            rulesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            rulesStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            rulesStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}

// MARK: - Rule Bullet Point View

/// View displaying a single rule with bullet point
final class RuleBulletPointView: UIView {

    // MARK: - Properties

    /// Bullet point view
    private let bulletView: UIView

    /// Text label
    private let textLabel: UILabel

    // MARK: - Initialization

    init(text: String, bulletColor: UIColor) {
        self.bulletView = UIView()
        self.textLabel = UILabel()

        super.init(frame: .zero)

        configureRowAppearance(text: text, bulletColor: bulletColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure row appearance
    private func configureRowAppearance(text: String, bulletColor: UIColor) {
        bulletView.backgroundColor = bulletColor
        bulletView.layer.cornerRadius = 4
        addSubview(bulletView)
        bulletView.translatesAutoresizingMaskIntoConstraints = false

        textLabel.text = text
        textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.numberOfLines = 0
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bulletView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bulletView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            bulletView.widthAnchor.constraint(equalToConstant: 8),
            bulletView.heightAnchor.constraint(equalToConstant: 8),

            textLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 12),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Controls Diagram Card Component

/// Card component displaying control instructions with diagram
final class ControlsDiagramCard: UIView {

    // MARK: - Properties

    /// Title label
    private let titleLabel: UILabel

    /// Gesture icon view
    private let gestureIconView: UIImageView

    /// Description label
    private let descriptionLabel: UILabel

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        self.gestureIconView = UIImageView()
        self.descriptionLabel = UILabel()

        super.init(frame: frame)

        configureCardAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure card appearance
    private func configureCardAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        configureTitleLabel()
        configureGestureIcon()
        configureDescriptionLabel()
        setupConstraints()
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = "CONTROLS"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure gesture icon
    private func configureGestureIcon() {
        gestureIconView.image = UIImage(systemName: "hand.draw.fill")
        gestureIconView.tintColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
        gestureIconView.contentMode = .scaleAspectFit
        addSubview(gestureIconView)
        gestureIconView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure description label
    private func configureDescriptionLabel() {
        descriptionLabel.text = "Drag tiles with your finger to move them around the play area"
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            gestureIconView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            gestureIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gestureIconView.widthAnchor.constraint(equalToConstant: 32),
            gestureIconView.heightAnchor.constraint(equalToConstant: 32),

            descriptionLabel.topAnchor.constraint(equalTo: gestureIconView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - Rules Screen Header Component

/// Header component for game rules screen
final class RulesScreenHeader: UIView {

    // MARK: - Properties

    /// Back button
    private let backButton: UIButton

    /// Title label
    private let titleLabel: UILabel

    /// Back button tap callback
    var onBackButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.backButton = UIButton(type: .system)
        self.titleLabel = UILabel()

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
        titleLabel.text = "GAME RULES"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0).cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.6
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
}

// MARK: - Rules Content Builder

/// Builder class for constructing rules screen content
final class RulesContentBuilder {

    // MARK: - Properties

    /// Content container stack view
    private let contentStack: UIStackView

    // MARK: - Initialization

    init() {
        self.contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
    }

    // MARK: - Builder Methods

    /// Add how to play section
    @discardableResult
    func addHowToPlaySection() -> RulesContentBuilder {
        let card = RulesSectionCard(configuration: .howToPlay)
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Add game modes section
    @discardableResult
    func addGameModesSection() -> RulesContentBuilder {
        let card = RulesSectionCard(configuration: .gameModes)
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Add scoring section
    @discardableResult
    func addScoringSection() -> RulesContentBuilder {
        let card = RulesSectionCard(configuration: .scoring)
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Add pro tips section
    @discardableResult
    func addProTipsSection() -> RulesContentBuilder {
        let card = RulesSectionCard(configuration: .proTips)
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Add controls diagram section
    @discardableResult
    func addControlsDiagram() -> RulesContentBuilder {
        let card = ControlsDiagramCard()
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Add custom rule section
    @discardableResult
    func addCustomSection(configuration: RulesSectionCard.RulesSectionConfiguration) -> RulesContentBuilder {
        let card = RulesSectionCard(configuration: configuration)
        contentStack.addArrangedSubview(card)
        return self
    }

    /// Build and return the content stack
    func build() -> UIStackView {
        return contentStack
    }

    /// Build default rules content
    static func buildDefaultContent() -> UIStackView {
        return RulesContentBuilder()
            .addHowToPlaySection()
            .addGameModesSection()
            .addScoringSection()
            .addProTipsSection()
            .addControlsDiagram()
            .build()
    }
}

// MARK: - Rules Animation Coordinator

/// Coordinator for rules screen entrance animations
final class RulesAnimationCoordinator {

    // MARK: - Public Methods

    /// Prepare views for entrance animation
    func prepareForEntranceAnimation(header: UIView, contentStack: UIStackView) {
        header.alpha = 0
        header.transform = CGAffineTransform(translationX: 0, y: -20)

        for subview in contentStack.arrangedSubviews {
            subview.alpha = 0
            subview.transform = CGAffineTransform(translationX: 0, y: 30)
        }
    }

    /// Execute entrance animation
    func executeEntranceAnimation(header: UIView, contentStack: UIStackView) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5
        ) {
            header.alpha = 1
            header.transform = .identity
        }

        for (index, subview) in contentStack.arrangedSubviews.enumerated() {
            let delay = 0.1 + Double(index) * 0.1

            UIView.animate(
                withDuration: 0.5,
                delay: delay,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5
            ) {
                subview.alpha = 1
                subview.transform = .identity
            }
        }
    }
}
