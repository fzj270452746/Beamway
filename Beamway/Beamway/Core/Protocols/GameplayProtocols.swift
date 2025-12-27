//
//  GameplayProtocols.swift
//  Beamway
//
//  Core gameplay protocol definitions
//

import UIKit

// MARK: - Game Entity Protocols

/// Protocol defining requirements for interactive game entities
protocol InteractiveGameEntityProtocol: AnyObject {
    /// Unique identifier for entity tracking
    var entityUniqueIdentifier: String { get }

    /// Current position within game bounds
    var currentPositionCoordinate: CGPoint { get set }

    /// Entity collision bounds rectangle
    var collisionBoundsRectangle: CGRect { get }

    /// Whether entity is currently active in game
    var isEntityActiveInGame: Bool { get set }

    /// Execute entity entrance animation sequence
    func executeEntranceAnimationSequence()

    /// Execute entity exit animation sequence
    func executeExitAnimationSequence(completion: (() -> Void)?)
}

/// Protocol for movable game entities supporting drag interaction
protocol DraggableGameEntityProtocol: InteractiveGameEntityProtocol {
    /// Whether entity is currently being dragged
    var isDraggingActive: Bool { get set }

    /// Last recorded drag position
    var lastRecordedDragPosition: CGPoint { get set }

    /// Containment bounds for drag movement
    var movementContainmentBounds: CGRect { get set }

    /// Process drag gesture state change
    func processDragGestureStateChange(_ gestureState: UIGestureRecognizer.State,
                                        translation: CGPoint,
                                        velocity: CGPoint)

    /// Constrain position within movement bounds
    func constrainPositionWithinBounds(_ proposedPosition: CGPoint) -> CGPoint
}

/// Protocol for projectile game entities
protocol ProjectileGameEntityProtocol: InteractiveGameEntityProtocol {
    /// Projectile movement direction
    var trajectoryDirection: ProjectileTrajectoryDirection { get }

    /// Projectile movement velocity
    var movementVelocity: CGFloat { get }

    /// Origin point for projectile spawn
    var trajectoryOriginPoint: CGPoint { get }

    /// Destination point for projectile path
    var trajectoryTerminusPoint: CGPoint { get }

    /// Execute projectile launch animation along trajectory
    func executeLaunchAlongTrajectory(completionHandler: @escaping () -> Void)

    /// Immediately terminate projectile
    func terminateProjectileImmediately()
}

/// Projectile trajectory direction enumeration
enum ProjectileTrajectoryDirection: CaseIterable {
    case descendingFromTop
    case ascendingFromBottom
    case advancingFromLeft
    case advancingFromRight

    /// Generate random trajectory direction
    static func generateRandomDirection() -> ProjectileTrajectoryDirection {
        return allCases.randomElement() ?? .descendingFromTop
    }

    /// Calculate rotation angle for direction indicator
    var indicatorRotationAngle: CGFloat {
        switch self {
        case .descendingFromTop:
            return 0
        case .ascendingFromBottom:
            return .pi
        case .advancingFromLeft:
            return .pi / 2
        case .advancingFromRight:
            return -.pi / 2
        }
    }
}

// MARK: - Collision Detection Protocols

/// Protocol for collision detection system
protocol CollisionDetectionSystemProtocol {
    /// Registered collision entities
    var registeredCollisionEntities: [InteractiveGameEntityProtocol] { get }

    /// Register entity for collision detection
    func registerEntityForCollisionDetection(_ entity: InteractiveGameEntityProtocol)

    /// Unregister entity from collision detection
    func unregisterEntityFromCollisionDetection(_ entity: InteractiveGameEntityProtocol)

    /// Perform collision check between two entities
    func performCollisionCheck(between firstEntity: InteractiveGameEntityProtocol,
                               and secondEntity: InteractiveGameEntityProtocol) -> CollisionCheckResult

    /// Process all registered entity collisions
    func processAllEntityCollisions() -> [CollisionEvent]
}

/// Collision check result structure
struct CollisionCheckResult {
    let collisionDetected: Bool
    let intersectionRectangle: CGRect?
    let penetrationDepth: CGFloat
    let collisionNormal: CGVector

    static let noCollision = CollisionCheckResult(
        collisionDetected: false,
        intersectionRectangle: nil,
        penetrationDepth: 0,
        collisionNormal: .zero
    )
}

/// Collision event structure
struct CollisionEvent {
    let firstEntityIdentifier: String
    let secondEntityIdentifier: String
    let collisionTimestamp: TimeInterval
    let collisionPoint: CGPoint
    let impactMagnitude: CGFloat

    /// Generate unique collision key for deduplication
    var uniqueCollisionKey: String {
        return "\(firstEntityIdentifier)-\(secondEntityIdentifier)"
    }
}

// MARK: - Scoring System Protocols

/// Protocol for scoring system implementation
protocol ScoringSystemProtocol {
    /// Current accumulated score
    var currentAccumulatedScore: Int { get }

    /// Current combo multiplier
    var currentComboMultiplier: Int { get }

    /// Peak score achieved in session
    var peakSessionScore: Int { get }

    /// Peak combo achieved in session
    var peakSessionCombo: Int { get }

    /// Award points for successful dodge
    func awardPointsForDodge(basePoints: Int)

    /// Increment combo multiplier
    func incrementComboMultiplier()

    /// Reset combo multiplier
    func resetComboMultiplier()

    /// Reset all scoring state
    func resetAllScoringState()
}

/// Protocol for score change observation
protocol ScoringSystemObserverProtocol: AnyObject {
    /// Called when score changes
    func scoringSystemDidUpdateScore(_ newScore: Int, delta: Int)

    /// Called when combo changes
    func scoringSystemDidUpdateCombo(_ newCombo: Int)

    /// Called when combo is broken
    func scoringSystemDidBreakCombo(finalCombo: Int)
}

// MARK: - Game Session Protocols

/// Protocol for game session management
protocol GameSessionManagerProtocol: AnyObject {
    /// Current session state
    var currentSessionState: GameSessionState { get }

    /// Session configuration
    var sessionConfiguration: GameSessionConfiguration { get }

    /// Session elapsed time
    var sessionElapsedTime: TimeInterval { get }

    /// Initialize game session
    func initializeGameSession()

    /// Start game session
    func startGameSession()

    /// Pause game session
    func pauseGameSession()

    /// Resume game session
    func resumeGameSession()

    /// Terminate game session
    func terminateGameSession()
}

/// Protocol session state enumeration (for generic protocol use)
enum ProtocolSessionState {
    case uninitialized
    case initialized
    case running
    case paused
    case completed
    case terminated
}

/// Protocol for game session observation
protocol GameSessionObserverProtocol: AnyObject {
    /// Called when session state changes
    func gameSessionDidChangeState(_ newState: GameSessionState)

    /// Called when session time updates
    func gameSessionDidUpdateTime(_ elapsedTime: TimeInterval)

    /// Called when session completes
    func gameSessionDidComplete(finalScore: Int, finalTime: TimeInterval)
}

// MARK: - Health System Protocols

/// Protocol for health/lives system
protocol HealthSystemProtocol {
    /// Current health points
    var currentHealthPoints: Int { get }

    /// Maximum health points
    var maximumHealthPoints: Int { get }

    /// Whether health is depleted
    var isHealthDepleted: Bool { get }

    /// Apply damage to health
    func applyDamage(amount: Int)

    /// Restore health points
    func restoreHealth(amount: Int)

    /// Reset health to maximum
    func resetHealthToMaximum()
}

/// Protocol for health system observation
protocol HealthSystemObserverProtocol: AnyObject {
    /// Called when health changes
    func healthSystemDidUpdateHealth(_ currentHealth: Int, maxHealth: Int)

    /// Called when damage is taken
    func healthSystemDidTakeDamage(remainingHealth: Int)

    /// Called when health is depleted
    func healthSystemDidDepleteHealth()
}

// MARK: - Difficulty Progression Protocols

/// Protocol for difficulty progression system
protocol DifficultyProgressionProtocol {
    /// Current difficulty factor (0.0 to 1.0+)
    var currentDifficultyFactor: CGFloat { get }

    /// Current level/stage number
    var currentProgressionLevel: Int { get }

    /// Calculate spawn frequency for current difficulty
    func calculateSpawnFrequency() -> TimeInterval

    /// Calculate projectile velocity for current difficulty
    func calculateProjectileVelocity() -> CGFloat

    /// Advance progression based on score
    func advanceProgressionForScore(_ score: Int)

    /// Advance progression based on time
    func advanceProgressionForTime(_ elapsedTime: TimeInterval)
}

// MARK: - Spawning System Protocols

/// Protocol for entity spawning system
protocol EntitySpawningSystemProtocol {
    /// Spawning system delegate
    var spawningDelegate: EntitySpawningDelegate? { get set }

    /// Whether spawning is currently active
    var isSpawningActive: Bool { get }

    /// Current spawn frequency
    var currentSpawnFrequency: TimeInterval { get }

    /// Start entity spawning
    func startEntitySpawning()

    /// Stop entity spawning
    func stopEntitySpawning()

    /// Update spawn frequency
    func updateSpawnFrequency(_ newFrequency: TimeInterval)

    /// Spawn single entity immediately
    func spawnEntityImmediately() -> InteractiveGameEntityProtocol?
}

/// Entity spawning delegate protocol
protocol EntitySpawningDelegate: AnyObject {
    /// Called when entity is spawned
    func spawningSystemDidSpawnEntity(_ entity: InteractiveGameEntityProtocol)

    /// Called when entity should be removed
    func spawningSystemDidRequestEntityRemoval(_ entity: InteractiveGameEntityProtocol)
}
