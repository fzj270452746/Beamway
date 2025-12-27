//
//  GameSessionViewModel.swift
//  Beamway
//
//  View model for game session state management
//

import Foundation
import Combine

/// View model managing game session state and business logic
/// Provides reactive bindings for UI updates and session coordination
final class GameSessionViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current score value
    @Published private(set) var currentScoreValue: Int = 0

    /// Current health points remaining
    @Published private(set) var currentHealthPoints: Int = 3

    /// Current level/stage number
    @Published private(set) var currentLevelNumber: Int = 1

    /// Elapsed session time in seconds
    @Published private(set) var elapsedSessionTime: TimeInterval = 0

    /// Current combo streak count
    @Published private(set) var currentComboStreak: Int = 0

    /// Whether session is currently paused
    @Published private(set) var isSessionPaused: Bool = false

    /// Whether session is concluded
    @Published private(set) var isSessionConcluded: Bool = false

    /// Session result (populated on conclusion)
    @Published private(set) var sessionResult: SessionResultDataModel?

    // MARK: - Properties

    /// Session configuration
    private let sessionConfiguration: GameSessionConfiguration

    /// Game category being played
    private let gameCategory: GameCategoryDescriptor

    /// Session start timestamp
    private var sessionStartTimestamp: Date?

    /// Pause start timestamp (for duration calculation)
    private var pauseStartTimestamp: Date?

    /// Total paused duration
    private var totalPausedDuration: TimeInterval = 0

    /// Maximum health capacity
    private let maximumHealthCapacity: Int = 3

    /// Peak combo achieved in session
    private var peakComboAchieved: Int = 0

    /// Total projectiles dodged
    private var totalProjectilesDodged: Int = 0

    /// Total collisions recorded
    private var totalCollisionsRecorded: Int = 0

    /// Session record repository
    private let recordRepository: SessionRecordRepository

    /// Scoring processing engine
    private let scoringEngine: ScoringProcessingEngine

    /// Cancellables storage
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Callbacks

    /// Callback when health is depleted (game over)
    var onHealthDepleted: (() -> Void)?

    /// Callback when level advances
    var onLevelAdvanced: ((Int) -> Void)?

    /// Callback when combo updates
    var onComboUpdated: ((Int) -> Void)?

    /// Callback when session concludes
    var onSessionConcluded: ((SessionResultDataModel) -> Void)?

    // MARK: - Initialization

    init(configuration: GameSessionConfiguration) {
        self.sessionConfiguration = configuration
        self.gameCategory = GameCategoryDescriptor.fromCategoryType(configuration.categoryType)
        self.recordRepository = SessionRecordRepository.shared
        self.scoringEngine = ScoringProcessingEngine()

        configureBindings()
    }

    /// Configure reactive bindings
    private func configureBindings() {
        scoringEngine.scoreUpdateCallback = { [weak self] event in
            self?.handleScoreUpdateEvent(event)
        }

        scoringEngine.comboUpdateCallback = { [weak self] event in
            self?.handleComboUpdateEvent(event)
        }
    }

    // MARK: - Session Lifecycle

    /// Initialize session to starting state
    func initializeSession() {
        currentScoreValue = 0
        currentHealthPoints = maximumHealthCapacity
        currentLevelNumber = 1
        elapsedSessionTime = 0
        currentComboStreak = 0
        isSessionPaused = false
        isSessionConcluded = false
        sessionResult = nil

        peakComboAchieved = 0
        totalProjectilesDodged = 0
        totalCollisionsRecorded = 0
        totalPausedDuration = 0

        scoringEngine.resetAllScoringState()
    }

    /// Start session execution
    func startSession() {
        guard sessionStartTimestamp == nil else { return }

        sessionStartTimestamp = Date()
        isSessionPaused = false
    }

    /// Pause session execution
    func pauseSession() {
        guard !isSessionPaused && !isSessionConcluded else { return }

        isSessionPaused = true
        pauseStartTimestamp = Date()
    }

    /// Resume session from pause
    func resumeSession() {
        guard isSessionPaused && !isSessionConcluded else { return }

        if let pauseStart = pauseStartTimestamp {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
        }

        isSessionPaused = false
        pauseStartTimestamp = nil
    }

    /// Conclude session with specified reason
    func concludeSession(reason: SessionTerminationReason) {
        guard !isSessionConcluded else { return }

        isSessionConcluded = true

        let finalDuration = calculateFinalSessionDuration()

        let result = SessionResultDataModel(
            scoreValue: currentScoreValue,
            gameCategory: gameCategory,
            durationSeconds: finalDuration,
            peakCombo: peakComboAchieved,
            projectilesDodged: totalProjectilesDodged,
            collisionsRecorded: totalCollisionsRecorded,
            levelReached: currentLevelNumber,
            termination: reason
        )

        sessionResult = result

        // Persist result
        recordRepository.persistSessionResult(result)

        onSessionConcluded?(result)
    }

    /// Calculate final session duration accounting for pauses
    private func calculateFinalSessionDuration() -> TimeInterval {
        guard let startTime = sessionStartTimestamp else { return 0 }

        var totalDuration = Date().timeIntervalSince(startTime)

        // Subtract paused duration
        totalDuration -= totalPausedDuration

        // Account for current pause if active
        if isSessionPaused, let pauseStart = pauseStartTimestamp {
            totalDuration -= Date().timeIntervalSince(pauseStart)
        }

        return max(0, totalDuration)
    }

    // MARK: - Game Events

    /// Record successful projectile dodge
    func recordProjectileDodge() {
        guard !isSessionConcluded && !isSessionPaused else { return }

        totalProjectilesDodged += 1
        scoringEngine.awardPointsForSuccessfulDodge()
    }

    /// Record collision event
    func recordCollision() {
        guard !isSessionConcluded && !isSessionPaused else { return }

        totalCollisionsRecorded += 1
        scoringEngine.registerCollisionEvent()

        // Apply damage
        applyDamage(amount: 1)
    }

    /// Apply damage to health
    private func applyDamage(amount: Int) {
        currentHealthPoints = max(0, currentHealthPoints - amount)

        if currentHealthPoints <= 0 {
            onHealthDepleted?()
            concludeSession(reason: .healthDepleted)
        }
    }

    /// Update elapsed time
    func updateElapsedTime(_ newTime: TimeInterval) {
        elapsedSessionTime = newTime
    }

    // MARK: - Event Handlers

    /// Handle score update event from scoring engine
    private func handleScoreUpdateEvent(_ event: ScoreUpdateEvent) {
        currentScoreValue = event.newScore

        // Check for level advancement
        evaluateLevelAdvancement()
    }

    /// Handle combo update event from scoring engine
    private func handleComboUpdateEvent(_ event: ComboUpdateEvent) {
        currentComboStreak = event.newCombo

        if event.newCombo > peakComboAchieved {
            peakComboAchieved = event.newCombo
        }

        onComboUpdated?(event.newCombo)
    }

    /// Evaluate and process level advancement
    private func evaluateLevelAdvancement() {
        guard sessionConfiguration.categoryType == .competitiveMultiBlock else { return }

        let calculatedLevel = (currentScoreValue / 10) + 1

        if calculatedLevel > currentLevelNumber {
            currentLevelNumber = calculatedLevel
            onLevelAdvanced?(currentLevelNumber)
        }
    }

    // MARK: - Accessors

    /// Get formatted elapsed time string
    var formattedElapsedTime: String {
        return elapsedSessionTime.formattedMinutesSeconds
    }

    /// Get formatted score string
    var formattedScore: String {
        return "\(currentScoreValue)"
    }

    /// Check if game is in challenge mode
    var isChallengeMode: Bool {
        return sessionConfiguration.categoryType == .competitiveMultiBlock
    }

    /// Get game category display name
    var categoryDisplayName: String {
        return gameCategory.displayName
    }
}

// MARK: - Welcome Screen View Model

/// View model for welcome/home screen
final class WelcomeScreenViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Total games played count
    @Published private(set) var totalGamesPlayed: Int = 0

    /// Highest score achieved
    @Published private(set) var highestScore: Int = 0

    /// Best play time achieved
    @Published private(set) var bestPlayTimeFormatted: String = "0:00"

    /// Achievement progress percentage
    @Published private(set) var achievementProgress: Double = 0.0

    /// Next achievement description
    @Published private(set) var nextAchievementDescription: String = ""

    // MARK: - Properties

    /// Session record repository
    private let recordRepository: SessionRecordRepository

    // MARK: - Initialization

    init() {
        self.recordRepository = SessionRecordRepository.shared
        refreshStatistics()
    }

    // MARK: - Data Refresh

    /// Refresh all statistics from repository
    func refreshStatistics() {
        totalGamesPlayed = recordRepository.getTotalGamesPlayedCount()
        highestScore = recordRepository.getHighestScoreAchieved()

        let peakDuration = recordRepository.retrieveOverallPeakDuration()
        bestPlayTimeFormatted = peakDuration > 0 ? peakDuration.formattedMinutesSeconds : "0:00"

        calculateAchievementProgress()
    }

    /// Calculate achievement progress
    private func calculateAchievementProgress() {
        let milestones = [5, 20, 50, 100]
        var completedMilestones = 0

        for milestone in milestones {
            if totalGamesPlayed >= milestone {
                completedMilestones += 1
            }
        }

        achievementProgress = Double(completedMilestones) / Double(milestones.count)

        // Determine next achievement
        if totalGamesPlayed < 5 {
            nextAchievementDescription = "Play 5 games - \(totalGamesPlayed)/5"
        } else if totalGamesPlayed < 20 {
            nextAchievementDescription = "Play 20 games - \(totalGamesPlayed)/20"
        } else if highestScore < 50 {
            nextAchievementDescription = "Score 50 points - \(highestScore)/50"
        } else {
            nextAchievementDescription = "All achievements unlocked!"
        }
    }
}

// MARK: - Records Screen View Model

/// View model for game records screen
final class RecordsScreenViewModel: ObservableObject {

    // MARK: - Published Properties

    /// All session records
    @Published private(set) var allSessionRecords: [SessionResultDataModel] = []

    /// Filtered session records
    @Published private(set) var filteredRecords: [SessionResultDataModel] = []

    /// Current filter category
    @Published var currentFilterCategory: RecordFilterCategory = .all

    /// Statistics summary
    @Published private(set) var statisticsSummary: SessionStatisticsSummary?

    // MARK: - Properties

    /// Session record repository
    private let recordRepository: SessionRecordRepository

    // MARK: - Initialization

    init() {
        self.recordRepository = SessionRecordRepository.shared
        refreshRecords()
    }

    // MARK: - Data Operations

    /// Refresh all records from repository
    func refreshRecords() {
        allSessionRecords = recordRepository.retrieveAllSessionRecords()
        statisticsSummary = recordRepository.calculateAggregateStatistics()
        applyCurrentFilter()
    }

    /// Apply current filter to records
    func applyCurrentFilter() {
        switch currentFilterCategory {
        case .all:
            filteredRecords = allSessionRecords
        case .singleMode:
            filteredRecords = allSessionRecords.filter { $0.playedGameCategory == .singleTileMode }
        case .challengeMode:
            filteredRecords = allSessionRecords.filter { $0.playedGameCategory == .challengeMultiTileMode }
        }
    }

    /// Delete record at index
    func deleteRecord(at index: Int) {
        guard index < filteredRecords.count else { return }

        let recordToDelete = filteredRecords[index]
        recordRepository.deleteSessionRecord(identifier: recordToDelete.resultUniqueIdentifier)
        refreshRecords()
    }

    /// Delete all records
    func deleteAllRecords() {
        recordRepository.deleteAllSessionRecords()
        refreshRecords()
    }

    // MARK: - Filter Category

    /// Record filter category enumeration
    enum RecordFilterCategory: String, CaseIterable {
        case all = "All"
        case singleMode = "Single"
        case challengeMode = "Challenge"
    }
}
