//
//  SessionResultDataModel.swift
//  Beamway
//
//  Data models for game session results and statistics
//

import Foundation

// MARK: - Session Result Models

/// Comprehensive data model for game session results
struct SessionResultDataModel {

    // MARK: - Properties

    /// Unique identifier for this session result
    let resultUniqueIdentifier: String

    /// Final score achieved in the session
    let achievedScoreValue: Int

    /// Game category/mode played
    let playedGameCategory: GameCategoryDescriptor

    /// Total session duration in seconds
    let sessionDurationSeconds: TimeInterval

    /// Date and time when session was completed
    let completionTimestamp: Date

    /// Peak combo streak achieved during session
    let peakComboStreakAchieved: Int

    /// Total projectiles successfully dodged
    let totalProjectilesDodged: Int

    /// Total collisions recorded
    let totalCollisionsRecorded: Int

    /// Final level reached (for challenge mode)
    let finalLevelReached: Int

    /// Session termination reason
    let terminationReason: SessionTerminationReason

    // MARK: - Initialization

    init(resultIdentifier: String = UUID().uuidString,
         scoreValue: Int,
         gameCategory: GameCategoryDescriptor,
         durationSeconds: TimeInterval,
         completionTime: Date = Date(),
         peakCombo: Int = 0,
         projectilesDodged: Int = 0,
         collisionsRecorded: Int = 0,
         levelReached: Int = 1,
         termination: SessionTerminationReason = .healthDepleted) {

        self.resultUniqueIdentifier = resultIdentifier
        self.achievedScoreValue = scoreValue
        self.playedGameCategory = gameCategory
        self.sessionDurationSeconds = durationSeconds
        self.completionTimestamp = completionTime
        self.peakComboStreakAchieved = peakCombo
        self.totalProjectilesDodged = projectilesDodged
        self.totalCollisionsRecorded = collisionsRecorded
        self.finalLevelReached = levelReached
        self.terminationReason = termination
    }

    // MARK: - Computed Properties

    /// Formatted duration string (M:SS)
    var formattedDurationString: String {
        let totalSeconds = Int(sessionDurationSeconds)
        let minutesPart = totalSeconds / 60
        let secondsPart = totalSeconds % 60
        return String(format: "%d:%02d", minutesPart, secondsPart)
    }

    /// Alias for formattedDurationString (compatibility)
    var formattedSessionDuration: String { formattedDurationString }

    /// Alias for achievedScoreValue (compatibility)
    var sessionScoreValue: Int { achievedScoreValue }

    /// Alias for peakComboStreakAchieved (compatibility)
    var sessionPeakCombo: Int { peakComboStreakAchieved }

    /// Alias for completionTimestamp (compatibility)
    var sessionRecordedDate: Date { completionTimestamp }

    /// Formatted completion date string
    var formattedCompletionDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: completionTimestamp)
    }

    /// Dodge success rate as percentage
    var dodgeSuccessRatePercentage: Double {
        let totalAttempts = totalProjectilesDodged + totalCollisionsRecorded
        guard totalAttempts > 0 else { return 100.0 }
        return Double(totalProjectilesDodged) / Double(totalAttempts) * 100.0
    }

    /// Formatted success rate string
    var formattedSuccessRateString: String {
        return String(format: "%.1f%%", dodgeSuccessRatePercentage)
    }

    /// Average score per minute
    var averageScorePerMinute: Double {
        guard sessionDurationSeconds > 0 else { return 0 }
        return Double(achievedScoreValue) / (sessionDurationSeconds / 60.0)
    }
}

// MARK: - Game Category Descriptor

/// Descriptor for game category/mode
enum GameCategoryDescriptor: String, Codable, CaseIterable {
    case singleTileMode = "Single Mode"
    case challengeMultiTileMode = "Challenge Mode"

    /// Display name for the category
    var displayName: String {
        return rawValue
    }

    /// Short display name
    var shortDisplayName: String {
        switch self {
        case .singleTileMode:
            return "Single"
        case .challengeMultiTileMode:
            return "Challenge"
        }
    }

    /// Associated accent color
    var associatedAccentColor: String {
        switch self {
        case .singleTileMode:
            return "#3399FF" // Blue
        case .challengeMultiTileMode:
            return "#FF4D66" // Red
        }
    }

    /// Convert from GameCategoryType
    static func fromCategoryType(_ type: GameCategoryType) -> GameCategoryDescriptor {
        switch type {
        case .individualChallenge:
            return .singleTileMode
        case .competitiveMultiBlock:
            return .challengeMultiTileMode
        }
    }

    /// Convert to GameCategoryType
    func toCategoryType() -> GameCategoryType {
        switch self {
        case .singleTileMode:
            return .individualChallenge
        case .challengeMultiTileMode:
            return .competitiveMultiBlock
        }
    }
}

// MARK: - Session Termination Reason

/// Enumeration of session termination reasons
enum SessionTerminationReason: String, Codable {
    case healthDepleted = "Health Depleted"
    case userExited = "User Exited"
    case timeExpired = "Time Expired"
    case applicationTerminated = "App Terminated"
    case errorOccurred = "Error Occurred"

    /// Whether the session ended naturally (not user-initiated)
    var isNaturalEnding: Bool {
        return self == .healthDepleted || self == .timeExpired
    }

    /// Human-readable termination description
    var terminationDescription: String {
        return rawValue
    }
}

// MARK: - Session Statistics Summary

/// Summary statistics for multiple sessions
struct SessionStatisticsSummary {

    // MARK: - Properties

    /// Total number of sessions played
    let totalSessionsPlayed: Int

    /// Highest score achieved across all sessions
    let highestScoreAchieved: Int

    /// Longest session duration in seconds
    let longestSessionDuration: TimeInterval

    /// Total play time across all sessions
    let totalPlayTimeSeconds: TimeInterval

    /// Average score per session
    let averageScorePerSession: Double

    /// Average session duration
    let averageSessionDuration: TimeInterval

    /// Most played game category
    let mostPlayedCategory: GameCategoryDescriptor?

    /// Highest combo achieved
    let highestComboAchieved: Int

    // MARK: - Initialization

    init(sessions: [SessionResultDataModel]) {
        self.totalSessionsPlayed = sessions.count

        self.highestScoreAchieved = sessions.map { $0.achievedScoreValue }.max() ?? 0

        self.longestSessionDuration = sessions.map { $0.sessionDurationSeconds }.max() ?? 0

        self.totalPlayTimeSeconds = sessions.reduce(0) { $0 + $1.sessionDurationSeconds }

        if sessions.isEmpty {
            self.averageScorePerSession = 0
            self.averageSessionDuration = 0
        } else {
            self.averageScorePerSession = Double(sessions.reduce(0) { $0 + $1.achievedScoreValue }) / Double(sessions.count)
            self.averageSessionDuration = totalPlayTimeSeconds / Double(sessions.count)
        }

        // Calculate most played category
        let categoryCounts = Dictionary(grouping: sessions, by: { $0.playedGameCategory })
        self.mostPlayedCategory = categoryCounts.max(by: { $0.value.count < $1.value.count })?.key

        self.highestComboAchieved = sessions.map { $0.peakComboStreakAchieved }.max() ?? 0
    }

    // MARK: - Computed Properties

    /// Formatted total play time
    var formattedTotalPlayTime: String {
        let totalSeconds = Int(totalPlayTimeSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        }
        return String(format: "%dm", minutes)
    }

    /// Formatted longest session duration
    var formattedLongestSession: String {
        return longestSessionDuration.formattedMinutesSeconds
    }

    /// Formatted average score
    var formattedAverageScore: String {
        return String(format: "%.1f", averageScorePerSession)
    }

    // MARK: - Compatibility Aliases

    /// Alias for highestScoreAchieved (compatibility)
    var overallHighestScore: Int { highestScoreAchieved }

    /// Alias for totalPlayTimeSeconds (compatibility)
    var aggregatePlayDuration: TimeInterval { totalPlayTimeSeconds }

    /// Alias for highestComboAchieved (compatibility)
    var overallPeakCombo: Int { highestComboAchieved }

    /// Alias for averageScorePerSession (compatibility)
    var averageScoreValue: Double { averageScorePerSession }
}

// MARK: - Achievement Progress

/// Achievement progress tracking model
struct AchievementProgressModel {

    // MARK: - Achievement Definitions

    enum AchievementType: String, CaseIterable {
        case playFiveGames = "play_5_games"
        case playTwentyGames = "play_20_games"
        case scoreFiftyPoints = "score_50_points"
        case achieveComboTen = "combo_10"
        case surviveFiveMinutes = "survive_5_min"

        var displayName: String {
            switch self {
            case .playFiveGames:
                return "Play 5 Games"
            case .playTwentyGames:
                return "Play 20 Games"
            case .scoreFiftyPoints:
                return "Score 50 Points"
            case .achieveComboTen:
                return "10x Combo"
            case .surviveFiveMinutes:
                return "Survive 5 Minutes"
            }
        }

        var requiredValue: Int {
            switch self {
            case .playFiveGames:
                return 5
            case .playTwentyGames:
                return 20
            case .scoreFiftyPoints:
                return 50
            case .achieveComboTen:
                return 10
            case .surviveFiveMinutes:
                return 300 // seconds
            }
        }

        var iconName: String {
            switch self {
            case .playFiveGames, .playTwentyGames:
                return "gamecontroller.fill"
            case .scoreFiftyPoints:
                return "star.fill"
            case .achieveComboTen:
                return "bolt.fill"
            case .surviveFiveMinutes:
                return "clock.fill"
            }
        }
    }

    // MARK: - Properties

    /// Achievement type
    let achievementType: AchievementType

    /// Current progress value
    let currentProgressValue: Int

    /// Whether achievement is unlocked
    let isAchievementUnlocked: Bool

    /// Unlock date (if unlocked)
    let unlockDate: Date?

    // MARK: - Computed Properties

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        let required = Double(achievementType.requiredValue)
        return min(Double(currentProgressValue) / required, 1.0)
    }

    /// Formatted progress string
    var formattedProgressString: String {
        return "\(currentProgressValue)/\(achievementType.requiredValue)"
    }
}

// MARK: - Leaderboard Entry

/// Leaderboard entry model for ranking display
struct LeaderboardEntryModel {

    // MARK: - Properties

    /// Entry rank position
    let rankPosition: Int

    /// Associated session result
    let sessionResult: SessionResultDataModel

    // MARK: - Computed Properties

    /// Rank display string
    var rankDisplayString: String {
        switch rankPosition {
        case 1:
            return "1st"
        case 2:
            return "2nd"
        case 3:
            return "3rd"
        default:
            return "\(rankPosition)th"
        }
    }

    /// Whether entry is in top 3
    var isTopThree: Bool {
        return rankPosition <= 3
    }

    /// Medal type for top 3
    var medalType: MedalType? {
        switch rankPosition {
        case 1:
            return .gold
        case 2:
            return .silver
        case 3:
            return .bronze
        default:
            return nil
        }
    }

    /// Medal type enumeration
    enum MedalType {
        case gold
        case silver
        case bronze

        var colorHex: String {
            switch self {
            case .gold:
                return "#FFD700"
            case .silver:
                return "#C0C0C0"
            case .bronze:
                return "#CD7F32"
            }
        }
    }
}
