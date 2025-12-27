//
//  CollisionDetectionEngine.swift
//  Beamway
//
//  Engine for detecting collisions between game elements
//

import UIKit

/// Event representing a detected collision
struct CollisionDetectionEvent {
    let projectileIdentifier: String
    let blockIdentifier: String
    let collisionPoint: CGPoint
    let timestamp: Date
}

/// Engine for collision detection between projectiles and tiles
final class CollisionDetectionEngine {

    // MARK: - Constants

    private struct CollisionConstants {
        static let defaultPadding: CGFloat = 5.0
        static let preciseCollisionPadding: CGFloat = 2.0
    }

    // MARK: - Types

    /// Result of collision detection
    struct CollisionResult {
        let projectile: DartMissilePanel
        let tile: DominoBlockPanel
        let collisionPoint: CGPoint
        let timestamp: Date
    }

    // MARK: - Properties

    private var recordedCollisions: Set<String> = []
    private let collisionPadding: CGFloat

    // MARK: - Initialization

    init(collisionPadding: CGFloat = CollisionConstants.defaultPadding) {
        self.collisionPadding = collisionPadding
    }

    // MARK: - Collision Detection

    /// Check for collisions between projectiles and tiles
    func detectCollisions(
        projectiles: [DartMissilePanel],
        tiles: [DominoBlockPanel]
    ) -> [CollisionResult] {
        var collisions: [CollisionResult] = []

        for projectile in projectiles {
            guard projectile.superview != nil else { continue }

            for tile in tiles {
                guard tile.superview != nil else { continue }

                let collisionKey = generateCollisionKey(projectile: projectile, tile: tile)

                if recordedCollisions.contains(collisionKey) {
                    continue
                }

                if checkCollision(between: projectile, and: tile) {
                    let collisionPoint = calculateCollisionPoint(projectile: projectile, tile: tile)

                    let result = CollisionResult(
                        projectile: projectile,
                        tile: tile,
                        collisionPoint: collisionPoint,
                        timestamp: Date()
                    )

                    collisions.append(result)
                    recordedCollisions.insert(collisionKey)
                }
            }
        }

        return collisions
    }

    /// Check if a single projectile collides with a tile
    func checkCollision(between projectile: DartMissilePanel, and tile: DominoBlockPanel) -> Bool {
        let projectileFrame = getAnimationFrame(for: projectile)
        let tileFrame = tile.layer.frame

        let expandedProjectileFrame = projectileFrame.insetBy(dx: -collisionPadding, dy: -collisionPadding)
        let expandedTileFrame = tileFrame.insetBy(dx: -collisionPadding, dy: -collisionPadding)

        return expandedProjectileFrame.intersects(expandedTileFrame)
    }

    /// Get the current animated frame of a view
    private func getAnimationFrame(for view: UIView) -> CGRect {
        let layer = view.layer.presentation() ?? view.layer
        return layer.frame
    }

    /// Calculate the point of collision
    private func calculateCollisionPoint(projectile: DartMissilePanel, tile: DominoBlockPanel) -> CGPoint {
        let projectileFrame = getAnimationFrame(for: projectile)
        let tileFrame = tile.layer.frame

        let intersectionRect = projectileFrame.intersection(tileFrame)

        return CGPoint(
            x: intersectionRect.midX,
            y: intersectionRect.midY
        )
    }

    // MARK: - Collision Key Management

    private func generateCollisionKey(projectile: DartMissilePanel, tile: DominoBlockPanel) -> String {
        return "\(projectile.dartUniqueId)-\(tile.blockUniqueId)"
    }

    /// Remove a collision from the recorded set
    func removeCollisionRecord(projectile: DartMissilePanel, tile: DominoBlockPanel) {
        let key = generateCollisionKey(projectile: projectile, tile: tile)
        recordedCollisions.remove(key)
    }

    /// Clear all collision records
    func clearAllRecords() {
        recordedCollisions.removeAll()
    }

    /// Check if a collision has been recorded
    func hasCollisionBeenRecorded(projectile: DartMissilePanel, tile: DominoBlockPanel) -> Bool {
        let key = generateCollisionKey(projectile: projectile, tile: tile)
        return recordedCollisions.contains(key)
    }
}

/// Advanced collision detection with shape-based algorithms
final class ShapeBasedCollisionDetector {

    // MARK: - Collision Types

    enum CollisionShape {
        case rectangle
        case circle
        case capsule
    }

    // MARK: - Properties

    private let projectileShape: CollisionShape
    private let tileShape: CollisionShape

    // MARK: - Initialization

    init(projectileShape: CollisionShape = .circle, tileShape: CollisionShape = .rectangle) {
        self.projectileShape = projectileShape
        self.tileShape = tileShape
    }

    // MARK: - Detection Methods

    /// Check collision using shape-based detection
    func checkCollision(
        projectileFrame: CGRect,
        tileFrame: CGRect
    ) -> Bool {
        switch (projectileShape, tileShape) {
        case (.circle, .rectangle):
            return circleRectangleCollision(
                circleCenter: CGPoint(x: projectileFrame.midX, y: projectileFrame.midY),
                circleRadius: projectileFrame.width / 2,
                rect: tileFrame
            )
        case (.rectangle, .rectangle):
            return projectileFrame.intersects(tileFrame)
        case (.circle, .circle):
            return circleCircleCollision(
                center1: CGPoint(x: projectileFrame.midX, y: projectileFrame.midY),
                radius1: projectileFrame.width / 2,
                center2: CGPoint(x: tileFrame.midX, y: tileFrame.midY),
                radius2: tileFrame.width / 2
            )
        default:
            return projectileFrame.intersects(tileFrame)
        }
    }

    /// Circle-rectangle collision detection
    private func circleRectangleCollision(
        circleCenter: CGPoint,
        circleRadius: CGFloat,
        rect: CGRect
    ) -> Bool {
        // Find the closest point on the rectangle to the circle center
        let closestX = max(rect.minX, min(circleCenter.x, rect.maxX))
        let closestY = max(rect.minY, min(circleCenter.y, rect.maxY))

        // Calculate distance between circle center and closest point
        let distanceX = circleCenter.x - closestX
        let distanceY = circleCenter.y - closestY
        let distanceSquared = distanceX * distanceX + distanceY * distanceY

        return distanceSquared < circleRadius * circleRadius
    }

    /// Circle-circle collision detection
    private func circleCircleCollision(
        center1: CGPoint,
        radius1: CGFloat,
        center2: CGPoint,
        radius2: CGFloat
    ) -> Bool {
        let distanceX = center2.x - center1.x
        let distanceY = center2.y - center1.y
        let distanceSquared = distanceX * distanceX + distanceY * distanceY
        let radiusSum = radius1 + radius2

        return distanceSquared < radiusSum * radiusSum
    }
}

/// Spatial partitioning for efficient collision detection
final class SpatialPartitioningGrid {

    // MARK: - Properties

    private let cellSize: CGFloat
    private var grid: [String: [AnyObject]] = [:]

    // MARK: - Initialization

    init(cellSize: CGFloat = 100) {
        self.cellSize = cellSize
    }

    // MARK: - Grid Management

    /// Get cell key for a position
    private func cellKey(for position: CGPoint) -> String {
        let cellX = Int(position.x / cellSize)
        let cellY = Int(position.y / cellSize)
        return "\(cellX),\(cellY)"
    }

    /// Add object to grid
    func addObject(_ object: AnyObject, at position: CGPoint) {
        let key = cellKey(for: position)
        if grid[key] == nil {
            grid[key] = []
        }
        grid[key]?.append(object)
    }

    /// Remove object from grid
    func removeObject(_ object: AnyObject, at position: CGPoint) {
        let key = cellKey(for: position)
        grid[key]?.removeAll { $0 === object }
    }

    /// Get objects in nearby cells
    func getNearbyObjects(for position: CGPoint) -> [AnyObject] {
        var objects: [AnyObject] = []

        let cellX = Int(position.x / cellSize)
        let cellY = Int(position.y / cellSize)

        // Check current cell and adjacent cells
        for dx in -1...1 {
            for dy in -1...1 {
                let key = "\(cellX + dx),\(cellY + dy)"
                if let cellObjects = grid[key] {
                    objects.append(contentsOf: cellObjects)
                }
            }
        }

        return objects
    }

    /// Clear grid
    func clear() {
        grid.removeAll()
    }

    /// Update object position
    func updateObject(_ object: AnyObject, from oldPosition: CGPoint, to newPosition: CGPoint) {
        removeObject(object, at: oldPosition)
        addObject(object, at: newPosition)
    }
}
