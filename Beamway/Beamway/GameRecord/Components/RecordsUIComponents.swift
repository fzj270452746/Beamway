//
//  RecordsUIComponents.swift
//  Beamway
//
//  Reusable UI components for game records screen
//

import UIKit

// MARK: - Session Record Cell Component

/// Table view cell for displaying a single game session record
final class SessionRecordTableCell: UITableViewCell {

    // MARK: - Static Properties

    /// Cell reuse identifier
    static let reuseIdentifier = "SessionRecordTableCell"

    // MARK: - Properties

    /// Container card view
    private let cardContainerView: UIView

    /// Score icon view
    private let scoreIconView: UIImageView

    /// Score value label
    private let scoreValueLabel: UILabel

    /// Game mode label
    private let gameModeLabel: UILabel

    /// Duration label
    private let durationLabel: UILabel

    /// Date label
    private let dateLabel: UILabel

    /// Stats container stack
    private let statsStackView: UIStackView

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cardContainerView = UIView()
        self.scoreIconView = UIImageView()
        self.scoreValueLabel = UILabel()
        self.gameModeLabel = UILabel()
        self.durationLabel = UILabel()
        self.dateLabel = UILabel()
        self.statsStackView = UIStackView()
        self.visualTheme = VisualThemeConfiguration.shared

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureCellAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure cell appearance
    private func configureCellAppearance() {
        backgroundColor = .clear
        selectionStyle = .none

        configureCardContainer()
        configureScoreSection()
        configureInfoSection()
        setupConstraints()
    }

    /// Configure card container
    private func configureCardContainer() {
        cardContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        cardContainerView.layer.cornerRadius = 15
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentView.addSubview(cardContainerView)
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure score section
    private func configureScoreSection() {
        scoreIconView.image = UIImage(systemName: "star.fill")
        scoreIconView.tintColor = visualTheme.colorPalette.goldHighlightTint
        scoreIconView.contentMode = .scaleAspectFit
        cardContainerView.addSubview(scoreIconView)
        scoreIconView.translatesAutoresizingMaskIntoConstraints = false

        scoreValueLabel.textColor = .white
        scoreValueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cardContainerView.addSubview(scoreValueLabel)
        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure info section
    private func configureInfoSection() {
        gameModeLabel.textColor = visualTheme.colorPalette.primaryNeonCyan
        gameModeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        cardContainerView.addSubview(gameModeLabel)
        gameModeLabel.translatesAutoresizingMaskIntoConstraints = false

        durationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cardContainerView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel.textAlignment = .right
        cardContainerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            scoreIconView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 15),
            scoreIconView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            scoreIconView.widthAnchor.constraint(equalToConstant: 24),
            scoreIconView.heightAnchor.constraint(equalToConstant: 24),

            scoreValueLabel.leadingAnchor.constraint(equalTo: scoreIconView.trailingAnchor, constant: 10),
            scoreValueLabel.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),

            gameModeLabel.leadingAnchor.constraint(equalTo: scoreValueLabel.trailingAnchor, constant: 20),
            gameModeLabel.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 15),

            durationLabel.leadingAnchor.constraint(equalTo: gameModeLabel.leadingAnchor),
            durationLabel.topAnchor.constraint(equalTo: gameModeLabel.bottomAnchor, constant: 4),

            dateLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -15),
            dateLabel.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Configure cell with session record data
    func configure(with record: SessionResultDataModel) {
        scoreValueLabel.text = "\(record.sessionScoreValue)"
        gameModeLabel.text = record.playedGameCategory.displayName
        durationLabel.text = record.formattedSessionDuration

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: record.sessionRecordedDate)
    }

    /// Configure cell with legacy history data
    func configure(score: Int, mode: String, date: Date) {
        scoreValueLabel.text = "\(score)"
        gameModeLabel.text = mode
        durationLabel.text = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: date)
    }
}

// MARK: - Statistics Summary Card Component

/// Card component displaying aggregate statistics summary
final class StatisticsSummaryCard: UIView {

    // MARK: - Properties

    /// Title label
    private let titleLabel: UILabel

    /// Stats rows container
    private let statsContainer: UIStackView

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        self.statsContainer = UIStackView()
        self.visualTheme = VisualThemeConfiguration.shared

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
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        configureTitleLabel()
        configureStatsContainer()
        setupConstraints()
    }

    /// Configure title label
    private func configureTitleLabel() {
        titleLabel.text = "Statistics"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure stats container
    private func configureStatsContainer() {
        statsContainer.axis = .vertical
        statsContainer.spacing = 12
        addSubview(statsContainer)
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Setup layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            statsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            statsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            statsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            statsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }

    // MARK: - Public Methods

    /// Update statistics display
    func updateStatistics(_ summary: SessionStatisticsSummary) {
        statsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        addStatRow(icon: "gamecontroller.fill", title: "Total Games", value: "\(summary.totalSessionsPlayed)")
        addStatRow(icon: "trophy.fill", title: "Highest Score", value: "\(summary.overallHighestScore)")
        addStatRow(icon: "clock.fill", title: "Total Play Time", value: formatDuration(summary.aggregatePlayDuration))
        addStatRow(icon: "flame.fill", title: "Best Combo", value: "x\(summary.overallPeakCombo)")
        addStatRow(icon: "chart.line.uptrend.xyaxis", title: "Average Score", value: String(format: "%.1f", summary.averageScoreValue))
    }

    /// Add stat row to container
    private func addStatRow(icon: String, title: String, value: String) {
        let rowView = StatisticsRowView(iconName: icon, title: title, value: value)
        statsContainer.addArrangedSubview(rowView)
    }

    /// Format duration to readable string
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Statistics Row View

/// Single row displaying a statistic with icon, title, and value
final class StatisticsRowView: UIView {

    // MARK: - Properties

    /// Icon image view
    private let iconView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Value label
    private let valueLabel: UILabel

    // MARK: - Initialization

    init(iconName: String, title: String, value: String) {
        self.iconView = UIImageView()
        self.titleLabel = UILabel()
        self.valueLabel = UILabel()

        super.init(frame: .zero)

        configureRowAppearance(iconName: iconName, title: title, value: value)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure row appearance
    private func configureRowAppearance(iconName: String, title: String, value: String) {
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = VisualThemeConfiguration.shared.colorPalette.primaryNeonCyan
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        valueLabel.textAlignment = .right
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Filter Segment Control Component

/// Segmented control for filtering records by category
final class RecordsFilterSegmentControl: UIView {

    // MARK: - Type Definitions

    /// Filter option enumeration
    enum FilterOption: Int, CaseIterable {
        case all = 0
        case singleMode = 1
        case challengeMode = 2

        var displayTitle: String {
            switch self {
            case .all:
                return "All"
            case .singleMode:
                return "Single"
            case .challengeMode:
                return "Challenge"
            }
        }
    }

    // MARK: - Properties

    /// Segment buttons
    private var segmentButtons: [UIButton] = []

    /// Selection indicator view
    private let selectionIndicator: UIView

    /// Currently selected filter
    private(set) var selectedFilter: FilterOption = .all

    /// Filter changed callback
    var onFilterChanged: ((FilterOption) -> Void)?

    /// Selection indicator leading constraint
    private var indicatorLeadingConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.selectionIndicator = UIView()

        super.init(frame: frame)

        configureControlAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure control appearance
    private func configureControlAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 12

        configureSelectionIndicator()
        configureSegmentButtons()
        setupConstraints()
    }

    /// Configure selection indicator
    private func configureSelectionIndicator() {
        selectionIndicator.backgroundColor = VisualThemeConfiguration.shared.colorPalette.primaryNeonCyan.withAlphaComponent(0.3)
        selectionIndicator.layer.cornerRadius = 10
        addSubview(selectionIndicator)
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Configure segment buttons
    private func configureSegmentButtons() {
        for option in FilterOption.allCases {
            let button = UIButton(type: .system)
            button.setTitle(option.displayTitle, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            button.tag = option.rawValue
            button.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            segmentButtons.append(button)
        }

        updateButtonAppearance()
    }

    /// Setup layout constraints
    private func setupConstraints() {
        guard segmentButtons.count == 3 else { return }

        let segmentWidth = 1.0 / CGFloat(segmentButtons.count)

        indicatorLeadingConstraint = selectionIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
        indicatorLeadingConstraint?.isActive = true

        NSLayoutConstraint.activate([
            selectionIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            selectionIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            selectionIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: segmentWidth, constant: -8)
        ])

        for (index, button) in segmentButtons.enumerated() {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor),
                button.bottomAnchor.constraint(equalTo: bottomAnchor),
                button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: segmentWidth)
            ])

            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: segmentButtons[index - 1].trailingAnchor).isActive = true
            }
        }
    }

    // MARK: - Actions

    @objc private func segmentButtonTapped(_ sender: UIButton) {
        guard let newFilter = FilterOption(rawValue: sender.tag) else { return }

        selectFilter(newFilter, animated: true)
        onFilterChanged?(newFilter)
    }

    // MARK: - Public Methods

    /// Select filter programmatically
    func selectFilter(_ filter: FilterOption, animated: Bool = true) {
        selectedFilter = filter
        updateSelectionIndicatorPosition(animated: animated)
        updateButtonAppearance()
    }

    /// Update selection indicator position
    private func updateSelectionIndicatorPosition(animated: Bool) {
        let segmentWidth = bounds.width / CGFloat(segmentButtons.count)
        let newLeading = segmentWidth * CGFloat(selectedFilter.rawValue) + 4

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.indicatorLeadingConstraint?.constant = newLeading
                self.layoutIfNeeded()
            }
        } else {
            indicatorLeadingConstraint?.constant = newLeading
        }
    }

    /// Update button appearance based on selection
    private func updateButtonAppearance() {
        for (index, button) in segmentButtons.enumerated() {
            if index == selectedFilter.rawValue {
                button.setTitleColor(.white, for: .normal)
            } else {
                button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
            }
        }
    }
}

// MARK: - Empty State View Component

/// View displayed when no records are available
final class EmptyRecordsStateView: UIView {

    // MARK: - Properties

    /// Icon image view
    private let iconView: UIImageView

    /// Title label
    private let titleLabel: UILabel

    /// Subtitle label
    private let subtitleLabel: UILabel

    /// Action button
    private let actionButton: UIButton

    /// Action button tap callback
    var onActionButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.iconView = UIImageView()
        self.titleLabel = UILabel()
        self.subtitleLabel = UILabel()
        self.actionButton = UIButton(type: .system)

        super.init(frame: frame)

        configureViewAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure view appearance
    private func configureViewAppearance() {
        iconView.image = UIImage(systemName: "list.star")
        iconView.tintColor = UIColor.white.withAlphaComponent(0.3)
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "No Records Yet"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "Play some games to see your records here!"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        actionButton.setTitle("Start Playing", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        actionButton.backgroundColor = VisualThemeConfiguration.shared.colorPalette.primaryNeonCyan
        actionButton.layer.cornerRadius = 20
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            actionButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 25),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    // MARK: - Actions

    @objc private func actionButtonTapped() {
        onActionButtonTapped?()
    }
}
