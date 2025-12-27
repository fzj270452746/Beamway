//
//  RulesContentBuilder.swift
//  Beamway
//
//  Content builder for game rules screen
//  Constructs rule cards and content sections
//

import UIKit

// MARK: - Guidelines Content Builder

/// Builder for constructing rules screen content sections
final class GuidelinesContentBuilder {

    // MARK: - Section Definitions

    /// Definition for a rules section
    struct RulesSectionDefinition {
        let icon: String
        let iconColor: UIColor
        let title: String
        let rules: [String]
    }

    /// Predefined section definitions
    struct PredefinedSections {
        static let howToPlay = RulesSectionDefinition(
            icon: "gamecontroller.fill",
            iconColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0),
            title: "HOW TO PLAY",
            rules: [
                "Drag mahjong tiles to dodge incoming arrows",
                "Arrows come from all four sides of the screen",
                "Each dodged arrow gives you 1 point",
                "You have 3 lives - don't get hit!"
            ]
        )

        static let gameModes = RulesSectionDefinition(
            icon: "switch.2",
            iconColor: UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0),
            title: "GAME MODES",
            rules: [
                "Single Mode: Control one tile throughout",
                "Challenge Mode: Control multiple tiles",
                "Difficulty increases as you progress",
                "Higher scores unlock achievements"
            ]
        )

        static let scoring = RulesSectionDefinition(
            icon: "star.fill",
            iconColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            title: "SCORING",
            rules: [
                "+1 point for each dodged arrow",
                "Build combos for extra excitement",
                "Level up every 10 points in Challenge",
                "Records are saved automatically"
            ]
        )

        static let proTips = RulesSectionDefinition(
            icon: "lightbulb.fill",
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

    // MARK: - Public Methods

    /// Build all content sections
    func buildAllSections() -> [UIView] {
        var sections: [UIView] = []

        sections.append(buildGuidelineCard(from: PredefinedSections.howToPlay))
        sections.append(buildGuidelineCard(from: PredefinedSections.gameModes))
        sections.append(buildGuidelineCard(from: PredefinedSections.scoring))
        sections.append(buildGuidelineCard(from: PredefinedSections.proTips))
        sections.append(buildControlsDiagram())

        return sections
    }

    /// Build a single guideline card from definition
    func buildGuidelineCard(from definition: RulesSectionDefinition) -> UIView {
        return GuidelineCardBuilder.build(
            icon: definition.icon,
            iconColor: definition.iconColor,
            title: definition.title,
            rules: definition.rules
        )
    }

    /// Build the controls diagram section
    func buildControlsDiagram() -> UIView {
        return ControlsDiagramBuilder.build()
    }
}

// MARK: - Guideline Card Builder

/// Builder for individual guideline card views
final class GuidelineCardBuilder {

    // MARK: - Configuration

    struct CardConfiguration {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let backgroundAlpha: CGFloat = 0.08
        static let iconSize: CGFloat = 24
        static let contentPadding: CGFloat = 18
        static let rulesSpacing: CGFloat = 12
    }

    // MARK: - Public Methods

    /// Build a complete guideline card
    static func build(
        icon: String,
        iconColor: UIColor,
        title: String,
        rules: [String]
    ) -> UIView {
        let cardView = createCardContainer(borderColor: iconColor)
        let iconView = createIconView(icon: icon, color: iconColor)
        let titleLabel = createTitleLabel(title: title)
        let rulesStack = createRulesStack(rules: rules, bulletColor: iconColor)

        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(rulesStack)

        setupConstraints(
            cardView: cardView,
            iconView: iconView,
            titleLabel: titleLabel,
            rulesStack: rulesStack
        )

        return cardView
    }

    // MARK: - Private Methods

    private static func createCardContainer(borderColor: UIColor) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.white.withAlphaComponent(CardConfiguration.backgroundAlpha)
        cardView.layer.cornerRadius = CardConfiguration.cornerRadius
        cardView.layer.borderWidth = CardConfiguration.borderWidth
        cardView.layer.borderColor = borderColor.withAlphaComponent(0.3).cgColor
        return cardView
    }

    private static func createIconView(icon: String, color: UIColor) -> UIImageView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        return iconView
    }

    private static func createTitleLabel(title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createRulesStack(rules: [String], bulletColor: UIColor) -> UIStackView {
        let rulesStack = UIStackView()
        rulesStack.axis = .vertical
        rulesStack.spacing = CardConfiguration.rulesSpacing
        rulesStack.translatesAutoresizingMaskIntoConstraints = false

        for rule in rules {
            let ruleView = RuleEntryBuilder.build(text: rule, bulletColor: bulletColor)
            rulesStack.addArrangedSubview(ruleView)
        }

        return rulesStack
    }

    private static func setupConstraints(
        cardView: UIView,
        iconView: UIImageView,
        titleLabel: UILabel,
        rulesStack: UIStackView
    ) {
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: CardConfiguration.contentPadding
            ),
            iconView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: CardConfiguration.contentPadding
            ),
            iconView.widthAnchor.constraint(equalToConstant: CardConfiguration.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: CardConfiguration.iconSize),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            rulesStack.topAnchor.constraint(
                equalTo: iconView.bottomAnchor,
                constant: CardConfiguration.contentPadding
            ),
            rulesStack.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: CardConfiguration.contentPadding
            ),
            rulesStack.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -CardConfiguration.contentPadding
            ),
            rulesStack.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -CardConfiguration.contentPadding
            )
        ])
    }
}

// MARK: - Rule Entry Builder

/// Builder for individual rule entry rows
final class RuleEntryBuilder {

    // MARK: - Configuration

    struct EntryConfiguration {
        static let bulletSize: CGFloat = 8
        static let bulletCornerRadius: CGFloat = 4
        static let bulletTopOffset: CGFloat = 6
        static let textSpacing: CGFloat = 12
    }

    // MARK: - Public Methods

    /// Build a single rule entry with bullet point
    static func build(text: String, bulletColor: UIColor) -> UIView {
        let rowView = UIView()

        let bulletView = createBulletView(color: bulletColor)
        let textLabel = createTextLabel(text: text)

        rowView.addSubview(bulletView)
        rowView.addSubview(textLabel)

        setupConstraints(rowView: rowView, bulletView: bulletView, textLabel: textLabel)

        return rowView
    }

    // MARK: - Private Methods

    private static func createBulletView(color: UIColor) -> UIView {
        let bulletView = UIView()
        bulletView.backgroundColor = color
        bulletView.layer.cornerRadius = EntryConfiguration.bulletCornerRadius
        bulletView.translatesAutoresizingMaskIntoConstraints = false
        return bulletView
    }

    private static func createTextLabel(text: String) -> UILabel {
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }

    private static func setupConstraints(
        rowView: UIView,
        bulletView: UIView,
        textLabel: UILabel
    ) {
        NSLayoutConstraint.activate([
            bulletView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            bulletView.topAnchor.constraint(
                equalTo: rowView.topAnchor,
                constant: EntryConfiguration.bulletTopOffset
            ),
            bulletView.widthAnchor.constraint(equalToConstant: EntryConfiguration.bulletSize),
            bulletView.heightAnchor.constraint(equalToConstant: EntryConfiguration.bulletSize),

            textLabel.leadingAnchor.constraint(
                equalTo: bulletView.trailingAnchor,
                constant: EntryConfiguration.textSpacing
            ),
            textLabel.topAnchor.constraint(equalTo: rowView.topAnchor),
            textLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
        ])
    }
}

// MARK: - Controls Diagram Builder

/// Builder for the controls diagram section
final class ControlsDiagramBuilder {

    // MARK: - Configuration

    struct DiagramConfiguration {
        static let cardHeight: CGFloat = 120
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let backgroundAlpha: CGFloat = 0.05
        static let iconSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 18
    }

    // MARK: - Public Methods

    /// Build the controls diagram card
    static func build() -> UIView {
        let cardView = createCardContainer()
        let titleLabel = createTitleLabel()
        let gestureIcon = createGestureIcon()
        let descriptionLabel = createDescriptionLabel()

        cardView.addSubview(titleLabel)
        cardView.addSubview(gestureIcon)
        cardView.addSubview(descriptionLabel)

        setupConstraints(
            cardView: cardView,
            titleLabel: titleLabel,
            gestureIcon: gestureIcon,
            descriptionLabel: descriptionLabel
        )

        return cardView
    }

    // MARK: - Private Methods

    private static func createCardContainer() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.white.withAlphaComponent(DiagramConfiguration.backgroundAlpha)
        cardView.layer.cornerRadius = DiagramConfiguration.cornerRadius
        cardView.layer.borderWidth = DiagramConfiguration.borderWidth
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return cardView
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "CONTROLS"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createGestureIcon() -> UIImageView {
        let gestureIcon = UIImageView(image: UIImage(systemName: "hand.draw.fill"))
        gestureIcon.tintColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
        gestureIcon.contentMode = .scaleAspectFit
        gestureIcon.translatesAutoresizingMaskIntoConstraints = false
        return gestureIcon
    }

    private static func createDescriptionLabel() -> UILabel {
        let descLabel = UILabel()
        descLabel.text = "Drag tiles with your finger to move them around the play area"
        descLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        descLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        return descLabel
    }

    private static func setupConstraints(
        cardView: UIView,
        titleLabel: UILabel,
        gestureIcon: UIImageView,
        descriptionLabel: UILabel
    ) {
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: DiagramConfiguration.cardHeight),

            titleLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: DiagramConfiguration.topPadding
            ),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            gestureIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            gestureIcon.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            gestureIcon.widthAnchor.constraint(equalToConstant: DiagramConfiguration.iconSize),
            gestureIcon.heightAnchor.constraint(equalToConstant: DiagramConfiguration.iconSize),

            descriptionLabel.topAnchor.constraint(equalTo: gestureIcon.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: DiagramConfiguration.horizontalPadding
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -DiagramConfiguration.horizontalPadding
            )
        ])
    }
}

// MARK: - Section Type Enumeration

/// Enumeration of available rules section types
enum RulesSectionType: CaseIterable {
    case howToPlay
    case gameModes
    case scoring
    case proTips
    case controls

    var definition: GuidelinesContentBuilder.RulesSectionDefinition? {
        switch self {
        case .howToPlay:
            return GuidelinesContentBuilder.PredefinedSections.howToPlay
        case .gameModes:
            return GuidelinesContentBuilder.PredefinedSections.gameModes
        case .scoring:
            return GuidelinesContentBuilder.PredefinedSections.scoring
        case .proTips:
            return GuidelinesContentBuilder.PredefinedSections.proTips
        case .controls:
            return nil // Controls has special handling
        }
    }
}
