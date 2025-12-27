//
//  GameLogicController.swift
//  Beamway
//
//  Handles core game logic including tile management, projectile spawning,
//  collision detection, and scoring
//

import UIKit

/// Protocol for game logic controller delegate callbacks
protocol GameLogicControllerDelegate: AnyObject {
    func gameLogicControllerDidUpdateScore(_ score: Int)
    func gameLogicControllerDidUpdateLives(_ lives: Int)
    func gameLogicControllerDidUpdateLevel(_ level: Int)
    func gameLogicControllerDidUpdateCombo(_ combo: Int)
    func gameLogicControllerDidDetectCollision(at tile: DominoBlockPanel)
    func gameLogicControllerIsSessionActive() -> Bool
}

/// Controller managing core game logic
final class GameLogicController {

    // MARK: - Constants

    private struct GameConstants {
        static let blockDimension: CGFloat = 60
        static let dartDimension: CGFloat = 30
        static let dartVelocity: CGFloat = 150
        static let minimumLaunchFrequency: TimeInterval = 0.8
        static let maximumLaunchFrequency: TimeInterval = 3.0
        static let initialLives: Int = 3
        static let pointsPerLevel: Int = 10
    }

    // MARK: - Properties

    private let sessionCategory: SessionCategory
    private weak var playZonePanel: UIView?
    private weak var delegate: GameLogicControllerDelegate?

    // Game Elements
    private var dominoBlocks: [DominoBlockPanel] = []
    private var activeDarts: [DartMissilePanel] = []
    private var recordedImpacts: Set<String> = []

    // Timers
    private var sessionScheduler: Timer?
    private var dartLaunchScheduler: Timer?

    // Drag State
    private var blockDragPositions: [String: CGPoint] = [:]
    private var blocksManuallyPlaced: Set<String> = []

    // Game State
    private(set) var currentScore: Int = 0 {
        didSet {
            delegate?.gameLogicControllerDidUpdateScore(currentScore)
            evaluateStageAdvancement()
        }
    }

    private var remainingLives: Int = GameConstants.initialLives {
        didSet {
            delegate?.gameLogicControllerDidUpdateLives(remainingLives)
        }
    }

    private var currentLevel: Int = 1 {
        didSet {
            delegate?.gameLogicControllerDidUpdateLevel(currentLevel)
        }
    }

    private var activeCombo: Int = 0 {
        didSet {
            delegate?.gameLogicControllerDidUpdateCombo(activeCombo)
        }
    }

    private var peakCombo: Int = 0

    // Projectile Spawning
    private var sessionStartTime: Date?
    private var activeLaunchFrequency: TimeInterval = GameConstants.maximumLaunchFrequency

    // MARK: - Initialization

    init(sessionCategory: SessionCategory, playZonePanel: UIView, delegate: GameLogicControllerDelegate) {
        self.sessionCategory = sessionCategory
        self.playZonePanel = playZonePanel
        self.delegate = delegate
    }

    // MARK: - Game Lifecycle

    func prepareGame() {
        currentScore = 0
        remainingLives = GameConstants.initialLives
        currentLevel = 1
        activeCombo = 0
        peakCombo = 0
        sessionStartTime = nil
        activeLaunchFrequency = GameConstants.maximumLaunchFrequency

        if sessionCategory == .solo {
            generateSoloBlock()
        } else {
            refreshBlocksForStage()
        }
    }

    func startGame() {
        sessionStartTime = Date()
        activeLaunchFrequency = GameConstants.maximumLaunchFrequency

        sessionScheduler = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 60.0,
            repeats: true
        ) { [weak self] _ in
            self?.refreshSession()
        }

        launchDarts()
    }

    func pauseGame() {
        sessionScheduler?.invalidate()
        sessionScheduler = nil
        dartLaunchScheduler?.invalidate()
        dartLaunchScheduler = nil
    }

    func stopGame() {
        pauseGame()
    }

    func resetGame() {
        dominoBlocks.forEach { $0.removeFromSuperview() }
        activeDarts.forEach { $0.removeFromSuperview() }
        dominoBlocks.removeAll()
        activeDarts.removeAll()
        recordedImpacts.removeAll()
        blockDragPositions.removeAll()
        blocksManuallyPlaced.removeAll()

        currentScore = 0
        remainingLives = GameConstants.initialLives
        currentLevel = 1
        activeCombo = 0
        peakCombo = 0
    }

    // MARK: - Tile Management

    private func generateSoloBlock() {
        clearAllBlocks()

        let tile = generateDominoBlock()
        dominoBlocks.append(tile)
        playZonePanel?.addSubview(tile)

        centerTileInPlayZone(tile)
        tile.executeAppearanceMotion()
    }

    private func refreshBlocksForStage() {
        clearAllBlocks()

        let tileCount = sessionCategory == .competitive ? 2 : 1
        let spacing: CGFloat = 100

        guard let playZone = playZonePanel else { return }

        let startX = playZone.bounds.width / 2 - CGFloat(tileCount - 1) * spacing / 2

        for i in 0..<tileCount {
            let tile = generateDominoBlock()

            if playZone.bounds.width > 0 && playZone.bounds.height > 0 {
                let x = startX + CGFloat(i) * spacing
                let y = playZone.bounds.height / 2
                tile.center = CGPoint(x: x, y: y)
            }

            dominoBlocks.append(tile)
            playZone.addSubview(tile)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                tile.executeAppearanceMotion()
            }
        }
    }

    private func clearAllBlocks() {
        dominoBlocks.forEach { $0.removeFromSuperview() }
        dominoBlocks.removeAll()
        blocksManuallyPlaced.removeAll()
    }

    private func generateDominoBlock() -> DominoBlockPanel {
        let randomImageIndex = Int.random(in: 0...26)
        let imageName = "be \(randomImageIndex)"

        let tile = DominoBlockPanel(pictureName: imageName)
        let aspectRatio: CGFloat = 1.0 / 1.402
        tile.frame = CGRect(
            x: 0,
            y: 0,
            width: GameConstants.blockDimension,
            height: GameConstants.blockDimension / aspectRatio
        )

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(processDragMotion(_:)))
        tile.addGestureRecognizer(panGesture)
        tile.isUserInteractionEnabled = true

        return tile
    }

    private func centerTileInPlayZone(_ tile: DominoBlockPanel) {
        guard let playZone = playZonePanel,
              playZone.bounds.width > 0,
              playZone.bounds.height > 0 else { return }

        let centerX = playZone.bounds.width / 2
        let centerY = playZone.bounds.height / 2
        tile.center = CGPoint(x: centerX, y: centerY)
    }

    func updateTilePositionsIfNeeded() {
        guard let playZone = playZonePanel,
              !dominoBlocks.isEmpty,
              playZone.bounds.width > 0 else { return }

        let centerX = playZone.bounds.width / 2
        let centerY = playZone.bounds.height / 2

        if sessionCategory == .solo {
            if let tile = dominoBlocks.first,
               !blocksManuallyPlaced.contains(tile.blockUniqueId) {
                tile.center = CGPoint(x: centerX, y: centerY)
            }
        } else {
            updateMultipleTilePositions(centerX: centerX, centerY: centerY)
        }
    }

    private func updateMultipleTilePositions(centerX: CGFloat, centerY: CGFloat) {
        guard dominoBlocks.count == 2 else {
            if dominoBlocks.isEmpty {
                refreshBlocksForStage()
            }
            return
        }

        let spacing: CGFloat = 100
        let startX = centerX - spacing / 2

        if !blocksManuallyPlaced.contains(dominoBlocks[0].blockUniqueId) {
            dominoBlocks[0].center = CGPoint(x: startX, y: centerY)
        }
        if !blocksManuallyPlaced.contains(dominoBlocks[1].blockUniqueId) {
            dominoBlocks[1].center = CGPoint(x: startX + spacing, y: centerY)
        }
    }

    // MARK: - Drag Handling

    @objc private func processDragMotion(_ gesture: UIPanGestureRecognizer) {
        guard delegate?.gameLogicControllerIsSessionActive() == true,
              let tile = gesture.view as? DominoBlockPanel,
              let playZone = playZonePanel else { return }

        let translation = gesture.translation(in: playZone)
        let tileId = tile.blockUniqueId

        if gesture.state == .began {
            blockDragPositions[tileId] = tile.center
        }

        guard let lastPanLocation = blockDragPositions[tileId] else { return }

        var newCenter = CGPoint(
            x: lastPanLocation.x + translation.x,
            y: lastPanLocation.y + translation.y
        )

        let halfWidth = tile.bounds.width / 2
        let halfHeight = tile.bounds.height / 2

        newCenter.x = max(halfWidth, min(playZone.bounds.width - halfWidth, newCenter.x))
        newCenter.y = max(halfHeight, min(playZone.bounds.height - halfHeight, newCenter.y))

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tile.center = newCenter
        CATransaction.commit()

        if gesture.state == .ended || gesture.state == .cancelled {
            blockDragPositions[tileId] = newCenter
            blocksManuallyPlaced.insert(tileId)
        }
    }

    // MARK: - Projectile Management

    private func launchDarts() {
        dartLaunchScheduler?.invalidate()
        activeLaunchFrequency = GameConstants.maximumLaunchFrequency
        queueNextDart()
    }

    private func queueNextDart() {
        guard delegate?.gameLogicControllerIsSessionActive() == true else { return }

        adjustLaunchFrequency()

        dartLaunchScheduler = Timer.scheduledTimer(
            withTimeInterval: activeLaunchFrequency,
            repeats: false
        ) { [weak self] _ in
            guard let self = self,
                  self.delegate?.gameLogicControllerIsSessionActive() == true else { return }
            self.generateDart()
            self.queueNextDart()
        }
    }

    private func adjustLaunchFrequency() {
        guard let startTime = sessionStartTime else {
            activeLaunchFrequency = GameConstants.maximumLaunchFrequency
            return
        }

        let elapsedTime = Date().timeIntervalSince(startTime)
        let progress = min(elapsedTime / 60.0, 1.0)
        activeLaunchFrequency = GameConstants.maximumLaunchFrequency -
            (GameConstants.maximumLaunchFrequency - GameConstants.minimumLaunchFrequency) * progress
    }

    private func generateDart() {
        guard let playZone = playZonePanel else { return }

        let directions: [DartOrientation] = [.upper, .lower, .leftward, .rightward]
        let randomDirection = directions.randomElement() ?? .upper

        let arrow = DartMissilePanel(orientation: randomDirection)
        arrow.bounds = CGRect(
            x: 0,
            y: 0,
            width: GameConstants.dartDimension,
            height: GameConstants.dartDimension
        )

        let (startPoint, endPoint) = calculateDartPath(
            direction: randomDirection,
            playZoneBounds: playZone.bounds
        )

        playZone.addSubview(arrow)
        activeDarts.append(arrow)

        let distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
        let duration = TimeInterval(distance / GameConstants.dartVelocity)

        arrow.executeLaunchMotion(from: startPoint, to: endPoint, interval: duration) { [weak self] in
            self?.discardDart(arrow)
            self?.currentScore += 1
            self?.incrementCombo()
        }
    }

    private func calculateDartPath(direction: DartOrientation, playZoneBounds: CGRect) -> (CGPoint, CGPoint) {
        let dartDim = GameConstants.dartDimension

        switch direction {
        case .upper:
            let x = CGFloat.random(in: dartDim...playZoneBounds.width - dartDim)
            return (CGPoint(x: x, y: -dartDim), CGPoint(x: x, y: playZoneBounds.height + dartDim))

        case .lower:
            let x = CGFloat.random(in: dartDim...playZoneBounds.width - dartDim)
            return (CGPoint(x: x, y: playZoneBounds.height + dartDim), CGPoint(x: x, y: -dartDim))

        case .leftward:
            let y = CGFloat.random(in: dartDim...playZoneBounds.height - dartDim)
            return (CGPoint(x: -dartDim, y: y), CGPoint(x: playZoneBounds.width + dartDim, y: y))

        case .rightward:
            let y = CGFloat.random(in: dartDim...playZoneBounds.height - dartDim)
            return (CGPoint(x: playZoneBounds.width + dartDim, y: y), CGPoint(x: -dartDim, y: y))
        }
    }

    private func discardDart(_ arrow: DartMissilePanel) {
        arrow.removeFromSuperview()
        if let index = activeDarts.firstIndex(where: { $0.dartUniqueId == arrow.dartUniqueId }) {
            activeDarts.remove(at: index)
        }
    }

    // MARK: - Game Loop

    private func refreshSession() {
        guard delegate?.gameLogicControllerIsSessionActive() == true else { return }

        detectAndProcessCollisions()

        if sessionCategory == .competitive {
            evaluateStageAdvancement()
        }
    }

    private func detectAndProcessCollisions() {
        var collisions: [(DartMissilePanel, DominoBlockPanel)] = []

        for arrow in activeDarts {
            guard arrow.superview != nil else { continue }

            for tile in dominoBlocks {
                guard tile.superview != nil else { continue }

                let collisionKey = "\(arrow.dartUniqueId)-\(tile.blockUniqueId)"
                if recordedImpacts.contains(collisionKey) {
                    continue
                }

                if detectImpact(arrow: arrow, tile: tile) {
                    collisions.append((arrow, tile))
                    recordedImpacts.insert(collisionKey)
                }
            }
        }

        if let (arrow, tile) = collisions.first {
            processImpact(arrow: arrow, tile: tile)
        }
    }

    private func detectImpact(arrow: DartMissilePanel, tile: DominoBlockPanel) -> Bool {
        let arrowLayer = arrow.layer.presentation() ?? arrow.layer
        let arrowFrame = arrowLayer.frame
        let tileFrame = tile.layer.frame

        let padding: CGFloat = 5.0
        let expandedArrowFrame = arrowFrame.insetBy(dx: -padding, dy: -padding)
        let expandedTileFrame = tileFrame.insetBy(dx: -padding, dy: -padding)

        return expandedArrowFrame.intersects(expandedTileFrame)
    }

    private func processImpact(arrow: DartMissilePanel, tile: DominoBlockPanel) {
        let collisionKey = "\(arrow.dartUniqueId)-\(tile.blockUniqueId)"
        recordedImpacts.remove(collisionKey)

        arrow.removeFromSuperview()
        if let index = activeDarts.firstIndex(where: { $0.dartUniqueId == arrow.dartUniqueId }) {
            activeDarts.remove(at: index)
        }

        delegate?.gameLogicControllerDidDetectCollision(at: tile)

        resetCombo()
        remainingLives -= 1
    }

    // MARK: - Combo System

    private func incrementCombo() {
        activeCombo += 1
        if activeCombo > peakCombo {
            peakCombo = activeCombo
        }
    }

    private func resetCombo() {
        activeCombo = 0
    }

    // MARK: - Level Progression

    private func evaluateStageAdvancement() {
        let newLevel = (currentScore / GameConstants.pointsPerLevel) + 1
        if newLevel > currentLevel {
            currentLevel = newLevel
        }
    }
}
