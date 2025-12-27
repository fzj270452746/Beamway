//
//  ProjectileSpawningController.swift
//  Beamway
//
//  Projectile spawning and trajectory management system
//

import UIKit

/// Controller managing projectile entity spawning and trajectory calculation
/// Handles spawn timing, direction randomization, and difficulty-based frequency adjustment
final class ProjectileSpawningController {

    // MARK: - Type Definitions

    /// Spawn event callback type
    typealias ProjectileSpawnCallback = (ProjectileSpawnConfiguration) -> Void

    /// Projectile removal callback type
    typealias ProjectileRemovalCallback = (String) -> Void

    // MARK: - Properties

    /// Whether spawning system is currently active
    private(set) var isSpawningSystemActive: Bool = false

    /// Current spawn interval in seconds
    private(set) var currentSpawnIntervalSeconds: TimeInterval

    /// Minimum spawn interval (fastest spawn rate)
    private let minimumSpawnIntervalSeconds: TimeInterval

    /// Maximum spawn interval (slowest spawn rate)
    private let maximumSpawnIntervalSeconds: TimeInterval

    /// Spawn scheduling timer
    private var spawnSchedulingTimer: Timer?

    /// Difficulty progression reference
    private let difficultyProgressionManager: DifficultyProgressionManager

    /// Spawn event callback
    var projectileSpawnCallback: ProjectileSpawnCallback?

    /// Projectile removal callback
    var projectileRemovalCallback: ProjectileRemovalCallback?

    /// Play zone bounds for trajectory calculation
    private var activePlayZoneBounds: CGRect = .zero

    /// Projectile movement velocity
    private var baseProjectileVelocity: CGFloat

    /// Projectile dimensions
    private let projectileDimensions: CGSize

    /// Active projectile tracking
    private var activeProjectileIdentifiers: Set<String> = []

    // MARK: - Initialization

    init(configuration: SpawningConfiguration = .defaultConfiguration) {
        self.minimumSpawnIntervalSeconds = configuration.minimumSpawnInterval
        self.maximumSpawnIntervalSeconds = configuration.maximumSpawnInterval
        self.currentSpawnIntervalSeconds = configuration.maximumSpawnInterval
        self.baseProjectileVelocity = configuration.baseProjectileVelocity
        self.projectileDimensions = configuration.projectileDimensions
        self.difficultyProgressionManager = DifficultyProgressionManager(
            configuration: GameSessionConfiguration(categoryType: .individualChallenge)
        )
    }

    // MARK: - Configuration

    /// Configure play zone bounds for trajectory calculations
    func configurePlayZoneBounds(_ bounds: CGRect) {
        activePlayZoneBounds = bounds
    }

    /// Update spawn interval based on difficulty progression
    func updateSpawnIntervalFromProgression() {
        currentSpawnIntervalSeconds = difficultyProgressionManager.currentSpawnInterval
    }

    // MARK: - Spawning System Control

    /// Activate projectile spawning system
    func activateSpawningSystem() {
        guard !isSpawningSystemActive else { return }

        isSpawningSystemActive = true
        scheduleNextSpawnEvent()
    }

    /// Deactivate projectile spawning system
    func deactivateSpawningSystem() {
        isSpawningSystemActive = false
        spawnSchedulingTimer?.invalidate()
        spawnSchedulingTimer = nil
    }

    /// Pause spawning temporarily
    func pauseSpawningSystem() {
        spawnSchedulingTimer?.invalidate()
        spawnSchedulingTimer = nil
    }

    /// Resume spawning from pause
    func resumeSpawningSystem() {
        guard isSpawningSystemActive else { return }
        scheduleNextSpawnEvent()
    }

    // MARK: - Spawn Scheduling

    /// Schedule next projectile spawn event
    private func scheduleNextSpawnEvent() {
        spawnSchedulingTimer?.invalidate()

        updateSpawnIntervalFromProgression()

        spawnSchedulingTimer = Timer.scheduledTimer(withTimeInterval: currentSpawnIntervalSeconds, repeats: false) { [weak self] _ in
            guard let self = self, self.isSpawningSystemActive else { return }

            self.executeProjectileSpawn()
            self.scheduleNextSpawnEvent()
        }
    }

    /// Execute single projectile spawn
    private func executeProjectileSpawn() {
        let spawnConfiguration = generateSpawnConfiguration()

        activeProjectileIdentifiers.insert(spawnConfiguration.uniqueIdentifier)

        projectileSpawnCallback?(spawnConfiguration)
    }

    /// Trigger immediate projectile spawn (for external calls)
    func triggerImmediateSpawn() {
        guard isSpawningSystemActive else { return }
        executeProjectileSpawn()
    }

    // MARK: - Spawn Configuration Generation

    /// Generate complete spawn configuration for new projectile
    private func generateSpawnConfiguration() -> ProjectileSpawnConfiguration {
        let trajectoryDirection = selectTrajectoryDirection()
        let trajectoryPoints = calculateTrajectoryPoints(for: trajectoryDirection)
        let travelDuration = calculateTravelDuration(
            from: trajectoryPoints.origin,
            to: trajectoryPoints.terminus
        )

        return ProjectileSpawnConfiguration(
            uniqueIdentifier: UUID().uuidString,
            trajectoryDirection: trajectoryDirection,
            originPoint: trajectoryPoints.origin,
            terminusPoint: trajectoryPoints.terminus,
            travelDurationSeconds: travelDuration,
            projectileDimensions: projectileDimensions,
            visualConfiguration: ProjectileVisualConfiguration.defaultConfiguration
        )
    }

    /// Select trajectory direction with optional weighting
    private func selectTrajectoryDirection() -> ProjectileTrajectoryDirection {
        return ProjectileTrajectoryDirection.generateRandomDirection()
    }

    /// Calculate trajectory origin and terminus points for direction
    private func calculateTrajectoryPoints(for direction: ProjectileTrajectoryDirection) -> (origin: CGPoint, terminus: CGPoint) {
        let bounds = activePlayZoneBounds
        let dimension = projectileDimensions.width
        let padding = dimension

        switch direction {
        case .descendingFromTop:
            let xPosition = CGFloat.random(in: padding...(bounds.width - padding))
            let origin = CGPoint(x: xPosition, y: -dimension)
            let terminus = CGPoint(x: xPosition, y: bounds.height + dimension)
            return (origin, terminus)

        case .ascendingFromBottom:
            let xPosition = CGFloat.random(in: padding...(bounds.width - padding))
            let origin = CGPoint(x: xPosition, y: bounds.height + dimension)
            let terminus = CGPoint(x: xPosition, y: -dimension)
            return (origin, terminus)

        case .advancingFromLeft:
            let yPosition = CGFloat.random(in: padding...(bounds.height - padding))
            let origin = CGPoint(x: -dimension, y: yPosition)
            let terminus = CGPoint(x: bounds.width + dimension, y: yPosition)
            return (origin, terminus)

        case .advancingFromRight:
            let yPosition = CGFloat.random(in: padding...(bounds.height - padding))
            let origin = CGPoint(x: bounds.width + dimension, y: yPosition)
            let terminus = CGPoint(x: -dimension, y: yPosition)
            return (origin, terminus)
        }
    }

    /// Calculate travel duration based on distance and velocity
    private func calculateTravelDuration(from origin: CGPoint, to terminus: CGPoint) -> TimeInterval {
        let deltaX = terminus.x - origin.x
        let deltaY = terminus.y - origin.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)

        let adjustedVelocity = baseProjectileVelocity * difficultyProgressionManager.velocityMultiplier

        return TimeInterval(distance / adjustedVelocity)
    }

    // MARK: - Projectile Lifecycle Management

    /// Register projectile completion (dodged successfully)
    func registerProjectileCompletion(identifier: String) {
        activeProjectileIdentifiers.remove(identifier)
        projectileRemovalCallback?(identifier)
    }

    /// Register projectile collision (hit block)
    func registerProjectileCollision(identifier: String) {
        activeProjectileIdentifiers.remove(identifier)
        projectileRemovalCallback?(identifier)
    }

    /// Get count of currently active projectiles
    var activeProjectileCount: Int {
        return activeProjectileIdentifiers.count
    }

    /// Clear all active projectiles
    func clearAllActiveProjectiles() {
        for identifier in activeProjectileIdentifiers {
            projectileRemovalCallback?(identifier)
        }
        activeProjectileIdentifiers.removeAll()
    }

    // MARK: - Cleanup

    deinit {
        spawnSchedulingTimer?.invalidate()
    }
}

// MARK: - Supporting Types

/// Spawning system configuration
struct SpawningConfiguration {
    let minimumSpawnInterval: TimeInterval
    let maximumSpawnInterval: TimeInterval
    let baseProjectileVelocity: CGFloat
    let projectileDimensions: CGSize

    static let defaultConfiguration = SpawningConfiguration(
        minimumSpawnInterval: 0.8,
        maximumSpawnInterval: 3.0,
        baseProjectileVelocity: 150,
        projectileDimensions: CGSize(width: 30, height: 30)
    )
}

/// Complete projectile spawn configuration
struct ProjectileSpawnConfiguration {
    let uniqueIdentifier: String
    let trajectoryDirection: ProjectileTrajectoryDirection
    let originPoint: CGPoint
    let terminusPoint: CGPoint
    let travelDurationSeconds: TimeInterval
    let projectileDimensions: CGSize
    let visualConfiguration: ProjectileVisualConfiguration
}

/// Projectile visual configuration
struct ProjectileVisualConfiguration {
    let primaryColor: UIColor
    let strokeColor: UIColor
    let strokeWidth: CGFloat
    let glowColor: UIColor
    let glowRadius: CGFloat
    let glowOpacity: Float

    static let defaultConfiguration = ProjectileVisualConfiguration(
        primaryColor: UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),
        strokeColor: .white,
        strokeWidth: 2.5,
        glowColor: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
        glowRadius: 10,
        glowOpacity: 0.9
    )
}

// MARK: - Difficulty Progression Manager

/// Manager handling difficulty progression and scaling
final class DifficultyProgressionManager {

    // MARK: - Properties

    /// Current progression level
    private(set) var currentLevelNumber: Int = 1

    /// Current difficulty factor (0.0 to 1.0+)
    private(set) var currentDifficultyFactor: CGFloat = 0.0

    /// Session configuration reference
    private let sessionConfiguration: GameSessionConfiguration

    /// Session start time
    private var sessionStartTime: Date?

    /// Time-based progression duration (seconds to reach maximum difficulty)
    private let progressionDurationSeconds: TimeInterval = 60.0

    // MARK: - Computed Properties

    /// Current spawn interval based on difficulty
    var currentSpawnInterval: TimeInterval {
        let maximumInterval: TimeInterval = 3.0
        let minimumInterval: TimeInterval = 0.8

        return maximumInterval - (maximumInterval - minimumInterval) * Double(currentDifficultyFactor)
    }

    /// Current velocity multiplier based on difficulty
    var velocityMultiplier: CGFloat {
        return 1.0 + (currentDifficultyFactor * 0.3)
    }

    // MARK: - Initialization

    init(configuration: GameSessionConfiguration) {
        self.sessionConfiguration = configuration
    }

    // MARK: - Progression Management

    /// Start progression tracking
    func startProgression() {
        sessionStartTime = Date()
        currentLevelNumber = 1
        currentDifficultyFactor = 0.0
    }

    /// Update progression based on elapsed time
    func updateProgression(elapsedTime: TimeInterval) {
        // Time-based difficulty scaling
        currentDifficultyFactor = CGFloat(min(elapsedTime / progressionDurationSeconds, 1.0))
    }

    /// Advance level based on score
    func advanceLevelForScore(_ score: Int) {
        let newLevel = (score / 10) + 1
        if newLevel > currentLevelNumber {
            currentLevelNumber = newLevel
        }
    }

    /// Reset progression to initial state
    func resetProgression() {
        sessionStartTime = nil
        currentLevelNumber = 1
        currentDifficultyFactor = 0.0
    }
}
