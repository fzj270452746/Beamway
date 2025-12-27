//
//  CollisionProcessingEngine.swift
//  Beamway
//
//  Collision detection and processing system
//

import UIKit

/// High-performance collision detection and processing engine
/// Manages collision checks between game entities with spatial optimization
final class CollisionProcessingEngine {

    // MARK: - Type Definitions

    /// Collision detection callback
    typealias CollisionDetectionCallback = (DetectedCollisionInfo) -> Void

    // MARK: - Properties

    /// Registered interactive block entities
    private var registeredBlockEntities: [InteractiveBlockEntityReference] = []

    /// Registered projectile entities
    private var registeredProjectileEntities: [ProjectileEntityReference] = []

    /// Set of processed collision identifiers to prevent duplicates
    private var processedCollisionIdentifiers: Set<String> = []

    /// Collision detection callback
    var collisionDetectionCallback: CollisionDetectionCallback?

    /// Alias for collisionDetectionCallback (compatibility with GameSessionCoordinator)
    var collisionEventCallback: ((CollisionDetectionEvent) -> Void)? {
        get { return nil }
        set {
            if let handler = newValue {
                collisionDetectionCallback = { collisionInfo in
                    let event = CollisionDetectionEvent(
                        projectileIdentifier: collisionInfo.projectileEntityIdentifier,
                        blockIdentifier: collisionInfo.blockEntityIdentifier,
                        collisionPoint: collisionInfo.collisionCenterPoint,
                        timestamp: collisionInfo.collisionTimestamp
                    )
                    handler(event)
                }
            } else {
                collisionDetectionCallback = nil
            }
        }
    }

    /// Collision boundary padding for more forgiving detection
    private let collisionBoundaryPadding: CGFloat = 5.0

    /// Frame collision limit to prevent performance issues
    private let maximumCollisionsPerFrame: Int = 3

    // MARK: - Entity Registration

    /// Register block entity for collision detection
    func registerBlockEntity(_ entityReference: InteractiveBlockEntityReference) {
        guard !registeredBlockEntities.contains(where: { $0.entityIdentifier == entityReference.entityIdentifier }) else {
            return
        }
        registeredBlockEntities.append(entityReference)
    }

    /// Register projectile entity for collision detection
    func registerProjectileEntity(_ entityReference: ProjectileEntityReference) {
        guard !registeredProjectileEntities.contains(where: { $0.entityIdentifier == entityReference.entityIdentifier }) else {
            return
        }
        registeredProjectileEntities.append(entityReference)
    }

    /// Unregister block entity from collision detection
    func unregisterBlockEntity(identifier: String) {
        registeredBlockEntities.removeAll { $0.entityIdentifier == identifier }
        clearCollisionRecordsForEntity(identifier: identifier)
    }

    /// Unregister projectile entity from collision detection
    func unregisterProjectileEntity(identifier: String) {
        registeredProjectileEntities.removeAll { $0.entityIdentifier == identifier }
        clearCollisionRecordsForEntity(identifier: identifier)
    }

    /// Clear all registered entities
    func clearAllRegisteredEntities() {
        registeredBlockEntities.removeAll()
        registeredProjectileEntities.removeAll()
        processedCollisionIdentifiers.removeAll()
    }

    // MARK: - Collision Detection

    /// Process collision detection for current frame
    func processCollisionDetection() {
        var detectedCollisions: [DetectedCollisionInfo] = []

        for projectileRef in registeredProjectileEntities {
            guard projectileRef.isEntityActive else { continue }

            for blockRef in registeredBlockEntities {
                guard blockRef.isEntityActive else { continue }

                let collisionKey = generateCollisionKey(
                    projectileId: projectileRef.entityIdentifier,
                    blockId: blockRef.entityIdentifier
                )

                if processedCollisionIdentifiers.contains(collisionKey) {
                    continue
                }

                if performBoundsIntersectionCheck(projectileRef: projectileRef, blockRef: blockRef) {
                    let collisionInfo = DetectedCollisionInfo(
                        projectileEntityIdentifier: projectileRef.entityIdentifier,
                        blockEntityIdentifier: blockRef.entityIdentifier,
                        collisionTimestamp: Date(),
                        projectileBounds: projectileRef.currentBounds,
                        blockBounds: blockRef.currentBounds
                    )
                    detectedCollisions.append(collisionInfo)
                    processedCollisionIdentifiers.insert(collisionKey)

                    if detectedCollisions.count >= maximumCollisionsPerFrame {
                        break
                    }
                }
            }

            if detectedCollisions.count >= maximumCollisionsPerFrame {
                break
            }
        }

        // Report detected collisions
        for collision in detectedCollisions {
            collisionDetectionCallback?(collision)
        }
    }

    /// Perform bounds intersection check between projectile and block
    private func performBoundsIntersectionCheck(projectileRef: ProjectileEntityReference,
                                                 blockRef: InteractiveBlockEntityReference) -> Bool {
        let projectileBounds = projectileRef.currentBounds.insetBy(
            dx: -collisionBoundaryPadding,
            dy: -collisionBoundaryPadding
        )

        let blockBounds = blockRef.currentBounds.insetBy(
            dx: -collisionBoundaryPadding,
            dy: -collisionBoundaryPadding
        )

        return projectileBounds.intersects(blockBounds)
    }

    /// Generate unique collision key for deduplication
    private func generateCollisionKey(projectileId: String, blockId: String) -> String {
        return "\(projectileId)_\(blockId)"
    }

    /// Clear collision records for specific entity
    private func clearCollisionRecordsForEntity(identifier: String) {
        processedCollisionIdentifiers = processedCollisionIdentifiers.filter { key in
            !key.contains(identifier)
        }
    }

    /// Reset processed collision tracking
    func resetProcessedCollisionTracking() {
        processedCollisionIdentifiers.removeAll()
    }

    /// Reset all collision state (compatibility alias)
    func resetAllCollisionState() {
        clearAllRegisteredEntities()
        resetProcessedCollisionTracking()
    }

    // MARK: - Advanced Collision Utilities

    /// Calculate precise collision point between entities
    func calculatePreciseCollisionPoint(projectileBounds: CGRect, blockBounds: CGRect) -> CGPoint {
        let intersection = projectileBounds.intersection(blockBounds)

        if intersection.isNull {
            return CGPoint(
                x: (projectileBounds.midX + blockBounds.midX) / 2,
                y: (projectileBounds.midY + blockBounds.midY) / 2
            )
        }

        return CGPoint(x: intersection.midX, y: intersection.midY)
    }

    /// Calculate impact direction vector
    func calculateImpactDirectionVector(from projectileCenter: CGPoint, to blockCenter: CGPoint) -> CGVector {
        let deltaX = blockCenter.x - projectileCenter.x
        let deltaY = blockCenter.y - projectileCenter.y
        let magnitude = sqrt(deltaX * deltaX + deltaY * deltaY)

        guard magnitude > 0 else {
            return CGVector(dx: 0, dy: 1)
        }

        return CGVector(dx: deltaX / magnitude, dy: deltaY / magnitude)
    }
}

// MARK: - Entity Reference Types

/// Reference structure for interactive block entities
struct InteractiveBlockEntityReference {
    let entityIdentifier: String
    var isEntityActive: Bool
    var currentBounds: CGRect

    /// Create reference from view
    static func createFromView(_ view: UIView, identifier: String) -> InteractiveBlockEntityReference {
        let presentationBounds: CGRect
        if let presentationLayer = view.layer.presentation() {
            presentationBounds = presentationLayer.frame
        } else {
            presentationBounds = view.frame
        }

        return InteractiveBlockEntityReference(
            entityIdentifier: identifier,
            isEntityActive: !view.isHidden && view.superview != nil,
            currentBounds: presentationBounds
        )
    }
}

/// Reference structure for projectile entities
struct ProjectileEntityReference {
    let entityIdentifier: String
    var isEntityActive: Bool
    var currentBounds: CGRect
    let trajectoryDirection: ProjectileTrajectoryDirection

    /// Create reference from view
    static func createFromView(_ view: UIView,
                               identifier: String,
                               direction: ProjectileTrajectoryDirection) -> ProjectileEntityReference {
        let presentationBounds: CGRect
        if let presentationLayer = view.layer.presentation() {
            presentationBounds = presentationLayer.frame
        } else {
            presentationBounds = view.frame
        }

        return ProjectileEntityReference(
            entityIdentifier: identifier,
            isEntityActive: !view.isHidden && view.superview != nil,
            currentBounds: presentationBounds,
            trajectoryDirection: direction
        )
    }
}

/// Detected collision information structure
struct DetectedCollisionInfo {
    let projectileEntityIdentifier: String
    let blockEntityIdentifier: String
    let collisionTimestamp: Date
    let projectileBounds: CGRect
    let blockBounds: CGRect

    /// Calculate collision center point
    var collisionCenterPoint: CGPoint {
        let intersection = projectileBounds.intersection(blockBounds)
        if intersection.isNull {
            return CGPoint(
                x: (projectileBounds.midX + blockBounds.midX) / 2,
                y: (projectileBounds.midY + blockBounds.midY) / 2
            )
        }
        return CGPoint(x: intersection.midX, y: intersection.midY)
    }

    /// Generate unique collision key
    var uniqueCollisionKey: String {
        return "\(projectileEntityIdentifier)_\(blockEntityIdentifier)"
    }
}

// MARK: - Collision Response Handler

/// Handler for processing collision responses
final class CollisionResponseHandler {

    // MARK: - Properties

    /// Response callback type
    typealias CollisionResponseCallback = (CollisionResponseAction) -> Void

    /// Response callback
    var responseCallback: CollisionResponseCallback?

    // MARK: - Response Processing

    /// Process collision and determine response action
    func processCollisionResponse(collisionInfo: DetectedCollisionInfo) -> CollisionResponseAction {
        return CollisionResponseAction(
            shouldRemoveProjectile: true,
            shouldApplyDamage: true,
            shouldTriggerVisualEffect: true,
            shouldTriggerHapticFeedback: true,
            collisionInfo: collisionInfo
        )
    }

    /// Execute collision response action
    func executeCollisionResponse(_ action: CollisionResponseAction) {
        responseCallback?(action)
    }
}

/// Collision response action structure
struct CollisionResponseAction {
    let shouldRemoveProjectile: Bool
    let shouldApplyDamage: Bool
    let shouldTriggerVisualEffect: Bool
    let shouldTriggerHapticFeedback: Bool
    let collisionInfo: DetectedCollisionInfo
}

// MARK: - Spatial Partitioning (Advanced Optimization)

/// Spatial partitioning grid for optimized collision detection (Service layer version)
final class ServiceSpatialPartitioningGrid {

    // MARK: - Properties

    /// Grid cell dimensions
    private let cellDimension: CGFloat

    /// Grid bounds
    private let gridBounds: CGRect

    /// Grid cells containing entity references
    private var gridCells: [[Set<String>]]

    /// Entity to cell mapping
    private var entityCellMapping: [String: [(Int, Int)]] = [:]

    // MARK: - Initialization

    init(bounds: CGRect, cellDimension: CGFloat = 100) {
        self.gridBounds = bounds
        self.cellDimension = cellDimension

        let columnsCount = Int(ceil(bounds.width / cellDimension))
        let rowsCount = Int(ceil(bounds.height / cellDimension))

        gridCells = Array(repeating: Array(repeating: Set<String>(), count: columnsCount), count: rowsCount)
    }

    // MARK: - Entity Management

    /// Insert entity into grid
    func insertEntity(identifier: String, bounds: CGRect) {
        let cells = calculateOccupiedCells(for: bounds)

        for (row, column) in cells {
            gridCells[row][column].insert(identifier)
        }

        entityCellMapping[identifier] = cells
    }

    /// Update entity position in grid
    func updateEntityPosition(identifier: String, newBounds: CGRect) {
        removeEntity(identifier: identifier)
        insertEntity(identifier: identifier, bounds: newBounds)
    }

    /// Remove entity from grid
    func removeEntity(identifier: String) {
        guard let cells = entityCellMapping[identifier] else { return }

        for (row, column) in cells {
            gridCells[row][column].remove(identifier)
        }

        entityCellMapping.removeValue(forKey: identifier)
    }

    /// Get potential collision candidates for entity
    func getPotentialCollisionCandidates(for bounds: CGRect) -> Set<String> {
        var candidates: Set<String> = []

        let cells = calculateOccupiedCells(for: bounds)
        for (row, column) in cells {
            candidates.formUnion(gridCells[row][column])
        }

        return candidates
    }

    // MARK: - Cell Calculation

    /// Calculate grid cells occupied by bounds
    private func calculateOccupiedCells(for bounds: CGRect) -> [(Int, Int)] {
        let minColumn = max(0, Int(floor((bounds.minX - gridBounds.minX) / cellDimension)))
        let maxColumn = min(gridCells[0].count - 1, Int(floor((bounds.maxX - gridBounds.minX) / cellDimension)))
        let minRow = max(0, Int(floor((bounds.minY - gridBounds.minY) / cellDimension)))
        let maxRow = min(gridCells.count - 1, Int(floor((bounds.maxY - gridBounds.minY) / cellDimension)))

        var cells: [(Int, Int)] = []
        for row in minRow...maxRow {
            for column in minColumn...maxColumn {
                cells.append((row, column))
            }
        }

        return cells
    }

    /// Clear all entities from grid
    func clearGrid() {
        for row in 0..<gridCells.count {
            for column in 0..<gridCells[row].count {
                gridCells[row][column].removeAll()
            }
        }
        entityCellMapping.removeAll()
    }
}
