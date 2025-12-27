//
//  RecordsScreenConfigurators.swift
//  Beamway
//
//  UI configuration components for game records screen
//  Handles backdrop, header, metrics, filters, table, and empty state
//

import UIKit

// MARK: - Backdrop Configurator

/// Configures the background and gradient overlay for records screen
final class RecordsBackdropConfigurator {

    // MARK: - Properties

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView

    // MARK: - Initialization

    init(backdropPictureHolder: UIImageView, maskingPanel: UIView) {
        self.backdropPictureHolder = backdropPictureHolder
        self.maskingPanel = maskingPanel
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureBackdropImage(in: parentView)
        configureGradientOverlay(in: parentView)
    }

    private func configureBackdropImage(in parentView: UIView) {
        if let backgroundImage = UIImage(named: "benImage") {
            backdropPictureHolder.image = backgroundImage
        } else {
            backdropPictureHolder.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        }
        backdropPictureHolder.contentMode = .scaleAspectFill
        backdropPictureHolder.clipsToBounds = true
        parentView.addSubview(backdropPictureHolder)
        backdropPictureHolder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropPictureHolder.topAnchor.constraint(equalTo: parentView.topAnchor),
            backdropPictureHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            backdropPictureHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            backdropPictureHolder.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    private func configureGradientOverlay(in parentView: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.85).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = UIScreen.main.bounds

        maskingPanel.layer.addSublayer(gradientLayer)
        parentView.addSubview(maskingPanel)
        maskingPanel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            maskingPanel.topAnchor.constraint(equalTo: parentView.topAnchor),
            maskingPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            maskingPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            maskingPanel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
}

// MARK: - Header Configurator

/// Configures the header section with title, back button, and delete button
final class RecordsHeaderConfigurator {

    // MARK: - Properties

    private let topSectionPanel: UIView
    private let returnAction: UIButton
    private let headingMarker: UILabel
    private let purgeAction: UIButton

    // MARK: - Initialization

    init(
        topSectionPanel: UIView,
        returnAction: UIButton,
        headingMarker: UILabel,
        purgeAction: UIButton
    ) {
        self.topSectionPanel = topSectionPanel
        self.returnAction = returnAction
        self.headingMarker = headingMarker
        self.purgeAction = purgeAction
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureTopSectionPanel(in: parentView)
        configureBackButton()
        configureHeadingLabel()
        configurePurgeButton()
        setupConstraints(in: parentView)
    }

    private func configureTopSectionPanel(in parentView: UIView) {
        topSectionPanel.backgroundColor = .clear
        parentView.addSubview(topSectionPanel)
        topSectionPanel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureBackButton() {
        returnAction.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        returnAction.tintColor = .white
        returnAction.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        returnAction.layer.cornerRadius = 22
        returnAction.layer.borderWidth = 1
        returnAction.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        topSectionPanel.addSubview(returnAction)
        returnAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureHeadingLabel() {
        headingMarker.text = "RECORDS"
        headingMarker.textColor = .white
        headingMarker.font = UIFont.systemFont(ofSize: 28, weight: .black)
        headingMarker.textAlignment = .center
        headingMarker.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        headingMarker.layer.shadowOffset = .zero
        headingMarker.layer.shadowRadius = 15
        headingMarker.layer.shadowOpacity = 0.6
        topSectionPanel.addSubview(headingMarker)
        headingMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configurePurgeButton() {
        purgeAction.setImage(UIImage(systemName: "trash"), for: .normal)
        purgeAction.tintColor = UIColor.systemRed
        purgeAction.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        purgeAction.layer.cornerRadius = 22
        purgeAction.layer.borderWidth = 1
        purgeAction.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        topSectionPanel.addSubview(purgeAction)
        purgeAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            topSectionPanel.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            topSectionPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            topSectionPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            topSectionPanel.heightAnchor.constraint(equalToConstant: 60),

            returnAction.leadingAnchor.constraint(equalTo: topSectionPanel.leadingAnchor, constant: 20),
            returnAction.centerYAnchor.constraint(equalTo: topSectionPanel.centerYAnchor),
            returnAction.widthAnchor.constraint(equalToConstant: 44),
            returnAction.heightAnchor.constraint(equalToConstant: 44),

            headingMarker.centerXAnchor.constraint(equalTo: topSectionPanel.centerXAnchor),
            headingMarker.centerYAnchor.constraint(equalTo: topSectionPanel.centerYAnchor),

            purgeAction.trailingAnchor.constraint(equalTo: topSectionPanel.trailingAnchor, constant: -20),
            purgeAction.centerYAnchor.constraint(equalTo: topSectionPanel.centerYAnchor),
            purgeAction.widthAnchor.constraint(equalToConstant: 44),
            purgeAction.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// MARK: - Metrics Summary Configurator

/// Configures the metrics summary panel with stats display
final class RecordsMetricsSummaryConfigurator {

    // MARK: - Tags for Value Labels

    struct MetricsTags {
        static let totalGames: Int = 100
        static let highScore: Int = 101
        static let bestTime: Int = 102
    }

    // MARK: - Properties

    private let metricsSummaryPanel: UIView

    // MARK: - Initialization

    init(metricsSummaryPanel: UIView) {
        self.metricsSummaryPanel = metricsSummaryPanel
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        configurePanel(in: parentView)
        configureStatsStack()
        setupConstraints(in: parentView, belowView: belowView)
    }

    private func configurePanel(in parentView: UIView) {
        metricsSummaryPanel.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        metricsSummaryPanel.layer.cornerRadius = 20
        metricsSummaryPanel.layer.borderWidth = 1
        metricsSummaryPanel.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.3).cgColor
        parentView.addSubview(metricsSummaryPanel)
        metricsSummaryPanel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureStatsStack() {
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 0
        metricsSummaryPanel.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        // Total Games Stat
        let totalGamesView = MetricPanelBuilder.build(
            icon: "gamecontroller.fill",
            iconColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0),
            value: "0",
            label: "Games",
            valueTag: MetricsTags.totalGames
        )
        statsStack.addArrangedSubview(totalGamesView)

        // Divider
        let divider1 = SeparatorBuilder.buildVerticalSeparator()
        statsStack.addArrangedSubview(divider1)

        // High Score Stat
        let highScoreView = MetricPanelBuilder.build(
            icon: "trophy.fill",
            iconColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            value: "0",
            label: "Best",
            valueTag: MetricsTags.highScore
        )
        statsStack.addArrangedSubview(highScoreView)

        // Divider
        let divider2 = SeparatorBuilder.buildVerticalSeparator()
        statsStack.addArrangedSubview(divider2)

        // Best Time Stat
        let bestTimeView = MetricPanelBuilder.build(
            icon: "clock.fill",
            iconColor: UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0),
            value: "0:00",
            label: "Time",
            valueTag: MetricsTags.bestTime
        )
        statsStack.addArrangedSubview(bestTimeView)

        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: metricsSummaryPanel.topAnchor),
            statsStack.leadingAnchor.constraint(equalTo: metricsSummaryPanel.leadingAnchor),
            statsStack.trailingAnchor.constraint(equalTo: metricsSummaryPanel.trailingAnchor),
            statsStack.bottomAnchor.constraint(equalTo: metricsSummaryPanel.bottomAnchor)
        ])
    }

    private func setupConstraints(in parentView: UIView, belowView: UIView) {
        NSLayoutConstraint.activate([
            metricsSummaryPanel.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 15),
            metricsSummaryPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            metricsSummaryPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            metricsSummaryPanel.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// MARK: - Metric Panel Builder

/// Builder for individual metric display panels
final class MetricPanelBuilder {

    static func build(
        icon: String,
        iconColor: UIColor,
        value: String,
        label: String,
        valueTag: Int
    ) -> UIView {
        let container = UIView()

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.tag = valueTag
        container.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let labelView = UILabel()
        labelView.text = label
        labelView.textColor = UIColor.white.withAlphaComponent(0.5)
        labelView.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        labelView.textAlignment = .center
        container.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            labelView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            labelView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        return container
    }
}

// MARK: - Separator Builder

/// Builder for separator views
final class SeparatorBuilder {

    static func buildVerticalSeparator() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    static func buildHorizontalSeparator(height: CGFloat = 1) -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        divider.heightAnchor.constraint(equalToConstant: height).isActive = true
        return divider
    }
}

// MARK: - Category Filter Configurator

/// Configures the category filter buttons
final class RecordsCategoryFilterConfigurator {

    // MARK: - Properties

    private let categoryFilterHolder: UIView
    private let entireAction: UIButton
    private let soloAction: UIButton
    private let competitiveAction: UIButton

    // MARK: - Initialization

    init(
        categoryFilterHolder: UIView,
        entireAction: UIButton,
        soloAction: UIButton,
        competitiveAction: UIButton
    ) {
        self.categoryFilterHolder = categoryFilterHolder
        self.entireAction = entireAction
        self.soloAction = soloAction
        self.competitiveAction = competitiveAction
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        configureHolder(in: parentView)
        configureFilterButtons()
        setupConstraints(in: parentView, belowView: belowView)
    }

    private func configureHolder(in parentView: UIView) {
        categoryFilterHolder.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        categoryFilterHolder.layer.cornerRadius = 15
        parentView.addSubview(categoryFilterHolder)
        categoryFilterHolder.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureFilterButtons() {
        let filterStack = UIStackView(arrangedSubviews: [entireAction, soloAction, competitiveAction])
        filterStack.axis = .horizontal
        filterStack.distribution = .fillEqually
        filterStack.spacing = 8
        categoryFilterHolder.addSubview(filterStack)
        filterStack.translatesAutoresizingMaskIntoConstraints = false

        CategoryFilterButtonStyler.configure(entireAction, title: "All", isSelected: true)
        CategoryFilterButtonStyler.configure(soloAction, title: "Single", isSelected: false)
        CategoryFilterButtonStyler.configure(competitiveAction, title: "Challenge", isSelected: false)

        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: categoryFilterHolder.topAnchor, constant: 8),
            filterStack.leadingAnchor.constraint(equalTo: categoryFilterHolder.leadingAnchor, constant: 8),
            filterStack.trailingAnchor.constraint(equalTo: categoryFilterHolder.trailingAnchor, constant: -8),
            filterStack.bottomAnchor.constraint(equalTo: categoryFilterHolder.bottomAnchor, constant: -8)
        ])
    }

    private func setupConstraints(in parentView: UIView, belowView: UIView) {
        NSLayoutConstraint.activate([
            categoryFilterHolder.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 15),
            categoryFilterHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            categoryFilterHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            categoryFilterHolder.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - Category Filter Button Styler

/// Styles category filter buttons
final class CategoryFilterButtonStyler {

    static let selectedBackgroundColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
    static let selectedTextColor = UIColor.white
    static let unselectedTextColor = UIColor.white.withAlphaComponent(0.6)

    static func configure(_ button: UIButton, title: String, isSelected: Bool) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 12

        applyStyle(to: button, isSelected: isSelected)
    }

    static func applyStyle(to button: UIButton, isSelected: Bool) {
        if isSelected {
            button.setTitleColor(selectedTextColor, for: .normal)
            button.backgroundColor = selectedBackgroundColor
        } else {
            button.setTitleColor(unselectedTextColor, for: .normal)
            button.backgroundColor = .clear
        }
    }
}

// MARK: - Category Filter State Updater

/// Updates category filter button states
final class CategoryFilterStateUpdater {

    // MARK: - Properties

    private let entireAction: UIButton
    private let soloAction: UIButton
    private let competitiveAction: UIButton

    // MARK: - Initialization

    init(entireAction: UIButton, soloAction: UIButton, competitiveAction: UIButton) {
        self.entireAction = entireAction
        self.soloAction = soloAction
        self.competitiveAction = competitiveAction
    }

    // MARK: - Public Methods

    func updateStates(selectedFilter: String) {
        let buttons = [entireAction, soloAction, competitiveAction]
        let titles = ["All", "Single", "Challenge"]

        for (index, button) in buttons.enumerated() {
            let isSelected = titles[index] == selectedFilter
            CategoryFilterButtonStyler.applyStyle(to: button, isSelected: isSelected)
        }
    }
}

// MARK: - Records Table Configurator

/// Configures the records table view
final class RecordsTableConfigurator {

    // MARK: - Properties

    private let historyList: UITableView

    // MARK: - Initialization

    init(historyList: UITableView) {
        self.historyList = historyList
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        historyList.backgroundColor = .clear
        historyList.separatorStyle = .none
        historyList.showsVerticalScrollIndicator = false
        parentView.addSubview(historyList)
        historyList.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            historyList.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 15),
            historyList.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            historyList.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            historyList.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Vacant State Configurator

/// Configures the empty state view
final class RecordsVacantStateConfigurator {

    // MARK: - Properties

    private let vacantStatePanel: UIView
    private let vacantSymbol: UIImageView
    private let vacantMarker: UILabel

    // MARK: - Initialization

    init(vacantStatePanel: UIView, vacantSymbol: UIImageView, vacantMarker: UILabel) {
        self.vacantStatePanel = vacantStatePanel
        self.vacantSymbol = vacantSymbol
        self.vacantMarker = vacantMarker
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, centeredIn referenceView: UIView) {
        vacantStatePanel.isHidden = true
        parentView.addSubview(vacantStatePanel)
        vacantStatePanel.translatesAutoresizingMaskIntoConstraints = false

        configureSymbol()
        configureMarker()
        setupConstraints(centeredIn: referenceView)
    }

    private func configureSymbol() {
        vacantSymbol.image = UIImage(systemName: "tray")
        vacantSymbol.tintColor = UIColor.white.withAlphaComponent(0.3)
        vacantSymbol.contentMode = .scaleAspectFit
        vacantStatePanel.addSubview(vacantSymbol)
        vacantSymbol.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureMarker() {
        vacantMarker.text = "No records yet\nPlay a game to see your scores!"
        vacantMarker.textColor = UIColor.white.withAlphaComponent(0.5)
        vacantMarker.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        vacantMarker.textAlignment = .center
        vacantMarker.numberOfLines = 0
        vacantStatePanel.addSubview(vacantMarker)
        vacantMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(centeredIn referenceView: UIView) {
        NSLayoutConstraint.activate([
            vacantStatePanel.centerXAnchor.constraint(equalTo: referenceView.centerXAnchor),
            vacantStatePanel.centerYAnchor.constraint(equalTo: referenceView.centerYAnchor),

            vacantSymbol.topAnchor.constraint(equalTo: vacantStatePanel.topAnchor),
            vacantSymbol.centerXAnchor.constraint(equalTo: vacantStatePanel.centerXAnchor),
            vacantSymbol.widthAnchor.constraint(equalToConstant: 60),
            vacantSymbol.heightAnchor.constraint(equalToConstant: 60),

            vacantMarker.topAnchor.constraint(equalTo: vacantSymbol.bottomAnchor, constant: 16),
            vacantMarker.centerXAnchor.constraint(equalTo: vacantStatePanel.centerXAnchor),
            vacantMarker.bottomAnchor.constraint(equalTo: vacantStatePanel.bottomAnchor)
        ])
    }
}
