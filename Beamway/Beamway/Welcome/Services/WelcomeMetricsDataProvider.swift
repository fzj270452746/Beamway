//
//  WelcomeMetricsDataProvider.swift
//  Beamway
//
//  Data provider for welcome screen metrics and statistics
//

import Foundation
import UIKit

/// Data model for welcome screen metrics
struct WelcomeMetrics {
    let totalGames: Int
    let highScore: Int
    let totalPlayTime: TimeInterval
    let singleModeHighScore: Int
    let challengeModeHighScore: Int

    var formattedPlayTime: String {
        if totalPlayTime <= 0 {
            return "0s"
        }

        let minutes = Int(totalPlayTime) / 60
        let seconds = Int(totalPlayTime) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

/// Data provider for fetching and computing welcome screen metrics
final class WelcomeMetricsDataProvider {

    // MARK: - Properties

    private let historyHandler: MatchHistoryHandler

    // MARK: - Initialization

    init(historyHandler: MatchHistoryHandler = .globalHandler) {
        self.historyHandler = historyHandler
    }

    // MARK: - Public Methods

    /// Fetch current metrics from data store
    func fetchCurrentMetrics() -> WelcomeMetrics {
        let histories = historyHandler.retrieveAllMatchHistories()

        let totalGames = histories.count
        let highScore = histories.map { $0.points }.max() ?? 0

        // Get play times for each mode
        let singleDuration = historyHandler.retrievePeakDurationHistory(category: "Single Mode")
        let challengeDuration = historyHandler.retrievePeakDurationHistory(category: "Challenge Mode")
        let totalPlayTime = singleDuration + challengeDuration

        // Get high scores by mode
        let singleModeScores = histories.filter { $0.category == "Single Mode" }.map { $0.points }
        let challengeModeScores = histories.filter { $0.category == "Challenge Mode" }.map { $0.points }

        let singleModeHighScore = singleModeScores.max() ?? 0
        let challengeModeHighScore = challengeModeScores.max() ?? 0

        return WelcomeMetrics(
            totalGames: totalGames,
            highScore: highScore,
            totalPlayTime: totalPlayTime,
            singleModeHighScore: singleModeHighScore,
            challengeModeHighScore: challengeModeHighScore
        )
    }

    /// Check if player has achieved certain milestones
    func checkMilestones() -> [GameMilestone] {
        let metrics = fetchCurrentMetrics()
        var achievedMilestones: [GameMilestone] = []

        if metrics.totalGames >= 1 {
            achievedMilestones.append(.firstGame)
        }

        if metrics.totalGames >= 5 {
            achievedMilestones.append(.fiveGames)
        }

        if metrics.totalGames >= 20 {
            achievedMilestones.append(.twentyGames)
        }

        if metrics.highScore >= 10 {
            achievedMilestones.append(.scoreTen)
        }

        if metrics.highScore >= 25 {
            achievedMilestones.append(.scoreTwentyFive)
        }

        if metrics.highScore >= 50 {
            achievedMilestones.append(.scoreFifty)
        }

        if metrics.totalPlayTime >= 300 { // 5 minutes
            achievedMilestones.append(.fiveMinutesPlayed)
        }

        if metrics.totalPlayTime >= 1800 { // 30 minutes
            achievedMilestones.append(.thirtyMinutesPlayed)
        }

        return achievedMilestones
    }

    /// Get next milestone to achieve
    func getNextMilestone() -> (milestone: GameMilestone, progress: Float, description: String)? {
        let metrics = fetchCurrentMetrics()
        let achieved = checkMilestones()

        // Check games played milestones
        if !achieved.contains(.firstGame) {
            return (.firstGame, 0, "Play your first game")
        }

        if !achieved.contains(.fiveGames) {
            let progress = Float(metrics.totalGames) / 5.0
            return (.fiveGames, progress, "Play 5 games - \(metrics.totalGames)/5")
        }

        if !achieved.contains(.twentyGames) {
            let progress = Float(metrics.totalGames) / 20.0
            return (.twentyGames, progress, "Play 20 games - \(metrics.totalGames)/20")
        }

        // Check score milestones
        if !achieved.contains(.scoreTen) {
            let progress = Float(metrics.highScore) / 10.0
            return (.scoreTen, progress, "Score 10 points - \(metrics.highScore)/10")
        }

        if !achieved.contains(.scoreTwentyFive) {
            let progress = Float(metrics.highScore) / 25.0
            return (.scoreTwentyFive, progress, "Score 25 points - \(metrics.highScore)/25")
        }

        if !achieved.contains(.scoreFifty) {
            let progress = Float(metrics.highScore) / 50.0
            return (.scoreFifty, progress, "Score 50 points - \(metrics.highScore)/50")
        }

        return nil
    }
}

// MARK: - Game Milestone Enumeration

/// Enumeration of game milestones/achievements
enum GameMilestone: String, CaseIterable {
    case firstGame = "first_game"
    case fiveGames = "five_games"
    case twentyGames = "twenty_games"
    case fiftyGames = "fifty_games"
    case scoreTen = "score_ten"
    case scoreTwentyFive = "score_twenty_five"
    case scoreFifty = "score_fifty"
    case scoreHundred = "score_hundred"
    case fiveMinutesPlayed = "five_minutes"
    case thirtyMinutesPlayed = "thirty_minutes"

    var displayName: String {
        switch self {
        case .firstGame:
            return "First Steps"
        case .fiveGames:
            return "Getting Started"
        case .twentyGames:
            return "Regular Player"
        case .fiftyGames:
            return "Dedicated"
        case .scoreTen:
            return "Scorer"
        case .scoreTwentyFive:
            return "Skilled"
        case .scoreFifty:
            return "Expert"
        case .scoreHundred:
            return "Master"
        case .fiveMinutesPlayed:
            return "Time Invested"
        case .thirtyMinutesPlayed:
            return "Veteran"
        }
    }

    var iconName: String {
        switch self {
        case .firstGame, .fiveGames, .twentyGames, .fiftyGames:
            return "gamecontroller.fill"
        case .scoreTen, .scoreTwentyFive, .scoreFifty, .scoreHundred:
            return "star.fill"
        case .fiveMinutesPlayed, .thirtyMinutesPlayed:
            return "clock.fill"
        }
    }

    var badgeColor: UIColor {
        switch self {
        case .firstGame, .fiveGames:
            return UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0) // Bronze
        case .twentyGames, .scoreTen, .fiveMinutesPlayed:
            return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // Silver
        case .fiftyGames, .scoreTwentyFive, .scoreFifty, .thirtyMinutesPlayed:
            return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
        case .scoreHundred:
            return UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0) // Platinum
        }
    }
}

// MARK: - Statistics Calculator

/// Utility for calculating derived statistics
final class StatisticsCalculator {

    /// Calculate average score from match histories
    static func calculateAverageScore(from histories: [MatchHistoryEntry]) -> Double {
        guard !histories.isEmpty else { return 0 }
        let total = histories.reduce(0) { $0 + $1.points }
        return Double(total) / Double(histories.count)
    }

    /// Calculate win rate (games with score >= threshold)
    static func calculateWinRate(from histories: [MatchHistoryEntry], threshold: Int = 10) -> Double {
        guard !histories.isEmpty else { return 0 }
        let wins = histories.filter { $0.points >= threshold }.count
        return Double(wins) / Double(histories.count) * 100
    }

    /// Get best streak of high-scoring games
    static func calculateBestStreak(from histories: [MatchHistoryEntry], threshold: Int = 10) -> Int {
        var currentStreak = 0
        var bestStreak = 0

        for entry in histories.sorted(by: { $0.date > $1.date }) {
            if entry.points >= threshold {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return bestStreak
    }

    /// Get improvement trend (comparing recent games to older games)
    static func calculateImprovementTrend(from histories: [MatchHistoryEntry]) -> Double {
        let sortedHistories = histories.sorted(by: { $0.date > $1.date })

        guard sortedHistories.count >= 6 else { return 0 }

        let recentGames = Array(sortedHistories.prefix(3))
        let olderGames = Array(sortedHistories.dropFirst(3).prefix(3))

        let recentAverage = Double(recentGames.reduce(0) { $0 + $1.points }) / 3.0
        let olderAverage = Double(olderGames.reduce(0) { $0 + $1.points }) / 3.0

        guard olderAverage > 0 else { return 0 }

        return ((recentAverage - olderAverage) / olderAverage) * 100
    }
}

// MARK: - Match History Entry (for type compatibility)

/// Simple struct representing a match history entry
struct MatchHistoryEntry {
    let points: Int
    let category: String
    let date: Date
}
