//
//  GameSessionCoordinator.swift
//  Beamway
//
//  Session lifecycle coordination and management
//

import UIKit

/// Protocol defining session lifecycle delegate methods
protocol GameSessionLifecycleDelegate: AnyObject {
    /// Called when session state changes
    func sessionStateDidChange(to newState: GameSessionState)

    /// Called when session should display game over
    func sessionDidRequestGameOverPresentation(result: SessionResultDataModel)

    /// Called when session requests pause overlay
    func sessionDidRequestPauseOverlay()

    /// Called when session requests dismiss pause overlay
    func sessionDidRequestDismissPauseOverlay()
}

/// Enumeration representing possible game session states
enum GameSessionState: Equatable {
    case uninitialized
    case preparing
    case active
    case paused
    case concluded(reason: SessionTerminationReason)

    /// Human-readable state description
    var stateDescription: String {
        switch self {
        case .uninitialized:
            return "Uninitialized"
        case .preparing:
            return "Preparing"
        case .active:
            return "Active"
        case .paused:
            return "Paused"
        case .concluded(let reason):
            return "Concluded: \(reason.terminationDescription)"
        }
    }

    /// Whether session is in active gameplay state
    var isActiveGameplay: Bool {
        switch self {
        case .active:
            return true
        default:
            return false
        }
    }
}

/// Central coordinator managing game session lifecycle and subsystem orchestration
final class GameSessionCoordinator {

    // MARK: - Type Definitions

    /// Session event handler closure type
    typealias SessionEventHandler = (GameSessionEvent) -> Void

    /// Timer tick handler closure type
    typealias TimerTickHandler = (TimeInterval) -> Void

    // MARK: - Properties

    /// Current session state
    private(set) var currentSessionState: GameSessionState = .uninitialized

    /// Session configuration parameters
    private let sessionConfiguration: GameSessionConfiguration

    /// Lifecycle delegate reference
    weak var lifecycleDelegate: GameSessionLifecycleDelegate?

    /// Game loop timer reference
    private var gameLoopDisplayLink: CADisplayLink?

    /// Session chronometer timer
    private var sessionChronometerTimer: Timer?

    /// Projectile spawn timer
    private var projectileSpawnTimer: Timer?

    /// Session start timestamp
    private var sessionInitiationTimestamp: Date?

    /// Pause start timestamp for duration calculation
    private var pauseInitiationTimestamp: Date?

    /// Accumulated pause duration
    private var accumulatedPauseDuration: TimeInterval = 0

    /// Current elapsed session time
    private(set) var currentElapsedSessionTime: TimeInterval = 0

    /// Game orchestrator reference
    private let gameplayOrchestrator: GameplayOrchestrator

    /// Collision processing engine
    private let collisionProcessor: CollisionProcessingEngine

    /// Scoring processing engine
    private let scoringProcessor: ScoringProcessingEngine

    /// Projectile spawning controller
    private let projectileSpawner: ProjectileSpawningController

    /// HUD manager reference
    private let headsUpDisplayManager: SessionHeadsUpDisplayManager

    /// Touch feedback controller
    private let touchFeedbackController: TouchFeedbackController

    /// Session record repository
    private let sessionRecordRepository: SessionRecordRepository

    /// Session event handler callback
    var sessionEventHandler: SessionEventHandler?

    /// Timer tick handler callback
    var timerTickHandler: TimerTickHandler?

    /// Current score value
    private(set) var currentScoreValue: Int = 0

    /// Current health points
    private(set) var currentHealthPoints: Int = 3

    /// Current level number
    private(set) var currentLevelNumber: Int = 1

    /// Current combo streak
    private(set) var currentComboStreak: Int = 0

    /// Peak combo achieved
    private(set) var peakComboAchieved: Int = 0

    /// Total projectiles dodged
    private(set) var totalProjectilesDodged: Int = 0

    /// Total collisions recorded
    private(set) var totalCollisionsRecorded: Int = 0

    /// Maximum health capacity
    private let maximumHealthCapacity: Int = 3

    /// Frame update callback
    var frameUpdateCallback: (() -> Void)?

    // MARK: - Initialization

    init(configuration: GameSessionConfiguration) {
        self.sessionConfiguration = configuration
        self.gameplayOrchestrator = GameplayOrchestrator(configuration: configuration)
        self.collisionProcessor = CollisionProcessingEngine()
        self.scoringProcessor = ScoringProcessingEngine()
        self.projectileSpawner = ProjectileSpawningController()
        self.headsUpDisplayManager = SessionHeadsUpDisplayManager()
        self.touchFeedbackController = TouchFeedbackController.shared
        self.sessionRecordRepository = SessionRecordRepository.shared

        configureSubsystemCallbacks()
    }

    // MARK: - Configuration

    /// Configure all subsystem callbacks
    private func configureSubsystemCallbacks() {
        configureScoringCallbacks()
        configureCollisionCallbacks()
        configureProjectileCallbacks()
    }

    /// Configure scoring system callbacks
    private func configureScoringCallbacks() {
        scoringProcessor.scoreUpdateCallback = { [weak self] event in
            self?.handleScoreUpdateEvent(event)
        }

        scoringProcessor.comboUpdateCallback = { [weak self] event in
            self?.handleComboUpdateEvent(event)
        }
    }

    /// Configure collision system callbacks
    private func configureCollisionCallbacks() {
        collisionProcessor.collisionEventCallback = { [weak self] event in
            self?.handleCollisionEvent(event)
        }
    }

    /// Configure projectile system callbacks
    private func configureProjectileCallbacks() {
        projectileSpawner.projectileSpawnCallback = { [weak self] config in
            self?.handleProjectileSpawnEvent(config)
        }

        projectileSpawner.projectileRemovalCallback = { [weak self] identifier in
            self?.handleProjectileRemovalEvent(identifier)
        }
    }

    // MARK: - Session Lifecycle

    /// Initialize session to starting state
    func initializeSessionState() {
        guard currentSessionState == .uninitialized else { return }

        transitionToState(.preparing)

        currentScoreValue = 0
        currentHealthPoints = maximumHealthCapacity
        currentLevelNumber = 1
        currentComboStreak = 0
        peakComboAchieved = 0
        totalProjectilesDodged = 0
        totalCollisionsRecorded = 0
        currentElapsedSessionTime = 0
        accumulatedPauseDuration = 0

        scoringProcessor.resetAllScoringState()
        collisionProcessor.resetAllCollisionState()

        sessionEventHandler?(.sessionInitialized)
    }

    /// Commence active session gameplay
    func commenceSessionGameplay() {
        guard currentSessionState == .preparing || currentSessionState == .paused else { return }

        sessionInitiationTimestamp = sessionInitiationTimestamp ?? Date()

        transitionToState(.active)

        startGameLoopTimer()
        startChronometerTimer()
        activateProjectileSpawning()

        sessionEventHandler?(.sessionStarted)
    }

    /// Pause session gameplay
    func pauseSessionGameplay() {
        guard currentSessionState == .active else { return }

        pauseInitiationTimestamp = Date()

        transitionToState(.paused)

        suspendAllTimers()
        projectileSpawner.pauseSpawningSystem()

        lifecycleDelegate?.sessionDidRequestPauseOverlay()
        sessionEventHandler?(.sessionPaused)

        touchFeedbackController.generateButtonPressFeedback()
    }

    /// Resume session from paused state
    func resumeSessionGameplay() {
        guard currentSessionState == .paused else { return }

        if let pauseStart = pauseInitiationTimestamp {
            accumulatedPauseDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseInitiationTimestamp = nil

        transitionToState(.active)

        startGameLoopTimer()
        startChronometerTimer()
        projectileSpawner.resumeSpawningSystem()

        lifecycleDelegate?.sessionDidRequestDismissPauseOverlay()
        sessionEventHandler?(.sessionResumed)

        touchFeedbackController.generateButtonPressFeedback()
    }

    /// Conclude session with specified termination reason
    func concludeSession(reason: SessionTerminationReason) {
        guard currentSessionState != .concluded(reason: reason) else { return }

        transitionToState(.concluded(reason: reason))

        suspendAllTimers()
        projectileSpawner.deactivateSpawningSystem()

        let sessionResult = generateSessionResult(terminationReason: reason)
        persistSessionResult(sessionResult)

        lifecycleDelegate?.sessionDidRequestGameOverPresentation(result: sessionResult)
        sessionEventHandler?(.sessionConcluded(result: sessionResult))

        touchFeedbackController.generateGameOverFeedback()
    }

    /// Reset session for replay
    func resetSessionForReplay() {
        suspendAllTimers()
        projectileSpawner.deactivateSpawningSystem()
        projectileSpawner.clearAllActiveProjectiles()

        currentSessionState = .uninitialized
        sessionInitiationTimestamp = nil
        pauseInitiationTimestamp = nil
        accumulatedPauseDuration = 0

        initializeSessionState()
    }

    // MARK: - State Management

    /// Transition to new session state
    private func transitionToState(_ newState: GameSessionState) {
        let previousState = currentSessionState
        currentSessionState = newState

        lifecycleDelegate?.sessionStateDidChange(to: newState)

        NotificationCenter.default.post(
            name: .gameSessionStateChanged,
            object: self,
            userInfo: [
                "previousState": previousState,
                "newState": newState
            ]
        )
    }

    // MARK: - Timer Management

    /// Start game loop display link timer
    private func startGameLoopTimer() {
        gameLoopDisplayLink?.invalidate()

        gameLoopDisplayLink = CADisplayLink(target: self, selector: #selector(processGameLoopFrame))
        gameLoopDisplayLink?.preferredFramesPerSecond = 60
        gameLoopDisplayLink?.add(to: .main, forMode: .common)
    }

    /// Start chronometer timer
    private func startChronometerTimer() {
        sessionChronometerTimer?.invalidate()

        sessionChronometerTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.processChronometerTick()
        }
    }

    /// Suspend all active timers
    private func suspendAllTimers() {
        gameLoopDisplayLink?.invalidate()
        gameLoopDisplayLink = nil

        sessionChronometerTimer?.invalidate()
        sessionChronometerTimer = nil
    }

    /// Activate projectile spawning system
    private func activateProjectileSpawning() {
        projectileSpawner.activateSpawningSystem()
    }

    // MARK: - Frame Processing

    /// Process single game loop frame
    @objc private func processGameLoopFrame() {
        guard currentSessionState.isActiveGameplay else { return }

        frameUpdateCallback?()
    }

    /// Process chronometer tick
    private func processChronometerTick() {
        guard currentSessionState.isActiveGameplay else { return }

        currentElapsedSessionTime += 1
        timerTickHandler?(currentElapsedSessionTime)
        headsUpDisplayManager.updateChronometerDisplay(elapsedSeconds: currentElapsedSessionTime)
    }

    // MARK: - Event Handlers

    /// Handle score update event from scoring engine
    private func handleScoreUpdateEvent(_ event: ScoreUpdateEvent) {
        currentScoreValue = event.newScore

        headsUpDisplayManager.updateScoreDisplay(newScore: event.newScore, animated: true)

        evaluateLevelAdvancement()

        sessionEventHandler?(.scoreUpdated(newScore: event.newScore, delta: event.pointsDelta))
    }

    /// Handle combo update event from scoring engine
    private func handleComboUpdateEvent(_ event: ComboUpdateEvent) {
        currentComboStreak = event.newCombo

        if event.newCombo > peakComboAchieved {
            peakComboAchieved = event.newCombo
        }

        headsUpDisplayManager.updateComboStreakDisplay(newStreak: event.newCombo)

        if event.newCombo > 0 {
            touchFeedbackController.generateComboIncreaseFeedback(comboLevel: event.newCombo)
        }

        sessionEventHandler?(.comboUpdated(newCombo: event.newCombo))
    }

    /// Handle collision event from collision engine
    private func handleCollisionEvent(_ event: CollisionDetectionEvent) {
        totalCollisionsRecorded += 1

        applyHealthDamage(amount: 1)
        scoringProcessor.registerCollisionEvent()
        headsUpDisplayManager.resetComboStreak()

        touchFeedbackController.generateCollisionFeedback()

        sessionEventHandler?(.collisionOccurred(
            projectileId: event.projectileIdentifier,
            blockId: event.blockIdentifier
        ))
    }

    /// Handle projectile spawn event
    private func handleProjectileSpawnEvent(_ config: ProjectileSpawnConfiguration) {
        sessionEventHandler?(.projectileSpawned(configuration: config))
    }

    /// Handle projectile removal event
    private func handleProjectileRemovalEvent(_ identifier: String) {
        totalProjectilesDodged += 1
        scoringProcessor.awardPointsForSuccessfulDodge()

        sessionEventHandler?(.projectileDodged(identifier: identifier))
    }

    // MARK: - Game Logic

    /// Apply damage to health points
    private func applyHealthDamage(amount: Int) {
        currentHealthPoints = max(0, currentHealthPoints - amount)

        headsUpDisplayManager.updateHealthDisplay(newHealth: currentHealthPoints, animated: true)

        if currentHealthPoints <= 0 {
            concludeSession(reason: .healthDepleted)
        }
    }

    /// Evaluate and process level advancement
    private func evaluateLevelAdvancement() {
        guard sessionConfiguration.categoryType == .competitiveMultiBlock else { return }

        let calculatedLevel = (currentScoreValue / 10) + 1

        if calculatedLevel > currentLevelNumber {
            currentLevelNumber = calculatedLevel
            headsUpDisplayManager.updateLevelDisplay(newLevel: currentLevelNumber, animated: true)

            touchFeedbackController.generateLevelUpFeedback()

            sessionEventHandler?(.levelAdvanced(newLevel: currentLevelNumber))
        }
    }

    // MARK: - Result Generation

    /// Generate session result data model
    private func generateSessionResult(terminationReason: SessionTerminationReason) -> SessionResultDataModel {
        let finalDuration = calculateFinalSessionDuration()
        let gameCategory = GameCategoryDescriptor.fromCategoryType(sessionConfiguration.categoryType)

        return SessionResultDataModel(
            scoreValue: currentScoreValue,
            gameCategory: gameCategory,
            durationSeconds: finalDuration,
            peakCombo: peakComboAchieved,
            projectilesDodged: totalProjectilesDodged,
            collisionsRecorded: totalCollisionsRecorded,
            levelReached: currentLevelNumber,
            termination: terminationReason
        )
    }

    /// Calculate final session duration accounting for pauses
    private func calculateFinalSessionDuration() -> TimeInterval {
        guard let startTime = sessionInitiationTimestamp else { return 0 }

        var totalDuration = Date().timeIntervalSince(startTime)
        totalDuration -= accumulatedPauseDuration

        if let pauseStart = pauseInitiationTimestamp {
            totalDuration -= Date().timeIntervalSince(pauseStart)
        }

        return max(0, totalDuration)
    }

    /// Persist session result to repository
    private func persistSessionResult(_ result: SessionResultDataModel) {
        sessionRecordRepository.persistSessionResult(result)
    }

    // MARK: - Accessors

    /// Get HUD manager reference
    var hudManager: SessionHeadsUpDisplayManager {
        return headsUpDisplayManager
    }

    /// Get collision processor reference
    var collisionEngine: CollisionProcessingEngine {
        return collisionProcessor
    }

    /// Get projectile spawner reference
    var projectileController: ProjectileSpawningController {
        return projectileSpawner
    }

    /// Get scoring processor reference
    var scoringEngine: ScoringProcessingEngine {
        return scoringProcessor
    }

    /// Get session configuration
    var configuration: GameSessionConfiguration {
        return sessionConfiguration
    }

    /// Check if session is in competitive mode
    var isCompetitiveMode: Bool {
        return sessionConfiguration.categoryType == .competitiveMultiBlock
    }

    // MARK: - Cleanup

    deinit {
        suspendAllTimers()
        projectileSpawner.deactivateSpawningSystem()
    }
}

// MARK: - Session Event Enumeration

/// Enumeration of possible game session events
enum GameSessionEvent {
    case sessionInitialized
    case sessionStarted
    case sessionPaused
    case sessionResumed
    case sessionConcluded(result: SessionResultDataModel)
    case scoreUpdated(newScore: Int, delta: Int)
    case comboUpdated(newCombo: Int)
    case levelAdvanced(newLevel: Int)
    case collisionOccurred(projectileId: String, blockId: String)
    case projectileSpawned(configuration: ProjectileSpawnConfiguration)
    case projectileDodged(identifier: String)
}

// MARK: - Notification Names

extension Notification.Name {
    static let gameSessionStateChanged = Notification.Name("gameSessionStateChanged")
}
