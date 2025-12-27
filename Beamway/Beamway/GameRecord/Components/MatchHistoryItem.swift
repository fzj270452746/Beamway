//
//  MatchHistoryItem.swift
//  Beamway
//
//  Table view cell for displaying match history records
//  Shows rank, score, mode, and date with visual styling
//

import UIKit

// MARK: - Match History Item Cell

/// Custom table view cell for displaying game records
class MatchHistoryItem: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "MatchHistoryItem"
    static let preferredHeight: CGFloat = 85

    // MARK: - Configuration

    struct CellConfiguration {
        static let holderCornerRadius: CGFloat = 16
        static let holderBorderWidth: CGFloat = 1
        static let holderBackgroundAlpha: CGFloat = 0.08
        static let holderBorderAlpha: CGFloat = 0.1
        static let verticalPadding: CGFloat = 5
    }

    struct RankConfiguration {
        static let rankWidth: CGFloat = 30
        static let trophySize: CGFloat = 24
    }

    struct ColorConfiguration {
        static let goldColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        static let silverColor = UIColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1.0)
        static let bronzeColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        static let singleModeColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        static let challengeModeColor = UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
        static let defaultCategoryColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
    }

    // MARK: - UI Components

    private let holderPanel: UIView
    private let positionMarker: UILabel
    private let pointsMarker: UILabel
    private let categoryMarker: UILabel
    private let timestampMarker: UILabel
    private let medallionSymbol: UIImageView

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        holderPanel = UIView()
        positionMarker = UILabel()
        pointsMarker = UILabel()
        categoryMarker = UILabel()
        timestampMarker = UILabel()
        medallionSymbol = UIImageView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureCellLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Configuration

    private func configureCellLayout() {
        configureBaseAppearance()
        configureHolderPanel()
        configureRankViews()
        configurePointsMarker()
        configureCategoryMarker()
        configureTimestampMarker()
        setupLayoutConstraints()
    }

    private func configureBaseAppearance() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    private func configureHolderPanel() {
        holderPanel.backgroundColor = UIColor.white.withAlphaComponent(CellConfiguration.holderBackgroundAlpha)
        holderPanel.layer.cornerRadius = CellConfiguration.holderCornerRadius
        holderPanel.layer.borderWidth = CellConfiguration.holderBorderWidth
        holderPanel.layer.borderColor = UIColor.white.withAlphaComponent(CellConfiguration.holderBorderAlpha).cgColor
        contentView.addSubview(holderPanel)
        holderPanel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureRankViews() {
        // Position label
        positionMarker.textColor = UIColor.white.withAlphaComponent(0.5)
        positionMarker.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        positionMarker.textAlignment = .center
        holderPanel.addSubview(positionMarker)
        positionMarker.translatesAutoresizingMaskIntoConstraints = false

        // Trophy icon for top 3
        medallionSymbol.contentMode = .scaleAspectFit
        medallionSymbol.isHidden = true
        holderPanel.addSubview(medallionSymbol)
        medallionSymbol.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configurePointsMarker() {
        pointsMarker.textColor = .white
        pointsMarker.font = UIFont.systemFont(ofSize: 28, weight: .black)
        holderPanel.addSubview(pointsMarker)
        pointsMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureCategoryMarker() {
        categoryMarker.textColor = ColorConfiguration.defaultCategoryColor
        categoryMarker.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        holderPanel.addSubview(categoryMarker)
        categoryMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTimestampMarker() {
        timestampMarker.textColor = UIColor.white.withAlphaComponent(0.4)
        timestampMarker.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        holderPanel.addSubview(timestampMarker)
        timestampMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            holderPanel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellConfiguration.verticalPadding),
            holderPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            holderPanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            holderPanel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellConfiguration.verticalPadding),

            positionMarker.leadingAnchor.constraint(equalTo: holderPanel.leadingAnchor, constant: 16),
            positionMarker.centerYAnchor.constraint(equalTo: holderPanel.centerYAnchor),
            positionMarker.widthAnchor.constraint(equalToConstant: RankConfiguration.rankWidth),

            medallionSymbol.leadingAnchor.constraint(equalTo: holderPanel.leadingAnchor, constant: 16),
            medallionSymbol.centerYAnchor.constraint(equalTo: holderPanel.centerYAnchor),
            medallionSymbol.widthAnchor.constraint(equalToConstant: RankConfiguration.trophySize),
            medallionSymbol.heightAnchor.constraint(equalToConstant: RankConfiguration.trophySize),

            pointsMarker.leadingAnchor.constraint(equalTo: positionMarker.trailingAnchor, constant: 12),
            pointsMarker.centerYAnchor.constraint(equalTo: holderPanel.centerYAnchor, constant: -6),

            categoryMarker.leadingAnchor.constraint(equalTo: pointsMarker.leadingAnchor),
            categoryMarker.topAnchor.constraint(equalTo: pointsMarker.bottomAnchor, constant: -2),

            timestampMarker.trailingAnchor.constraint(equalTo: holderPanel.trailingAnchor, constant: -16),
            timestampMarker.centerYAnchor.constraint(equalTo: holderPanel.centerYAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Configure cell with record data
    func populateWith(record: MatchHistoryData, rank: Int) {
        pointsMarker.text = "\(record.points)"
        categoryMarker.text = record.category
        timestampMarker.text = record.displayableTimestamp

        configureRankDisplay(rank: rank)
        configureCategoryColor(category: record.category)
    }

    // MARK: - Private Configuration Methods

    private func configureRankDisplay(rank: Int) {
        if rank <= 3 {
            configureTopThreeRank(rank: rank)
        } else {
            configureStandardRank(rank: rank)
        }
    }

    private func configureTopThreeRank(rank: Int) {
        positionMarker.isHidden = true
        medallionSymbol.isHidden = false
        medallionSymbol.image = UIImage(systemName: "trophy.fill")

        let (trophyColor, borderColor) = RankColorProvider.colorsForRank(rank)
        medallionSymbol.tintColor = trophyColor
        holderPanel.layer.borderColor = borderColor.cgColor
    }

    private func configureStandardRank(rank: Int) {
        positionMarker.isHidden = false
        medallionSymbol.isHidden = true
        positionMarker.text = "#\(rank)"
        holderPanel.layer.borderColor = UIColor.white.withAlphaComponent(CellConfiguration.holderBorderAlpha).cgColor
    }

    private func configureCategoryColor(category: String) {
        if category == "Challenge Mode" {
            categoryMarker.textColor = ColorConfiguration.challengeModeColor
        } else {
            categoryMarker.textColor = ColorConfiguration.singleModeColor
        }
    }
}

// MARK: - Rank Color Provider

/// Provides colors for rank display
final class RankColorProvider {

    /// Returns trophy and border colors for a given rank
    static func colorsForRank(_ rank: Int) -> (trophyColor: UIColor, borderColor: UIColor) {
        switch rank {
        case 1:
            return (
                MatchHistoryItem.ColorConfiguration.goldColor,
                MatchHistoryItem.ColorConfiguration.goldColor.withAlphaComponent(0.4)
            )
        case 2:
            return (
                MatchHistoryItem.ColorConfiguration.silverColor,
                MatchHistoryItem.ColorConfiguration.silverColor.withAlphaComponent(0.3)
            )
        case 3:
            return (
                MatchHistoryItem.ColorConfiguration.bronzeColor,
                MatchHistoryItem.ColorConfiguration.bronzeColor.withAlphaComponent(0.3)
            )
        default:
            return (
                UIColor.white.withAlphaComponent(0.5),
                UIColor.white.withAlphaComponent(0.1)
            )
        }
    }
}

// MARK: - Record Display Formatter

/// Formats record data for display
final class RecordDisplayFormatter {

    /// Format score for display
    static func formatScore(_ score: Int) -> String {
        if score >= 1000 {
            let thousands = Double(score) / 1000.0
            return String(format: "%.1fK", thousands)
        }
        return "\(score)"
    }

    /// Format date for display
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Format relative time
    static func formatRelativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    /// Format play time duration
    static func formatPlayTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60

        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        }

        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Empty Records View

/// View displayed when no records are available
final class EmptyRecordsView: UIView {

    // MARK: - Properties

    private let iconImageView: UIImageView
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel

    // MARK: - Initialization

    override init(frame: CGRect) {
        iconImageView = UIImageView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()

        super.init(frame: frame)

        configureViewAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureViewAppearance() {
        configureIcon()
        configureTitleLabel()
        configureSubtitleLabel()
        setupConstraints()
    }

    private func configureIcon() {
        iconImageView.image = UIImage(systemName: "tray")
        iconImageView.tintColor = UIColor.white.withAlphaComponent(0.3)
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTitleLabel() {
        titleLabel.text = "No records yet"
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSubtitleLabel() {
        subtitleLabel.text = "Play a game to see your scores!"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Update empty state message
    func updateMessage(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    /// Update for filtered empty state
    func configureForFilteredEmpty(filterName: String) {
        titleLabel.text = "No \(filterName) records"
        subtitleLabel.text = "Try a different filter or play more games!"
    }
}
