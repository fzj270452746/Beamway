//
//  GameplayOrchestrator.swift
//  Beamway
//
//  Central game loop and state orchestration
//

import UIKit

/// Central orchestrator managing game loop execution and state coordination
/// Responsible for frame-by-frame game updates and subsystem coordination
final class GameplayOrchestrator {

    // MARK: - Type Definitions

    /// Game loop update callback type
    typealias FrameUpdateCallback = (GameFrameContext) -> Void

    /// Session completion callback type
    typealias SessionCompletionCallback = (GameSessionResult) -> Void

    // MARK: - Singleton Access

    /// Shared orchestrator instance
    static let shared = GameplayOrchestrator()

    // MARK: - Properties

    /// Current gameplay state
    private(set) var currentGameplayState: GameplayState = .dormant

    /// Active game session configuration
    private(set) var activeSessionConfiguration: GameSessionConfiguration?

    /// Frame update display link
    private var displayLinkController: CADisplayLink?

    /// Projectile spawning timer
    private var projectileSpawnScheduler: Timer?

    /// Chronometer update timer
    private var chronometerUpdateTimer: Timer?

    /// Session commencement timestamp
    private var sessionCommencementTimestamp: Date?

    /// Total elapsed session time (accounting for pauses)
    private var accumulatedSessionDuration: TimeInterval = 0

    /// Pause commencement timestamp
    private var pauseCommencementTimestamp: Date?

    /// Frame update callback
    var frameUpdateCallback: FrameUpdateCallback?

    /// Session completion callback
    var sessionCompletionCallback: SessionCompletionCallback?

    /// Observers for gameplay state changes
    private var stateChangeObservers: [GameplayStateObserver] = []

    /// Current frame context
    private var currentFrameContext: GameFrameContext

    /// Target frame rate (60 FPS)
    private let targetFrameInterval: TimeInterval = 1.0 / 60.0

    /// Subsystem coordinator
    private let subsystemCoordinator: GameSubsystemCoordinator

    // MARK: - Initialization

    private init() {
        self.currentFrameContext = GameFrameContext()
        self.subsystemCoordinator = GameSubsystemCoordinator()
    }

    /// Initialize with configuration (for use by GameSessionCoordinator)
    init(configuration: GameSessionConfiguration) {
        self.currentFrameContext = GameFrameContext()
        self.subsystemCoordinator = GameSubsystemCoordinator()
        self.activeSessionConfiguration = configuration
        subsystemCoordinator.initializeAllSubsystems(with: configuration)
    }

    // MARK: - Session Lifecycle Management

    /// Initialize a new gameplay session with specified configuration
    func initializeGameplaySession(configuration: GameSessionConfiguration) {
        guard currentGameplayState == .dormant || currentGameplayState == .concluded else {
            return
        }

        activeSessionConfiguration = configuration
        currentFrameContext = GameFrameContext()
        accumulatedSessionDuration = 0
        sessionCommencementTimestamp = nil
        pauseCommencementTimestamp = nil

        subsystemCoordinator.initializeAllSubsystems(with: configuration)

        transitionToState(.initialized)
    }

    /// Commence gameplay execution
    func commenceGameplayExecution() {
        guard currentGameplayState == .initialized else {
            return
        }

        sessionCommencementTimestamp = Date()
        activateDisplayLink()
        activateProjectileSpawning()
        activateChronometerUpdates()

        transitionToState(.executing)
    }

    /// Suspend gameplay execution temporarily
    func suspendGameplayExecution() {
        guard currentGameplayState == .executing else {
            return
        }

        pauseCommencementTimestamp = Date()
        deactivateDisplayLink()
        deactivateProjectileSpawning()
        deactivateChronometerUpdates()

        transitionToState(.suspended)
    }

    /// Resume gameplay execution from suspension
    func resumeGameplayExecution() {
        guard currentGameplayState == .suspended else {
            return
        }

        if let pauseStart = pauseCommencementTimestamp {
            let pauseDuration = Date().timeIntervalSince(pauseStart)
            sessionCommencementTimestamp = sessionCommencementTimestamp?.addingTimeInterval(pauseDuration)
        }
        pauseCommencementTimestamp = nil

        activateDisplayLink()
        activateProjectileSpawning()
        activateChronometerUpdates()

        transitionToState(.executing)
    }

    /// Conclude gameplay session with final result
    func concludeGameplaySession(reason: SessionConclusionReason) {
        guard currentGameplayState == .executing || currentGameplayState == .suspended else {
            return
        }

        deactivateDisplayLink()
        deactivateProjectileSpawning()
        deactivateChronometerUpdates()

        let sessionResult = generateSessionResult(reason: reason)
        subsystemCoordinator.terminateAllSubsystems()

        transitionToState(.concluded)

        sessionCompletionCallback?(sessionResult)
    }

    /// Reset orchestrator to dormant state
    func resetToDormantState() {
        deactivateDisplayLink()
        deactivateProjectileSpawning()
        deactivateChronometerUpdates()

        activeSessionConfiguration = nil
        currentFrameContext = GameFrameContext()
        accumulatedSessionDuration = 0
        sessionCommencementTimestamp = nil
        pauseCommencementTimestamp = nil

        transitionToState(.dormant)
    }

    // MARK: - State Management

    /// Transition to new gameplay state
    private func transitionToState(_ newState: GameplayState) {
        let previousState = currentGameplayState
        currentGameplayState = newState

        stateChangeObservers.forEach { observer in
            observer.gameplayOrchestrator(self, didTransitionFrom: previousState, to: newState)
        }
    }

    // MARK: - Display Link Management

    /// Activate frame update display link
    private func activateDisplayLink() {
        displayLinkController?.invalidate()
        displayLinkController = CADisplayLink(target: self, selector: #selector(processFrameUpdate(_:)))
        if #available(iOS 15.0, *) {
            displayLinkController?.preferredFrameRateRange = CAFrameRateRange(
                minimum: 30,
                maximum: 60,
                preferred: 60
            )
        } else {
            displayLinkController?.preferredFramesPerSecond = 60
        }
        displayLinkController?.add(to: .main, forMode: .common)
    }

    /// Deactivate frame update display link
    private func deactivateDisplayLink() {
        displayLinkController?.invalidate()
        displayLinkController = nil
    }

    /// Process frame update from display link
    @objc private func processFrameUpdate(_ displayLink: CADisplayLink) {
        guard currentGameplayState == .executing else { return }

        let currentTimestamp = Date()
        let frameDeltaTime = displayLink.targetTimestamp - displayLink.timestamp

        currentFrameContext.frameNumber += 1
        currentFrameContext.frameDeltaTime = frameDeltaTime
        currentFrameContext.totalElapsedTime = calculateTotalElapsedTime()
        currentFrameContext.frameTimestamp = currentTimestamp

        subsystemCoordinator.processFrameUpdate(context: currentFrameContext)

        frameUpdateCallback?(currentFrameContext)
    }

    // MARK: - Projectile Spawning Management

    /// Activate projectile spawning system
    private func activateProjectileSpawning() {
        projectileSpawnScheduler?.invalidate()

        let initialSpawnInterval = subsystemCoordinator.calculateCurrentSpawnInterval()
        scheduleNextProjectileSpawn(interval: initialSpawnInterval)
    }

    /// Deactivate projectile spawning system
    private func deactivateProjectileSpawning() {
        projectileSpawnScheduler?.invalidate()
        projectileSpawnScheduler = nil
    }

    /// Schedule next projectile spawn
    private func scheduleNextProjectileSpawn(interval: TimeInterval) {
        projectileSpawnScheduler?.invalidate()

        projectileSpawnScheduler = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self, self.currentGameplayState == .executing else { return }

            self.subsystemCoordinator.triggerProjectileSpawn()

            let nextInterval = self.subsystemCoordinator.calculateCurrentSpawnInterval()
            self.scheduleNextProjectileSpawn(interval: nextInterval)
        }
    }

    // MARK: - Chronometer Management

    /// Activate chronometer updates
    private func activateChronometerUpdates() {
        chronometerUpdateTimer?.invalidate()

        chronometerUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.currentGameplayState == .executing else { return }
            self.accumulatedSessionDuration = self.calculateTotalElapsedTime()
        }
    }

    /// Deactivate chronometer updates
    private func deactivateChronometerUpdates() {
        chronometerUpdateTimer?.invalidate()
        chronometerUpdateTimer = nil
    }

    /// Calculate total elapsed session time
    private func calculateTotalElapsedTime() -> TimeInterval {
        guard let startTime = sessionCommencementTimestamp else {
            return accumulatedSessionDuration
        }
        return Date().timeIntervalSince(startTime)
    }

    // MARK: - Session Result Generation

    /// Generate session result from current state
    private func generateSessionResult(reason: SessionConclusionReason) -> GameSessionResult {
        let finalStatistics = subsystemCoordinator.collectFinalStatistics()

        return GameSessionResult(
            conclusionReason: reason,
            finalScoreValue: finalStatistics.totalScore,
            totalDurationSeconds: accumulatedSessionDuration,
            peakComboAchieved: finalStatistics.peakCombo,
            projectilesDodged: finalStatistics.projectilesDodged,
            projectilesCollided: finalStatistics.projectilesCollided,
            levelReached: finalStatistics.levelReached,
            sessionConfiguration: activeSessionConfiguration
        )
    }

    // MARK: - Observer Management

    /// Register gameplay state observer
    func registerStateObserver(_ observer: GameplayStateObserver) {
        stateChangeObservers.append(observer)
    }

    /// Unregister gameplay state observer
    func unregisterStateObserver(_ observer: GameplayStateObserver) {
        stateChangeObservers.removeAll { $0 === observer }
    }

    // MARK: - External Access

    /// Get current elapsed session time
    var currentSessionElapsedTime: TimeInterval {
        return calculateTotalElapsedTime()
    }

    /// Get subsystem coordinator for direct access
    var gameSubsystemCoordinator: GameSubsystemCoordinator {
        return subsystemCoordinator
    }
}

// MARK: - Supporting Types

/// Gameplay execution state enumeration
enum GameplayState {
    case dormant
    case initialized
    case executing
    case suspended
    case concluded
}

/// Session conclusion reason enumeration
enum SessionConclusionReason {
    case healthDepleted
    case userExited
    case timeExpired
    case errorOccurred
}

/// Game frame context structure
struct GameFrameContext {
    var frameNumber: UInt64 = 0
    var frameDeltaTime: TimeInterval = 0
    var totalElapsedTime: TimeInterval = 0
    var frameTimestamp: Date = Date()
}

/// Game session result structure
struct GameSessionResult {
    let conclusionReason: SessionConclusionReason
    let finalScoreValue: Int
    let totalDurationSeconds: TimeInterval
    let peakComboAchieved: Int
    let projectilesDodged: Int
    let projectilesCollided: Int
    let levelReached: Int
    let sessionConfiguration: GameSessionConfiguration?

    /// Format duration as string
    var formattedDuration: String {
        let minutes = Int(totalDurationSeconds) / 60
        let seconds = Int(totalDurationSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Final statistics structure
struct FinalGameStatistics {
    let totalScore: Int
    let peakCombo: Int
    let projectilesDodged: Int
    let projectilesCollided: Int
    let levelReached: Int
}

/// Gameplay state observer protocol
protocol GameplayStateObserver: AnyObject {
    func gameplayOrchestrator(_ orchestrator: GameplayOrchestrator,
                              didTransitionFrom previousState: GameplayState,
                              to newState: GameplayState)
}

// MARK: - Game Subsystem Coordinator

/// Coordinator managing all game subsystems
final class GameSubsystemCoordinator {

    // MARK: - Subsystem References

    private var collisionProcessor: CollisionProcessingEngine?
    private var scoringProcessor: ScoringProcessingEngine?
    private var difficultyProgressionManager: DifficultyProgressionManager?

    // MARK: - State Properties

    private var activeConfiguration: GameSessionConfiguration?
    private var sessionStartTime: Date?

    // MARK: - Initialization

    /// Initialize all subsystems with configuration
    func initializeAllSubsystems(with configuration: GameSessionConfiguration) {
        activeConfiguration = configuration
        sessionStartTime = nil

        collisionProcessor = CollisionProcessingEngine()
        scoringProcessor = ScoringProcessingEngine()
        difficultyProgressionManager = DifficultyProgressionManager(configuration: configuration)
    }

    /// Process frame update across all subsystems
    func processFrameUpdate(context: GameFrameContext) {
        if sessionStartTime == nil {
            sessionStartTime = context.frameTimestamp
        }

        collisionProcessor?.processCollisionDetection()
        difficultyProgressionManager?.updateProgression(elapsedTime: context.totalElapsedTime)
    }

    /// Calculate current spawn interval based on difficulty
    func calculateCurrentSpawnInterval() -> TimeInterval {
        return difficultyProgressionManager?.currentSpawnInterval ?? 3.0
    }

    /// Trigger projectile spawn
    func triggerProjectileSpawn() {
        // Spawn trigger notification handled by delegate
    }

    /// Collect final game statistics
    func collectFinalStatistics() -> FinalGameStatistics {
        return FinalGameStatistics(
            totalScore: scoringProcessor?.currentTotalScore ?? 0,
            peakCombo: scoringProcessor?.peakComboValue ?? 0,
            projectilesDodged: scoringProcessor?.totalProjectilesDodged ?? 0,
            projectilesCollided: scoringProcessor?.totalCollisions ?? 0,
            levelReached: difficultyProgressionManager?.currentLevelNumber ?? 1
        )
    }

    /// Terminate all subsystems
    func terminateAllSubsystems() {
        collisionProcessor = nil
        scoringProcessor = nil
        difficultyProgressionManager = nil
        activeConfiguration = nil
        sessionStartTime = nil
    }
}
