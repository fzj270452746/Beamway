//
//  BlockEntityController.swift
//  Beamway
//
//  Block entity management and interaction handling
//

import UIKit

/// Controller managing block entity lifecycle, interactions, and rendering
/// Handles creation, positioning, drag interactions, and animations for block tiles
final class BlockEntityController {

    // MARK: - Type Definitions

    /// Block creation callback
    typealias BlockCreationCallback = (InteractiveBlockEntity) -> Void

    /// Block position update callback
    typealias BlockPositionUpdateCallback = (String, CGPoint) -> Void

    /// Block entity configuration
    struct BlockEntityConfiguration {
        let baseDimension: CGFloat
        let aspectRatio: CGFloat
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let shadowRadius: CGFloat
        let shadowOpacity: Float

        static let standard = BlockEntityConfiguration(
            baseDimension: 60,
            aspectRatio: 1.0 / 1.402,
            cornerRadius: 4.5,
            borderWidth: 2.0,
            shadowRadius: 4.0,
            shadowOpacity: 0.3
        )
    }

    // MARK: - Properties

    /// Active block entities managed by this controller
    private(set) var activeBlockEntities: [InteractiveBlockEntity] = []

    /// Container view for block entities
    private weak var blockContainerView: UIView?

    /// Movement containment bounds
    private var movementContainmentBounds: CGRect = .zero

    /// Block configuration
    private let blockConfiguration: BlockEntityConfiguration

    /// Drag position tracking dictionary
    private var dragPositionTracking: [String: CGPoint] = [:]

    /// Manually positioned block identifiers
    private var manuallyPositionedBlockIds: Set<String> = []

    /// Block creation callback
    var blockCreationCallback: BlockCreationCallback?

    /// Block position update callback
    var blockPositionUpdateCallback: BlockPositionUpdateCallback?

    /// Visual theme reference
    private let visualTheme: VisualThemeConfiguration

    /// Available tile image count
    private let availableTileImageCount: Int = 27

    // MARK: - Initialization

    init(configuration: BlockEntityConfiguration = .standard) {
        self.blockConfiguration = configuration
        self.visualTheme = VisualThemeConfiguration.shared
    }

    // MARK: - Configuration

    /// Configure controller with container view and bounds
    func configureController(containerView: UIView, containmentBounds: CGRect) {
        self.blockContainerView = containerView
        self.movementContainmentBounds = containmentBounds
    }

    /// Update containment bounds
    func updateContainmentBounds(_ newBounds: CGRect) {
        movementContainmentBounds = newBounds
    }

    // MARK: - Block Entity Creation

    /// Create single block entity for solo mode
    func createSingleBlockEntity() -> InteractiveBlockEntity {
        clearAllBlockEntities()

        let blockEntity = generateNewBlockEntity()
        activeBlockEntities.append(blockEntity)

        if let container = blockContainerView {
            container.addSubview(blockEntity.visualRepresentation)

            // Position at center
            let centerPosition = CGPoint(
                x: movementContainmentBounds.width / 2,
                y: movementContainmentBounds.height / 2
            )
            blockEntity.visualRepresentation.center = centerPosition
        }

        blockEntity.executeEntranceAnimation()
        blockCreationCallback?(blockEntity)

        return blockEntity
    }

    /// Create multiple block entities for challenge mode
    func createMultipleBlockEntities(count: Int) -> [InteractiveBlockEntity] {
        clearAllBlockEntities()

        var createdEntities: [InteractiveBlockEntity] = []
        let horizontalSpacing: CGFloat = 100
        let startXPosition = movementContainmentBounds.width / 2 - CGFloat(count - 1) * horizontalSpacing / 2
        let centerYPosition = movementContainmentBounds.height / 2

        for entityIndex in 0..<count {
            let blockEntity = generateNewBlockEntity()
            createdEntities.append(blockEntity)
            activeBlockEntities.append(blockEntity)

            if let container = blockContainerView {
                container.addSubview(blockEntity.visualRepresentation)

                let xPosition = startXPosition + CGFloat(entityIndex) * horizontalSpacing
                blockEntity.visualRepresentation.center = CGPoint(x: xPosition, y: centerYPosition)
            }

            // Staggered entrance animation
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(entityIndex) * 0.1) {
                blockEntity.executeEntranceAnimation()
            }

            blockCreationCallback?(blockEntity)
        }

        return createdEntities
    }

    /// Generate new block entity with random tile image
    private func generateNewBlockEntity() -> InteractiveBlockEntity {
        let randomImageIndex = Int.random(in: 0..<availableTileImageCount)
        let imageName = "be \(randomImageIndex)"

        let entityIdentifier = UUID().uuidString
        let calculatedHeight = blockConfiguration.baseDimension / blockConfiguration.aspectRatio

        let visualView = TileBlockVisualView(
            pictureName: imageName,
            uniqueIdentifier: entityIdentifier,
            configuration: blockConfiguration
        )

        visualView.frame = CGRect(
            x: 0,
            y: 0,
            width: blockConfiguration.baseDimension,
            height: calculatedHeight
        )

        // Configure drag gesture
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleBlockDragGesture(_:))
        )
        visualView.addGestureRecognizer(panGestureRecognizer)
        visualView.isUserInteractionEnabled = true

        return InteractiveBlockEntity(
            identifier: entityIdentifier,
            visualRepresentation: visualView,
            containmentBounds: movementContainmentBounds
        )
    }

    // MARK: - Block Entity Management

    /// Clear all active block entities
    func clearAllBlockEntities() {
        for entity in activeBlockEntities {
            entity.visualRepresentation.removeFromSuperview()
        }
        activeBlockEntities.removeAll()
        dragPositionTracking.removeAll()
        manuallyPositionedBlockIds.removeAll()
    }

    /// Get block entity by identifier
    func getBlockEntity(byIdentifier identifier: String) -> InteractiveBlockEntity? {
        return activeBlockEntities.first { $0.identifier == identifier }
    }

    /// Check if block was manually positioned
    func isBlockManuallyPositioned(_ identifier: String) -> Bool {
        return manuallyPositionedBlockIds.contains(identifier)
    }

    /// Reset block to default position
    func resetBlockToDefaultPosition(_ identifier: String) {
        guard let entity = getBlockEntity(byIdentifier: identifier) else { return }

        let centerPosition = CGPoint(
            x: movementContainmentBounds.width / 2,
            y: movementContainmentBounds.height / 2
        )

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            entity.visualRepresentation.center = centerPosition
        }

        manuallyPositionedBlockIds.remove(identifier)
        dragPositionTracking.removeValue(forKey: identifier)
    }

    // MARK: - Drag Gesture Handling

    /// Handle block drag gesture
    @objc private func handleBlockDragGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let blockView = gestureRecognizer.view as? TileBlockVisualView else { return }
        let blockIdentifier = blockView.blockUniqueIdentifier

        guard let blockEntity = getBlockEntity(byIdentifier: blockIdentifier) else { return }

        let translationOffset = gestureRecognizer.translation(in: blockContainerView)

        switch gestureRecognizer.state {
        case .began:
            dragPositionTracking[blockIdentifier] = blockView.center
            blockEntity.beginDragInteraction()

        case .changed:
            guard let initialDragPosition = dragPositionTracking[blockIdentifier] else { return }

            var proposedCenter = CGPoint(
                x: initialDragPosition.x + translationOffset.x,
                y: initialDragPosition.y + translationOffset.y
            )

            // Constrain within bounds
            proposedCenter = constrainPositionWithinBounds(
                proposedCenter,
                viewSize: blockView.bounds.size
            )

            // Apply position without animation for smooth dragging
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            blockView.center = proposedCenter
            CATransaction.commit()

            blockPositionUpdateCallback?(blockIdentifier, proposedCenter)

        case .ended, .cancelled:
            let finalPosition = blockView.center
            dragPositionTracking[blockIdentifier] = finalPosition
            manuallyPositionedBlockIds.insert(blockIdentifier)
            blockEntity.endDragInteraction()

        default:
            break
        }
    }

    /// Constrain position within containment bounds
    private func constrainPositionWithinBounds(_ proposedPosition: CGPoint, viewSize: CGSize) -> CGPoint {
        let halfWidth = viewSize.width / 2
        let halfHeight = viewSize.height / 2

        let constrainedX = max(halfWidth, min(movementContainmentBounds.width - halfWidth, proposedPosition.x))
        let constrainedY = max(halfHeight, min(movementContainmentBounds.height - halfHeight, proposedPosition.y))

        return CGPoint(x: constrainedX, y: constrainedY)
    }

    // MARK: - Block Collision References

    /// Get collision references for all active blocks
    func getCollisionReferencesForAllBlocks() -> [InteractiveBlockEntityReference] {
        return activeBlockEntities.map { entity in
            InteractiveBlockEntityReference.createFromView(
                entity.visualRepresentation,
                identifier: entity.identifier
            )
        }
    }

    // MARK: - Block Visual Effects

    /// Execute shake effect on block
    func executeShakeEffectOnBlock(_ identifier: String) {
        guard let entity = getBlockEntity(byIdentifier: identifier) else { return }
        entity.executeImpactShakeEffect()
    }

    /// Execute flash effect on block
    func executeFlashEffectOnBlock(_ identifier: String) {
        guard let entity = getBlockEntity(byIdentifier: identifier) else { return }
        entity.executeImpactFlashEffect()
    }
}

// MARK: - Interactive Block Entity

/// Represents an interactive block entity in the game
final class InteractiveBlockEntity {

    // MARK: - Properties

    /// Unique entity identifier
    let identifier: String

    /// Visual view representation
    let visualRepresentation: TileBlockVisualView

    /// Movement containment bounds
    var containmentBounds: CGRect

    /// Whether entity is currently being dragged
    private(set) var isDragging: Bool = false

    /// Whether entity is active in game
    var isActiveInGame: Bool = true

    // MARK: - Initialization

    init(identifier: String, visualRepresentation: TileBlockVisualView, containmentBounds: CGRect) {
        self.identifier = identifier
        self.visualRepresentation = visualRepresentation
        self.containmentBounds = containmentBounds
    }

    // MARK: - Interaction Handling

    /// Begin drag interaction
    func beginDragInteraction() {
        isDragging = true
        TouchFeedbackController.shared.generateTileDragStartFeedback()
    }

    /// End drag interaction
    func endDragInteraction() {
        isDragging = false
        TouchFeedbackController.shared.generateTileDragEndFeedback()
    }

    // MARK: - Animation Methods

    /// Execute entrance animation
    func executeEntranceAnimation() {
        visualRepresentation.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        visualRepresentation.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.visualRepresentation.transform = .identity
            self.visualRepresentation.alpha = 1.0
        }
    }

    /// Execute impact shake effect
    func executeImpactShakeEffect() {
        let horizontalShake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        horizontalShake.timingFunction = CAMediaTimingFunction(name: .linear)
        horizontalShake.duration = 0.5
        horizontalShake.values = [-10, 10, -10, 10, -5, 5, -5, 5, 0]

        let verticalShake = CAKeyframeAnimation(keyPath: "transform.translation.y")
        verticalShake.timingFunction = CAMediaTimingFunction(name: .linear)
        verticalShake.duration = 0.5
        verticalShake.values = [-5, 5, -5, 5, -3, 3, -3, 3, 0]

        visualRepresentation.layer.add(horizontalShake, forKey: "horizontalShake")
        visualRepresentation.layer.add(verticalShake, forKey: "verticalShake")
    }

    /// Execute impact flash effect
    func executeImpactFlashEffect() {
        UIView.animate(withDuration: 0.1, animations: {
            self.visualRepresentation.alpha = 0.5
            self.visualRepresentation.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.visualRepresentation.alpha = 1.0
                self.visualRepresentation.transform = .identity
            }
        }
    }

    // MARK: - Collision Bounds

    /// Get current collision bounds
    var currentCollisionBounds: CGRect {
        if let presentationLayer = visualRepresentation.layer.presentation() {
            return presentationLayer.frame
        }
        return visualRepresentation.frame
    }
}

// MARK: - Tile Block Visual View

/// Visual view component for block tiles
final class TileBlockVisualView: UIView {

    // MARK: - Properties

    /// Block unique identifier
    let blockUniqueIdentifier: String

    /// Tile image view
    private let tileImageView: UIImageView

    /// Current tile image name
    private var currentTileImageName: String

    /// Block configuration
    private let blockConfiguration: BlockEntityController.BlockEntityConfiguration

    // MARK: - Initialization

    init(pictureName: String, uniqueIdentifier: String, configuration: BlockEntityController.BlockEntityConfiguration) {
        self.blockUniqueIdentifier = uniqueIdentifier
        self.currentTileImageName = pictureName
        self.blockConfiguration = configuration
        self.tileImageView = UIImageView()

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

        // Configure tile image
        if let tileImage = UIImage(named: currentTileImageName) {
            tileImageView.image = tileImage
        } else {
            tileImageView.image = UIImage(named: "be 0")
        }
        tileImageView.contentMode = .scaleToFill
        tileImageView.clipsToBounds = true
        addSubview(tileImageView)

        tileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tileImageView.topAnchor.constraint(equalTo: topAnchor),
            tileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tileImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Apply styling
        layer.cornerRadius = blockConfiguration.cornerRadius
        layer.borderWidth = blockConfiguration.borderWidth
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        clipsToBounds = true

        // Apply shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = blockConfiguration.shadowRadius
        layer.shadowOpacity = blockConfiguration.shadowOpacity
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: blockConfiguration.cornerRadius
        ).cgPath
    }

    // MARK: - Image Update

    /// Update tile image
    func updateTileImage(pictureName: String) {
        currentTileImageName = pictureName
        if let newImage = UIImage(named: pictureName) {
            tileImageView.image = newImage
        }
    }
}
