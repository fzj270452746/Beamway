//
//  ProjectileEntityController.swift
//  Beamway
//
//  Projectile entity management and trajectory handling
//

import UIKit

/// Controller managing projectile entity lifecycle, trajectories, and rendering
/// Handles creation, movement animation, and cleanup for arrow projectiles
final class ProjectileEntityController {

    // MARK: - Type Definitions

    /// Projectile spawn callback
    typealias ProjectileSpawnCallback = (ActiveProjectileEntity) -> Void

    /// Projectile removal callback
    typealias ProjectileRemovalCallback = (String) -> Void

    /// Projectile dodge callback (successfully passed through)
    typealias ProjectileDodgeCallback = (String) -> Void

    /// Projectile entity configuration
    struct ProjectileEntityConfiguration {
        let baseDimension: CGFloat
        let baseVelocity: CGFloat
        let fadeInDuration: TimeInterval
        let glowRadius: CGFloat
        let glowOpacity: Float

        static let standard = ProjectileEntityConfiguration(
            baseDimension: 30,
            baseVelocity: 150,
            fadeInDuration: 0.2,
            glowRadius: 10,
            glowOpacity: 0.9
        )
    }

    // MARK: - Properties

    /// Active projectile entities managed by this controller
    private(set) var activeProjectileEntities: [ActiveProjectileEntity] = []

    /// Container view for projectile entities
    private weak var projectileContainerView: UIView?

    /// Play zone bounds for trajectory calculation
    private var playZoneBounds: CGRect = .zero

    /// Projectile configuration
    private let projectileConfiguration: ProjectileEntityConfiguration

    /// Current velocity multiplier based on difficulty
    private var velocityMultiplier: CGFloat = 1.0

    /// Projectile spawn callback
    var projectileSpawnCallback: ProjectileSpawnCallback?

    /// Projectile removal callback
    var projectileRemovalCallback: ProjectileRemovalCallback?

    /// Projectile dodge callback
    var projectileDodgeCallback: ProjectileDodgeCallback?

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    // MARK: - Initialization

    init(configuration: ProjectileEntityConfiguration = .standard) {
        self.projectileConfiguration = configuration
        self.visualTheme = VisualThemeConfiguration.shared
    }

    // MARK: - Configuration

    /// Configure controller with container view and bounds
    func configureController(containerView: UIView, playBounds: CGRect) {
        self.projectileContainerView = containerView
        self.playZoneBounds = playBounds
    }

    /// Update play zone bounds
    func updatePlayZoneBounds(_ newBounds: CGRect) {
        playZoneBounds = newBounds
    }

    /// Update velocity multiplier for difficulty scaling
    func updateVelocityMultiplier(_ multiplier: CGFloat) {
        velocityMultiplier = max(1.0, multiplier)
    }

    // MARK: - Projectile Creation

    /// Spawn new projectile with random direction
    func spawnRandomDirectionProjectile() -> ActiveProjectileEntity {
        let randomDirection = ProjectileMovementDirection.selectRandomDirection()
        return spawnProjectile(direction: randomDirection)
    }

    /// Spawn new projectile with specific direction
    func spawnProjectile(direction: ProjectileMovementDirection) -> ActiveProjectileEntity {
        let trajectoryPoints = calculateTrajectoryPoints(for: direction)

        let entityIdentifier = UUID().uuidString

        let visualView = ArrowProjectileVisualView(
            movementDirection: direction,
            uniqueIdentifier: entityIdentifier,
            configuration: projectileConfiguration
        )

        visualView.bounds = CGRect(
            x: 0,
            y: 0,
            width: projectileConfiguration.baseDimension,
            height: projectileConfiguration.baseDimension
        )

        let projectileEntity = ActiveProjectileEntity(
            identifier: entityIdentifier,
            visualRepresentation: visualView,
            movementDirection: direction,
            originPoint: trajectoryPoints.origin,
            terminusPoint: trajectoryPoints.terminus
        )

        activeProjectileEntities.append(projectileEntity)

        if let container = projectileContainerView {
            container.addSubview(visualView)
        }

        // Calculate travel duration and launch
        let travelDuration = calculateTravelDuration(
            from: trajectoryPoints.origin,
            to: trajectoryPoints.terminus
        )

        launchProjectileAlongTrajectory(
            entity: projectileEntity,
            duration: travelDuration
        )

        projectileSpawnCallback?(projectileEntity)

        return projectileEntity
    }

    /// Calculate trajectory points for direction
    private func calculateTrajectoryPoints(for direction: ProjectileMovementDirection) -> (origin: CGPoint, terminus: CGPoint) {
        let dimension = projectileConfiguration.baseDimension
        let padding = dimension

        switch direction {
        case .descendingFromTop:
            let xPosition = CGFloat.random(in: padding...(playZoneBounds.width - padding))
            return (
                CGPoint(x: xPosition, y: -dimension),
                CGPoint(x: xPosition, y: playZoneBounds.height + dimension)
            )

        case .ascendingFromBottom:
            let xPosition = CGFloat.random(in: padding...(playZoneBounds.width - padding))
            return (
                CGPoint(x: xPosition, y: playZoneBounds.height + dimension),
                CGPoint(x: xPosition, y: -dimension)
            )

        case .advancingFromLeft:
            let yPosition = CGFloat.random(in: padding...(playZoneBounds.height - padding))
            return (
                CGPoint(x: -dimension, y: yPosition),
                CGPoint(x: playZoneBounds.width + dimension, y: yPosition)
            )

        case .advancingFromRight:
            let yPosition = CGFloat.random(in: padding...(playZoneBounds.height - padding))
            return (
                CGPoint(x: playZoneBounds.width + dimension, y: yPosition),
                CGPoint(x: -dimension, y: yPosition)
            )
        }
    }

    /// Calculate travel duration based on distance and velocity
    private func calculateTravelDuration(from origin: CGPoint, to terminus: CGPoint) -> TimeInterval {
        let deltaX = terminus.x - origin.x
        let deltaY = terminus.y - origin.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)

        let adjustedVelocity = projectileConfiguration.baseVelocity * velocityMultiplier

        return TimeInterval(distance / adjustedVelocity)
    }

    /// Launch projectile along trajectory
    private func launchProjectileAlongTrajectory(entity: ActiveProjectileEntity, duration: TimeInterval) {
        let visualView = entity.visualRepresentation

        visualView.center = entity.originPoint
        visualView.alpha = 0

        // Fade in
        UIView.animate(withDuration: projectileConfiguration.fadeInDuration) {
            visualView.alpha = 1.0
        } completion: { _ in
            // Launch animation
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .curveLinear
            ) {
                visualView.center = entity.terminusPoint
            } completion: { [weak self] finished in
                if finished {
                    // Projectile dodged successfully
                    self?.handleProjectileDodged(entity)
                }
            }
        }
    }

    // MARK: - Projectile Removal

    /// Handle projectile dodged (reached terminus without collision)
    private func handleProjectileDodged(_ entity: ActiveProjectileEntity) {
        projectileDodgeCallback?(entity.identifier)
        removeProjectileEntity(identifier: entity.identifier)
    }

    /// Remove projectile entity by identifier
    func removeProjectileEntity(identifier: String) {
        guard let entityIndex = activeProjectileEntities.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }

        let entity = activeProjectileEntities[entityIndex]
        entity.visualRepresentation.removeFromSuperview()
        activeProjectileEntities.remove(at: entityIndex)

        projectileRemovalCallback?(identifier)
    }

    /// Remove all active projectile entities
    func clearAllProjectileEntities() {
        for entity in activeProjectileEntities {
            entity.visualRepresentation.removeFromSuperview()
        }
        activeProjectileEntities.removeAll()
    }

    // MARK: - Collision References

    /// Get collision references for all active projectiles
    func getCollisionReferencesForAllProjectiles() -> [ProjectileEntityReference] {
        return activeProjectileEntities.map { entity in
            ProjectileEntityReference(
                entityIdentifier: entity.identifier,
                isEntityActive: true,
                currentBounds: entity.currentCollisionBounds,
                trajectoryDirection: entity.movementDirection.toTrajectoryDirection()
            )
        }
    }

    // MARK: - Accessors

    /// Get projectile entity by identifier
    func getProjectileEntity(byIdentifier identifier: String) -> ActiveProjectileEntity? {
        return activeProjectileEntities.first { $0.identifier == identifier }
    }

    /// Get count of active projectiles
    var activeProjectileCount: Int {
        return activeProjectileEntities.count
    }
}

// MARK: - Projectile Movement Direction

/// Enumeration defining projectile movement directions
enum ProjectileMovementDirection: CaseIterable {
    case descendingFromTop
    case ascendingFromBottom
    case advancingFromLeft
    case advancingFromRight

    /// Select random direction
    static func selectRandomDirection() -> ProjectileMovementDirection {
        return allCases.randomElement() ?? .descendingFromTop
    }

    /// Convert to trajectory direction for collision system
    func toTrajectoryDirection() -> ProjectileTrajectoryDirection {
        switch self {
        case .descendingFromTop:
            return .descendingFromTop
        case .ascendingFromBottom:
            return .ascendingFromBottom
        case .advancingFromLeft:
            return .advancingFromLeft
        case .advancingFromRight:
            return .advancingFromRight
        }
    }

    /// Convert to legacy dart orientation
    func toDartOrientation() -> DartOrientation {
        switch self {
        case .descendingFromTop:
            return .upper
        case .ascendingFromBottom:
            return .lower
        case .advancingFromLeft:
            return .leftward
        case .advancingFromRight:
            return .rightward
        }
    }
}

// MARK: - Active Projectile Entity

/// Represents an active projectile entity in the game
final class ActiveProjectileEntity {

    // MARK: - Properties

    /// Unique entity identifier
    let identifier: String

    /// Visual view representation
    let visualRepresentation: ArrowProjectileVisualView

    /// Movement direction
    let movementDirection: ProjectileMovementDirection

    /// Trajectory origin point
    let originPoint: CGPoint

    /// Trajectory terminus point
    let terminusPoint: CGPoint

    /// Whether entity is active
    var isActiveInGame: Bool = true

    // MARK: - Initialization

    init(identifier: String,
         visualRepresentation: ArrowProjectileVisualView,
         movementDirection: ProjectileMovementDirection,
         originPoint: CGPoint,
         terminusPoint: CGPoint) {
        self.identifier = identifier
        self.visualRepresentation = visualRepresentation
        self.movementDirection = movementDirection
        self.originPoint = originPoint
        self.terminusPoint = terminusPoint
    }

    // MARK: - Collision Bounds

    /// Get current collision bounds (from presentation layer for animation accuracy)
    var currentCollisionBounds: CGRect {
        if let presentationLayer = visualRepresentation.layer.presentation() {
            return presentationLayer.frame
        }
        return visualRepresentation.frame
    }
}

// MARK: - Arrow Projectile Visual View

/// Visual view component for arrow projectiles
final class ArrowProjectileVisualView: UIView {

    // MARK: - Properties

    /// Projectile unique identifier
    let projectileUniqueIdentifier: String

    /// Movement direction
    let movementDirection: ProjectileMovementDirection

    /// Arrow shape layer
    private let arrowShapeLayer: CAShapeLayer

    /// Projectile configuration
    private let projectileConfiguration: ProjectileEntityController.ProjectileEntityConfiguration

    // MARK: - Initialization

    init(movementDirection: ProjectileMovementDirection,
         uniqueIdentifier: String,
         configuration: ProjectileEntityController.ProjectileEntityConfiguration) {
        self.movementDirection = movementDirection
        self.projectileUniqueIdentifier = uniqueIdentifier
        self.projectileConfiguration = configuration
        self.arrowShapeLayer = CAShapeLayer()

        super.init(frame: .zero)

        configureVisualAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configure visual appearance
    private func configureVisualAppearance() {
        backgroundColor = .clear

        // Configure arrow shape
        arrowShapeLayer.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        arrowShapeLayer.strokeColor = UIColor.white.cgColor
        arrowShapeLayer.lineWidth = 2.5
        layer.addSublayer(arrowShapeLayer)

        // Apply glow effect
        layer.shadowColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        layer.shadowRadius = projectileConfiguration.glowRadius
        layer.shadowOpacity = projectileConfiguration.glowOpacity
        layer.shadowOffset = .zero
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        arrowShapeLayer.path = generateArrowPath().cgPath
        arrowShapeLayer.frame = bounds
    }

    /// Generate arrow bezier path based on direction
    private func generateArrowPath() -> UIBezierPath {
        let pathBuilder = UIBezierPath()
        let pathWidth = bounds.width > 0 ? bounds.width : projectileConfiguration.baseDimension
        let pathHeight = bounds.height > 0 ? bounds.height : projectileConfiguration.baseDimension

        switch movementDirection {
        case .descendingFromTop:
            // Arrow pointing downward (tip at bottom)
            pathBuilder.move(to: CGPoint(x: pathWidth / 2, y: pathHeight))
            pathBuilder.addLine(to: CGPoint(x: 0, y: pathHeight * 0.7))
            pathBuilder.addLine(to: CGPoint(x: pathWidth / 4, y: pathHeight * 0.7))
            pathBuilder.addLine(to: CGPoint(x: pathWidth / 4, y: 0))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 3 / 4, y: 0))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 3 / 4, y: pathHeight * 0.7))
            pathBuilder.addLine(to: CGPoint(x: pathWidth, y: pathHeight * 0.7))
            pathBuilder.close()

        case .ascendingFromBottom:
            // Arrow pointing upward (tip at top)
            pathBuilder.move(to: CGPoint(x: pathWidth / 2, y: 0))
            pathBuilder.addLine(to: CGPoint(x: 0, y: pathHeight * 0.3))
            pathBuilder.addLine(to: CGPoint(x: pathWidth / 4, y: pathHeight * 0.3))
            pathBuilder.addLine(to: CGPoint(x: pathWidth / 4, y: pathHeight))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 3 / 4, y: pathHeight))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 3 / 4, y: pathHeight * 0.3))
            pathBuilder.addLine(to: CGPoint(x: pathWidth, y: pathHeight * 0.3))
            pathBuilder.close()

        case .advancingFromLeft:
            // Arrow pointing rightward (tip at right)
            pathBuilder.move(to: CGPoint(x: pathWidth, y: pathHeight / 2))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.3, y: 0))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.3, y: pathHeight / 4))
            pathBuilder.addLine(to: CGPoint(x: 0, y: pathHeight / 4))
            pathBuilder.addLine(to: CGPoint(x: 0, y: pathHeight * 3 / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.3, y: pathHeight * 3 / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.3, y: pathHeight))
            pathBuilder.close()

        case .advancingFromRight:
            // Arrow pointing leftward (tip at left)
            pathBuilder.move(to: CGPoint(x: 0, y: pathHeight / 2))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.7, y: 0))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.7, y: pathHeight / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth, y: pathHeight / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth, y: pathHeight * 3 / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.7, y: pathHeight * 3 / 4))
            pathBuilder.addLine(to: CGPoint(x: pathWidth * 0.7, y: pathHeight))
            pathBuilder.close()
        }

        return pathBuilder
    }
}
