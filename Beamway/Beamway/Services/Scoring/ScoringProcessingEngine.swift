//
//  ScoringProcessingEngine.swift
//  Beamway
//
//  Score calculation and combo tracking system
//

import Foundation

/// Comprehensive scoring and combo tracking engine
/// Manages point accumulation, combo multipliers, and streak tracking
final class ScoringProcessingEngine {

    // MARK: - Type Definitions

    /// Score update notification callback
    typealias ScoreUpdateCallback = (ScoreUpdateEvent) -> Void

    /// Combo update notification callback
    typealias ComboUpdateCallback = (ComboUpdateEvent) -> Void

    // MARK: - Properties

    /// Current accumulated total score
    private(set) var currentTotalScore: Int = 0

    /// Current active combo multiplier value
    private(set) var currentComboValue: Int = 0

    /// Peak combo achieved in current session
    private(set) var peakComboValue: Int = 0

    /// Total projectiles successfully dodged
    private(set) var totalProjectilesDodged: Int = 0

    /// Total collisions recorded
    private(set) var totalCollisions: Int = 0

    /// Base point value for successful dodge
    private let basePointsPerDodge: Int = 1

    /// Combo decay timer
    private var comboDecayTimer: Timer?

    /// Duration before combo starts decaying
    private let comboDecayDelaySeconds: TimeInterval = 2.0

    /// Score update callback
    var scoreUpdateCallback: ScoreUpdateCallback?

    /// Combo update callback
    var comboUpdateCallback: ComboUpdateCallback?

    /// Scoring configuration
    private let scoringConfiguration: ScoringConfiguration

    // MARK: - Initialization

    init(configuration: ScoringConfiguration = .defaultConfiguration) {
        self.scoringConfiguration = configuration
    }

    // MARK: - Score Management

    /// Award points for successful projectile dodge
    func awardPointsForSuccessfulDodge() {
        let pointsToAward = calculatePointsForDodge()

        currentTotalScore += pointsToAward
        totalProjectilesDodged += 1

        incrementComboMultiplier()

        let updateEvent = ScoreUpdateEvent(
            previousScore: currentTotalScore - pointsToAward,
            newScore: currentTotalScore,
            pointsDelta: pointsToAward,
            eventType: .dodgeAwarded
        )

        scoreUpdateCallback?(updateEvent)
    }

    /// Register collision event (breaks combo)
    func registerCollisionEvent() {
        totalCollisions += 1

        let previousCombo = currentComboValue
        resetComboMultiplier()

        let comboEvent = ComboUpdateEvent(
            previousCombo: previousCombo,
            newCombo: 0,
            eventType: .comboBroken
        )

        comboUpdateCallback?(comboEvent)
    }

    /// Calculate points for current dodge including combo bonus
    private func calculatePointsForDodge() -> Int {
        var points = basePointsPerDodge

        // Apply combo bonus if applicable
        if scoringConfiguration.comboBonusEnabled && currentComboValue >= scoringConfiguration.comboThresholdForBonus {
            let bonusMultiplier = calculateComboBonus()
            points = Int(CGFloat(points) * bonusMultiplier)
        }

        return max(points, basePointsPerDodge)
    }

    /// Calculate combo bonus multiplier
    private func calculateComboBonus() -> CGFloat {
        let comboTiers = scoringConfiguration.comboTierThresholds

        for (threshold, multiplier) in comboTiers.sorted(by: { $0.key > $1.key }) {
            if currentComboValue >= threshold {
                return multiplier
            }
        }

        return 1.0
    }

    // MARK: - Combo Management

    /// Increment combo multiplier
    private func incrementComboMultiplier() {
        currentComboValue += 1

        if currentComboValue > peakComboValue {
            peakComboValue = currentComboValue
        }

        resetComboDecayTimer()

        let comboEvent = ComboUpdateEvent(
            previousCombo: currentComboValue - 1,
            newCombo: currentComboValue,
            eventType: .comboIncreased
        )

        comboUpdateCallback?(comboEvent)
    }

    /// Reset combo multiplier to zero
    private func resetComboMultiplier() {
        comboDecayTimer?.invalidate()
        comboDecayTimer = nil

        currentComboValue = 0
    }

    /// Reset combo decay timer
    private func resetComboDecayTimer() {
        comboDecayTimer?.invalidate()

        comboDecayTimer = Timer.scheduledTimer(withTimeInterval: comboDecayDelaySeconds, repeats: false) { [weak self] _ in
            self?.handleComboDecay()
        }
    }

    /// Handle combo decay timeout
    private func handleComboDecay() {
        guard scoringConfiguration.comboDecayEnabled && currentComboValue > 0 else { return }

        let previousCombo = currentComboValue

        // Gradually decay combo rather than immediate reset
        currentComboValue = max(0, currentComboValue - 1)

        let comboEvent = ComboUpdateEvent(
            previousCombo: previousCombo,
            newCombo: currentComboValue,
            eventType: .comboDecayed
        )

        comboUpdateCallback?(comboEvent)

        // Continue decay if combo still active
        if currentComboValue > 0 {
            resetComboDecayTimer()
        }
    }

    // MARK: - Session Management

    /// Reset all scoring state for new session
    func resetAllScoringState() {
        currentTotalScore = 0
        currentComboValue = 0
        peakComboValue = 0
        totalProjectilesDodged = 0
        totalCollisions = 0

        comboDecayTimer?.invalidate()
        comboDecayTimer = nil
    }

    /// Generate scoring summary for session end
    func generateScoringSummary() -> ScoringSummary {
        return ScoringSummary(
            finalTotalScore: currentTotalScore,
            peakComboAchieved: peakComboValue,
            totalDodges: totalProjectilesDodged,
            totalCollisions: totalCollisions,
            dodgeSuccessRate: calculateDodgeSuccessRate()
        )
    }

    /// Calculate dodge success rate percentage
    private func calculateDodgeSuccessRate() -> CGFloat {
        let totalAttempts = totalProjectilesDodged + totalCollisions
        guard totalAttempts > 0 else { return 1.0 }
        return CGFloat(totalProjectilesDodged) / CGFloat(totalAttempts)
    }

    // MARK: - Cleanup

    deinit {
        comboDecayTimer?.invalidate()
    }
}

// MARK: - Supporting Types

/// Scoring configuration structure
struct ScoringConfiguration {
    let comboBonusEnabled: Bool
    let comboThresholdForBonus: Int
    let comboTierThresholds: [Int: CGFloat]
    let comboDecayEnabled: Bool

    static let defaultConfiguration = ScoringConfiguration(
        comboBonusEnabled: true,
        comboThresholdForBonus: 5,
        comboTierThresholds: [
            5: 1.1,
            10: 1.2,
            20: 1.5,
            50: 2.0
        ],
        comboDecayEnabled: false
    )
}

/// Score update event structure
struct ScoreUpdateEvent {
    let previousScore: Int
    let newScore: Int
    let pointsDelta: Int
    let eventType: ScoreEventType
}

/// Score event type enumeration
enum ScoreEventType {
    case dodgeAwarded
    case bonusAwarded
    case penaltyApplied
}

/// Combo update event structure
struct ComboUpdateEvent {
    let previousCombo: Int
    let newCombo: Int
    let eventType: ComboEventType
}

/// Combo event type enumeration
enum ComboEventType {
    case comboIncreased
    case comboBroken
    case comboDecayed
}

/// Scoring summary structure
struct ScoringSummary {
    let finalTotalScore: Int
    let peakComboAchieved: Int
    let totalDodges: Int
    let totalCollisions: Int
    let dodgeSuccessRate: CGFloat

    /// Format success rate as percentage string
    var formattedSuccessRate: String {
        return String(format: "%.1f%%", dodgeSuccessRate * 100)
    }
}

// MARK: - Leaderboard Integration

/// Leaderboard score entry structure
struct LeaderboardScoreEntry {
    let playerIdentifier: String
    let scoreValue: Int
    let achievedDate: Date
    let gameConfiguration: GameCategoryType
    let sessionDuration: TimeInterval

    /// Generate display rank string
    func generateRankDisplay(rank: Int) -> String {
        switch rank {
        case 1:
            return "1st"
        case 2:
            return "2nd"
        case 3:
            return "3rd"
        default:
            return "\(rank)th"
        }
    }
}

/// Leaderboard management utility
final class LeaderboardManager {

    /// Maximum entries to maintain per category
    private let maximumEntriesPerCategory: Int = 100

    /// Score entries by category
    private var scoreEntriesByCategory: [GameCategoryType: [LeaderboardScoreEntry]] = [:]

    /// Add new score entry
    func addScoreEntry(_ entry: LeaderboardScoreEntry) {
        var categoryEntries = scoreEntriesByCategory[entry.gameConfiguration] ?? []
        categoryEntries.append(entry)

        // Sort by score descending
        categoryEntries.sort { $0.scoreValue > $1.scoreValue }

        // Trim to maximum
        if categoryEntries.count > maximumEntriesPerCategory {
            categoryEntries = Array(categoryEntries.prefix(maximumEntriesPerCategory))
        }

        scoreEntriesByCategory[entry.gameConfiguration] = categoryEntries
    }

    /// Get top scores for category
    func getTopScores(for category: GameCategoryType, limit: Int = 10) -> [LeaderboardScoreEntry] {
        let entries = scoreEntriesByCategory[category] ?? []
        return Array(entries.prefix(limit))
    }

    /// Get rank for score in category
    func getRank(for score: Int, in category: GameCategoryType) -> Int {
        let entries = scoreEntriesByCategory[category] ?? []
        let betterScores = entries.filter { $0.scoreValue > score }
        return betterScores.count + 1
    }
}
