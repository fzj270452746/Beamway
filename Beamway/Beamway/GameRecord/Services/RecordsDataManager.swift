//
//  RecordsDataManager.swift
//  Beamway
//
//  Data management for game records screen
//  Handles loading, filtering, and metrics calculation
//

import Foundation
import UIKit

// MARK: - Records Metrics

/// Computed metrics for game records
struct RecordsMetrics {
    let totalGames: Int
    let highScore: Int
    let bestTime: TimeInterval

    var formattedBestTime: String {
        let minutes = Int(bestTime) / 60
        let seconds = Int(bestTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Records Data Manager

/// Manages game records data operations
final class RecordsDataManager {

    // MARK: - Properties

    private(set) var allHistories: [MatchHistoryData] = []
    private(set) var filteredHistories: [MatchHistoryData] = []

    // MARK: - Data Loading

    /// Load all match histories from storage
    func loadAllHistories() {
        allHistories = MatchHistoryHandler.globalHandler.retrieveAllMatchHistories()
    }

    /// Apply category filter to histories
    func applyFilter(_ filter: String) {
        switch filter {
        case "Single":
            filteredHistories = allHistories.filter { $0.category == "Single Mode" }
        case "Challenge":
            filteredHistories = allHistories.filter { $0.category == "Challenge Mode" }
        default:
            filteredHistories = allHistories
        }
    }

    /// Calculate summary metrics
    func calculateMetrics() -> RecordsMetrics {
        let totalGames = allHistories.count
        let highScore = allHistories.map { $0.points }.max() ?? 0

        let singleTime = MatchHistoryHandler.globalHandler.retrievePeakDurationHistory(category: "Single Mode")
        let challengeTime = MatchHistoryHandler.globalHandler.retrievePeakDurationHistory(category: "Challenge Mode")
        let bestTime = max(singleTime, challengeTime)

        return RecordsMetrics(
            totalGames: totalGames,
            highScore: highScore,
            bestTime: bestTime
        )
    }

    /// Delete a specific record
    func deleteRecord(at index: Int) -> Bool {
        guard index < filteredHistories.count else { return false }
        let record = filteredHistories[index]
        MatchHistoryHandler.globalHandler.removeMatchHistory(uniqueId: record.uniqueId)
        return true
    }

    /// Delete all records
    func deleteAllRecords() {
        MatchHistoryHandler.globalHandler.removeAllMatchHistories()
        allHistories.removeAll()
        filteredHistories.removeAll()
    }
}

// MARK: - Records Statistics Calculator

/// Calculates detailed statistics from records
final class RecordsStatisticsCalculator {

    // MARK: - Statistics Models

    struct DetailedStatistics {
        let totalGames: Int
        let highScore: Int
        let averageScore: Double
        let totalPlayTime: TimeInterval
        let bestPlayTime: TimeInterval
        let singleModeStats: ModeStatistics
        let challengeModeStats: ModeStatistics
        let recentTrend: TrendDirection
    }

    struct ModeStatistics {
        let gamesPlayed: Int
        let highScore: Int
        let averageScore: Double
        let bestTime: TimeInterval
    }

    enum TrendDirection {
        case improving
        case declining
        case stable
        case insufficient

        var displayText: String {
            switch self {
            case .improving:
                return "Improving"
            case .declining:
                return "Declining"
            case .stable:
                return "Stable"
            case .insufficient:
                return "Not enough data"
            }
        }

        var iconName: String {
            switch self {
            case .improving:
                return "arrow.up.right"
            case .declining:
                return "arrow.down.right"
            case .stable:
                return "arrow.right"
            case .insufficient:
                return "questionmark"
            }
        }
    }

    // MARK: - Calculation Methods

    /// Calculate detailed statistics from all records
    static func calculateDetailedStatistics(from records: [MatchHistoryData]) -> DetailedStatistics {
        let singleModeRecords = records.filter { $0.category == "Single Mode" }
        let challengeModeRecords = records.filter { $0.category == "Challenge Mode" }

        let singleStats = calculateModeStatistics(from: singleModeRecords, modeName: "Single Mode")
        let challengeStats = calculateModeStatistics(from: challengeModeRecords, modeName: "Challenge Mode")

        let allScores = records.map { $0.points }
        let averageScore = allScores.isEmpty ? 0.0 : Double(allScores.reduce(0, +)) / Double(allScores.count)

        return DetailedStatistics(
            totalGames: records.count,
            highScore: allScores.max() ?? 0,
            averageScore: averageScore,
            totalPlayTime: singleStats.bestTime + challengeStats.bestTime,
            bestPlayTime: max(singleStats.bestTime, challengeStats.bestTime),
            singleModeStats: singleStats,
            challengeModeStats: challengeStats,
            recentTrend: calculateTrend(from: records)
        )
    }

    /// Calculate statistics for a specific mode
    static func calculateModeStatistics(
        from records: [MatchHistoryData],
        modeName: String
    ) -> ModeStatistics {
        let scores = records.map { $0.points }
        let averageScore = scores.isEmpty ? 0.0 : Double(scores.reduce(0, +)) / Double(scores.count)
        let bestTime = MatchHistoryHandler.globalHandler.retrievePeakDurationHistory(category: modeName)

        return ModeStatistics(
            gamesPlayed: records.count,
            highScore: scores.max() ?? 0,
            averageScore: averageScore,
            bestTime: bestTime
        )
    }

    /// Calculate recent performance trend
    static func calculateTrend(from records: [MatchHistoryData]) -> TrendDirection {
        guard records.count >= 6 else {
            return .insufficient
        }

        let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }
        let recentScores = Array(sortedRecords.prefix(3)).map { $0.points }
        let olderScores = Array(sortedRecords.dropFirst(3).prefix(3)).map { $0.points }

        let recentAverage = Double(recentScores.reduce(0, +)) / 3.0
        let olderAverage = Double(olderScores.reduce(0, +)) / 3.0

        let difference = recentAverage - olderAverage
        let threshold = olderAverage * 0.1 // 10% threshold

        if difference > threshold {
            return .improving
        } else if difference < -threshold {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - Records Filter Manager

/// Manages filter state and logic
final class RecordsFilterManager {

    // MARK: - Filter Types

    enum FilterType: String, CaseIterable {
        case all = "All"
        case single = "Single"
        case challenge = "Challenge"

        var displayName: String {
            return rawValue
        }

        var categoryName: String? {
            switch self {
            case .all:
                return nil
            case .single:
                return "Single Mode"
            case .challenge:
                return "Challenge Mode"
            }
        }
    }

    // MARK: - Properties

    private(set) var currentFilter: FilterType = .all

    // MARK: - Public Methods

    /// Set the current filter
    func setFilter(_ filter: FilterType) {
        currentFilter = filter
    }

    /// Set filter from string
    func setFilter(from string: String) {
        currentFilter = FilterType(rawValue: string) ?? .all
    }

    /// Apply current filter to records
    func applyFilter(to records: [MatchHistoryData]) -> [MatchHistoryData] {
        guard let categoryName = currentFilter.categoryName else {
            return records
        }
        return records.filter { $0.category == categoryName }
    }
}

// MARK: - Records Sort Manager

/// Manages sorting options for records
final class RecordsSortManager {

    // MARK: - Sort Types

    enum SortType {
        case dateDescending
        case dateAscending
        case scoreDescending
        case scoreAscending

        var displayName: String {
            switch self {
            case .dateDescending:
                return "Newest First"
            case .dateAscending:
                return "Oldest First"
            case .scoreDescending:
                return "Highest Score"
            case .scoreAscending:
                return "Lowest Score"
            }
        }
    }

    // MARK: - Properties

    private(set) var currentSort: SortType = .dateDescending

    // MARK: - Public Methods

    /// Set the current sort type
    func setSort(_ sort: SortType) {
        currentSort = sort
    }

    /// Apply current sort to records
    func applySort(to records: [MatchHistoryData]) -> [MatchHistoryData] {
        switch currentSort {
        case .dateDescending:
            return records.sorted { $0.timestamp > $1.timestamp }
        case .dateAscending:
            return records.sorted { $0.timestamp < $1.timestamp }
        case .scoreDescending:
            return records.sorted { $0.points > $1.points }
        case .scoreAscending:
            return records.sorted { $0.points < $1.points }
        }
    }
}

// MARK: - Records Alert Presenter

/// Handles alert presentations for records screen
final class RecordsAlertPresenter {

    /// Present clear all confirmation dialog
    func presentClearAllConfirmation(
        from viewController: UIViewController,
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Clear All Records",
            message: "Are you sure you want to delete all game records? This cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { _ in
            onConfirm()
        })

        viewController.present(alert, animated: true)
    }

    /// Present single record deletion confirmation
    func presentDeleteConfirmation(
        from viewController: UIViewController,
        recordScore: Int,
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this record with score \(recordScore)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            onConfirm()
        })

        viewController.present(alert, animated: true)
    }
}
