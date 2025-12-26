//
//  MainGameViewController.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

enum GameModeType {
    case single
    case challenge
}

class MainGameViewController: UIViewController {
    
    // MARK: - Properties
    
    private let gameMode: GameModeType
    private let backgroundImageView: UIImageView
    private let overlayView: UIView
    private let gameAreaView: UIView
    private let topInfoContainerView: UIView
    private let scoreLabel: UILabel
    private let livesLabel: UILabel
    private let levelLabel: UILabel
    private var livesIconViews: [UIImageView] = []
    private let backButton: CustomBackButton
    private let pauseButton: UIButton
    
    private var mahjongTiles: [MahjongTileView] = []
    private var activeArrows: [ArrowProjectileView] = []
    private var gameTimer: Timer?
    private var arrowSpawnTimer: Timer?
    private var processedCollisions: Set<String> = []
    
    private var currentScore: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(currentScore)"
        }
    }
    
    private var currentLives: Int = 3 {
        didSet {
            livesLabel.text = "Lives: \(currentLives)"
            // Ensure lives doesn't go below 0
            if currentLives < 0 {
                currentLives = 0
            }
            // Update life icons display
            updateLivesIcons()
            if currentLives <= 0 {
                endGame()
            }
        }
    }
    
    private var currentLevel: Int = 1 {
        didSet {
            levelLabel.text = "Level: \(currentLevel)"
            // In challenge mode, tiles count is fixed at 2, so no need to recreate tiles on level change
            // updateTilesForLevel() is only called during initialization
        }
    }
    
    private var isGamePaused: Bool = false
    private var isGameOver: Bool = false
    private var hasInitializedGame = false
    
    private let tileSize: CGFloat = 60
    private let arrowSize: CGFloat = 30
    private let arrowSpeed: CGFloat = 150  // Reduced speed for slower arrows
    private var tilePanLocations: [String: CGPoint] = [:]  // Store pan location for each tile
    private var tilesManuallyPositioned: Set<String> = []  // Track tiles that have been manually moved by user
    
    // Arrow spawning progression
    private var gameStartTime: Date?
    private var currentSpawnInterval: TimeInterval = 3.0  // Start with longer interval (fewer arrows)
    private let minSpawnInterval: TimeInterval = 0.8  // Minimum interval (max arrows per second)
    private let maxSpawnInterval: TimeInterval = 3.0  // Maximum interval (min arrows per second)
    
    // MARK: - Initialization
    
    init(gameMode: GameModeType) {
        self.gameMode = gameMode
        backgroundImageView = UIImageView()
        overlayView = UIView()
        gameAreaView = UIView()
        topInfoContainerView = UIView()
        scoreLabel = UILabel()
        livesLabel = UILabel()
        levelLabel = UILabel()
        backButton = CustomBackButton()
        pauseButton = UIButton(type: .system)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameInterface()
        // Don't initialize game here, wait for layout to complete
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start game only if already initialized
        if hasInitializedGame {
            startGame()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGame()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup Interface
    
    private func setupGameInterface() {
        view.backgroundColor = .black
        
        // Setup background image
        if let backgroundImage = UIImage(named: "benImage") {
            backgroundImageView.image = backgroundImage
        } else {
            backgroundImageView.backgroundColor = .darkGray
        }
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup overlay with reduced opacity to better show background
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup game area
        gameAreaView.backgroundColor = .clear
        gameAreaView.clipsToBounds = true
        view.addSubview(gameAreaView)
        gameAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adjust spacing to account for top info container
        let topSpacing: CGFloat = 70
        let spacing: CGFloat = 20
        NSLayoutConstraint.activate([
            gameAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topSpacing),
            gameAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            gameAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            gameAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing)
        ])
        
        // Setup UI labels
        setupUILabels()
        
        // Setup buttons
        setupButtons()
    }
    
    private func setupUILabels() {
        // Setup container view for labels
        topInfoContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topInfoContainerView.layer.cornerRadius = 12
        topInfoContainerView.layer.borderWidth = 1.5
        topInfoContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        topInfoContainerView.clipsToBounds = true
        view.addSubview(topInfoContainerView)
        topInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Score label
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        scoreLabel.backgroundColor = .clear
        scoreLabel.textAlignment = .center
        scoreLabel.layer.cornerRadius = 8
        scoreLabel.clipsToBounds = true
        
        // Setup Lives label
        livesLabel.text = "Lives: 3"
        livesLabel.textColor = .white
        livesLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        livesLabel.backgroundColor = .clear
        livesLabel.textAlignment = .center
        livesLabel.layer.cornerRadius = 8
        livesLabel.clipsToBounds = true
        
        // Setup Lives icons - three heart symbols
        setupLivesIcons()
        
        // Setup Level label (only for challenge mode)
        levelLabel.text = "Level: 1"
        levelLabel.textColor = .white
        levelLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        levelLabel.backgroundColor = .clear
        levelLabel.textAlignment = .center
        levelLabel.layer.cornerRadius = 8
        levelLabel.clipsToBounds = true
        
        // Create horizontal stack view for labels
        var labelArray: [UILabel] = []
        if gameMode == .challenge {
            labelArray = [levelLabel, scoreLabel, livesLabel]
        } else {
            labelArray = [scoreLabel, livesLabel]
        }
        
        let labelsStackView = UIStackView(arrangedSubviews: labelArray)
        labelsStackView.axis = .horizontal
        labelsStackView.distribution = .fillEqually
        labelsStackView.spacing = 12
        labelsStackView.alignment = .fill
        
        topInfoContainerView.addSubview(labelsStackView)
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout container view
        NSLayoutConstraint.activate([
            topInfoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            topInfoContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topInfoContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            topInfoContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            labelsStackView.topAnchor.constraint(equalTo: topInfoContainerView.topAnchor, constant: 5),
            labelsStackView.leadingAnchor.constraint(equalTo: topInfoContainerView.leadingAnchor, constant: 12),
            labelsStackView.trailingAnchor.constraint(equalTo: topInfoContainerView.trailingAnchor, constant: -12),
            labelsStackView.bottomAnchor.constraint(equalTo: topInfoContainerView.bottomAnchor, constant: -5)
        ])
    }
    
    private func setupLivesIcons() {
        // Create three life icons
        let iconSize: CGFloat = 30
        let spacing: CGFloat = 8
        let startX: CGFloat = 20
        
        for i in 0..<3 {
            let iconView = UIImageView()
            iconView.image = UIImage(systemName: "heart.fill")
            iconView.tintColor = .systemRed
            iconView.contentMode = .scaleAspectFit
            iconView.tag = i // Use tag to identify each icon
            view.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: topInfoContainerView.bottomAnchor, constant: 10),
                iconView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: startX + CGFloat(i) * (iconSize + spacing)),
                iconView.widthAnchor.constraint(equalToConstant: iconSize),
                iconView.heightAnchor.constraint(equalToConstant: iconSize)
            ])
            
            livesIconViews.append(iconView)
        }
        
    }
    
    private func updateLivesIcons() {
        // Show/hide icons based on current lives
        for (index, iconView) in livesIconViews.enumerated() {
            if index < currentLives {
                iconView.isHidden = false
                iconView.alpha = 1.0
            } else {
                // Animate the icon disappearing
                UIView.animate(withDuration: 0.3, animations: {
                    iconView.alpha = 0.0
                    iconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }) { _ in
                    iconView.isHidden = true
                    iconView.transform = .identity
                }
            }
        }
    }
    
    private func setupButtons() {
        // Back button
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Pause button with improved style
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitle("Resume", for: .selected)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        pauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        pauseButton.layer.cornerRadius = 22
        pauseButton.layer.borderWidth = 1.5
        pauseButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        view.addSubview(pauseButton)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pauseButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            pauseButton.widthAnchor.constraint(equalToConstant: 100),
            pauseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Game Logic
    
    private func initializeGame() {
        currentScore = 0
        currentLives = 3
        currentLevel = 1
        gameStartTime = nil
        currentSpawnInterval = maxSpawnInterval
        
        if gameMode == .single {
            createSingleTile()
        } else {
            updateTilesForLevel()
        }
    }
    
    private func createSingleTile() {
        // Ensure only one tile exists in single mode
        mahjongTiles.forEach { $0.removeFromSuperview() }
        mahjongTiles.removeAll()
        tilesManuallyPositioned.removeAll()  // Reset manual positioning flags
        
        let tile = createMahjongTile()
        // Position will be set in viewDidLayoutSubviews when bounds are valid
        mahjongTiles.append(tile)
        gameAreaView.addSubview(tile)
        
        // Set position if bounds are already valid
        if gameAreaView.bounds.width > 0 && gameAreaView.bounds.height > 0 {
            let centerX = gameAreaView.bounds.width / 2
            let centerY = gameAreaView.bounds.height / 2
            tile.center = CGPoint(x: centerX, y: centerY)
        }
        
        tile.animateTileAppearance()
    }
    
    private func updateTilesForLevel() {
        // Remove existing tiles
        mahjongTiles.forEach { $0.removeFromSuperview() }
        mahjongTiles.removeAll()
        tilesManuallyPositioned.removeAll()  // Reset manual positioning flags
        
        // Challenge mode: always create 2 tiles
        // Single mode: 1 tile
        let tileCount = gameMode == .challenge ? 2 : 1
        
        let spacing: CGFloat = 100
        let startX = gameAreaView.bounds.width / 2 - CGFloat(tileCount - 1) * spacing / 2
        
        for i in 0..<tileCount {
            let tile = createMahjongTile()
            // Position will be set properly if bounds are valid
            if gameAreaView.bounds.width > 0 && gameAreaView.bounds.height > 0 {
                let x = startX + CGFloat(i) * spacing
                let y = gameAreaView.bounds.height / 2
                tile.center = CGPoint(x: x, y: y)
            }
            mahjongTiles.append(tile)
            gameAreaView.addSubview(tile)
            
            // Stagger animation
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                tile.animateTileAppearance()
            }
        }
    }
    
    private func createMahjongTile() -> MahjongTileView {
        let randomImageIndex = Int.random(in: 0...26)
        let imageName = "be \(randomImageIndex)"
        
        let tile = MahjongTileView(imageName: imageName)
        let aspectRatio: CGFloat = 1.0 / 1.402
        tile.frame = CGRect(x: 0, y: 0, width: tileSize, height: tileSize / aspectRatio)
        
        // Add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        tile.addGestureRecognizer(panGesture)
        tile.isUserInteractionEnabled = true
        
        return tile
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard !isGamePaused && !isGameOver, let tile = gesture.view as? MahjongTileView else { return }
        
        let translation = gesture.translation(in: gameAreaView)
        let tileId = tile.tileIdentifier
        
        // Get or initialize the starting location for this specific tile
        if gesture.state == .began {
            tilePanLocations[tileId] = tile.center
        }
        
        // Get the starting location for this tile
        guard let lastPanLocation = tilePanLocations[tileId] else { return }
        
        var newCenter = CGPoint(
            x: lastPanLocation.x + translation.x,
            y: lastPanLocation.y + translation.y
        )
        
        // Constrain to game area
        let halfWidth = tile.bounds.width / 2
        let halfHeight = tile.bounds.height / 2
        
        newCenter.x = max(halfWidth, min(gameAreaView.bounds.width - halfWidth, newCenter.x))
        newCenter.y = max(halfHeight, min(gameAreaView.bounds.height - halfHeight, newCenter.y))
        
        // Disable animation during dragging to prevent ghosting
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tile.center = newCenter
        CATransaction.commit()
        
        if gesture.state == .ended || gesture.state == .cancelled {
            tilePanLocations[tileId] = newCenter
            // Mark this tile as manually positioned by user
            tilesManuallyPositioned.insert(tileId)
        }
    }
    
    private func startGame() {
        isGamePaused = false
        isGameOver = false
        gameStartTime = Date()
        currentSpawnInterval = maxSpawnInterval  // Reset to initial slow spawn rate
        
        // Start game timer for collision detection and spawn rate updates
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        // Start arrow spawning with progressive difficulty
        spawnArrows()
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        arrowSpawnTimer?.invalidate()
        arrowSpawnTimer = nil
    }
    
    private func spawnArrows() {
        // Cancel existing timer if any
        arrowSpawnTimer?.invalidate()
        
        // Start with slower spawn rate
        currentSpawnInterval = maxSpawnInterval
        scheduleNextArrow()
    }
    
    private func scheduleNextArrow() {
        guard !isGamePaused && !isGameOver else { return }
        
        // Calculate new spawn interval based on game time
        updateSpawnInterval()
        
        // Schedule next arrow
        arrowSpawnTimer = Timer.scheduledTimer(withTimeInterval: currentSpawnInterval, repeats: false) { [weak self] _ in
            guard let self = self, !self.isGamePaused && !self.isGameOver else { return }
            self.createArrow()
            // Schedule next arrow
            self.scheduleNextArrow()
        }
    }
    
    private func updateSpawnInterval() {
        guard let startTime = gameStartTime else {
            currentSpawnInterval = maxSpawnInterval
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        // Gradually decrease spawn interval (increase arrow frequency) over 60 seconds
        // After 60 seconds, reach minimum spawn interval
        let progress = min(elapsedTime / 60.0, 1.0)  // Progress from 0 to 1 over 60 seconds
        currentSpawnInterval = maxSpawnInterval - (maxSpawnInterval - minSpawnInterval) * progress
        
    }
    
    private func createArrow() {
        let directions: [ArrowDirection] = [.top, .bottom, .left, .right]
        let randomDirection = directions.randomElement() ?? .top
        
        let arrow = ArrowProjectileView(direction: randomDirection)
        // Set bounds first, then frame will be set by center in animateArrowLaunch
        arrow.bounds = CGRect(x: 0, y: 0, width: arrowSize, height: arrowSize)
        
        let startPoint: CGPoint
        let endPoint: CGPoint
        
        switch randomDirection {
        case .top:
            startPoint = CGPoint(x: CGFloat.random(in: arrowSize...gameAreaView.bounds.width - arrowSize), y: -arrowSize)
            endPoint = CGPoint(x: startPoint.x, y: gameAreaView.bounds.height + arrowSize)
        case .bottom:
            startPoint = CGPoint(x: CGFloat.random(in: arrowSize...gameAreaView.bounds.width - arrowSize), y: gameAreaView.bounds.height + arrowSize)
            endPoint = CGPoint(x: startPoint.x, y: -arrowSize)
        case .left:
            startPoint = CGPoint(x: -arrowSize, y: CGFloat.random(in: arrowSize...gameAreaView.bounds.height - arrowSize))
            endPoint = CGPoint(x: gameAreaView.bounds.width + arrowSize, y: startPoint.y)
        case .right:
            startPoint = CGPoint(x: gameAreaView.bounds.width + arrowSize, y: CGFloat.random(in: arrowSize...gameAreaView.bounds.height - arrowSize))
            endPoint = CGPoint(x: -arrowSize, y: startPoint.y)
        }
        
        gameAreaView.addSubview(arrow)
        activeArrows.append(arrow)
        
        let distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
        let duration = TimeInterval(distance / arrowSpeed)
        
        arrow.animateArrowLaunch(from: startPoint, to: endPoint, duration: duration) { [weak self] in
            self?.removeArrow(arrow)
            self?.currentScore += 1
        }
    }
    
    private func removeArrow(_ arrow: ArrowProjectileView) {
        arrow.removeFromSuperview()
        if let index = activeArrows.firstIndex(where: { $0.arrowIdentifier == arrow.arrowIdentifier }) {
            activeArrows.remove(at: index)
        }
    }
    
    private func updateGame() {
        guard !isGamePaused && !isGameOver else { return }
        
        // Check collisions - collect all collisions first to avoid concurrent modification
        var collisions: [(ArrowProjectileView, MahjongTileView)] = []
        for arrow in activeArrows {
            // Skip if arrow is not in view hierarchy
            guard arrow.superview != nil else { continue }
            
            for tile in mahjongTiles {
                // Skip if tile is not in view hierarchy
                guard tile.superview != nil else { continue }
                
                let collisionKey = "\(arrow.arrowIdentifier)-\(tile.tileIdentifier)"
                // Skip if already processed
                if processedCollisions.contains(collisionKey) {
                    continue
                }
                
                if checkCollision(arrow: arrow, tile: tile) {
                    collisions.append((arrow, tile))
                    // Mark as processed to prevent duplicate handling
                    processedCollisions.insert(collisionKey)
                }
            }
        }
        
        // Handle collisions (process first collision only per frame to avoid rapid life loss)
        if let (arrow, tile) = collisions.first {
            handleCollision(arrow: arrow, tile: tile)
        }
        
        // Check level progression for challenge mode
        if gameMode == .challenge {
            checkLevelProgression()
        }
    }
    
    private func checkCollision(arrow: ArrowProjectileView, tile: MahjongTileView) -> Bool {
        // Use presentation layer for arrow (it's animating)
        let arrowLayer = arrow.layer.presentation() ?? arrow.layer
        let arrowFrame = arrowLayer.frame
        
        // For tile, use actual layer frame (not presentation) since dragging disables animation
        // This ensures we get the real current position, not a cached presentation position
        let tileFrame = tile.layer.frame
        
        // Add some padding for more forgiving collision detection
        let padding: CGFloat = 5.0
        let expandedArrowFrame = arrowFrame.insetBy(dx: -padding, dy: -padding)
        let expandedTileFrame = tileFrame.insetBy(dx: -padding, dy: -padding)
        
        let isColliding = expandedArrowFrame.intersects(expandedTileFrame)
        
        if isColliding {
            
        }
        
        return isColliding
    }
    
    private func handleCollision(arrow: ArrowProjectileView, tile: MahjongTileView) {
        // Remove collision from processed set since we're handling it now
        let collisionKey = "\(arrow.arrowIdentifier)-\(tile.tileIdentifier)"
        processedCollisions.remove(collisionKey)
        
        
        // Remove arrow immediately to prevent multiple collisions
        arrow.removeFromSuperview()
        if let index = activeArrows.firstIndex(where: { $0.arrowIdentifier == arrow.arrowIdentifier }) {
            activeArrows.remove(at: index)
        }
        
        // Add shake animation to tile - this should be visible
        tile.animateShake()
        
        // Also add a visual feedback with color flash
        UIView.animate(withDuration: 0.1, animations: {
            tile.alpha = 0.5
            tile.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                tile.alpha = 1.0
                tile.transform = .identity
            }
        }
        
        // Show life lost message
        showLifeLostMessage()
        
        // Animate lives icon before losing life
        animateLivesIcon()
        
        // Lose life
        currentLives -= 1
    }
    
    private func showLifeLostMessage() {
        let messageLabel = UILabel()
        messageLabel.text = "Life -1"
        messageLabel.textColor = .systemRed
        messageLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        messageLabel.textAlignment = .center
        messageLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        messageLabel.layer.cornerRadius = 8
        messageLabel.clipsToBounds = true
        messageLabel.layer.borderWidth = 2
        messageLabel.layer.borderColor = UIColor.systemRed.cgColor
        
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: 150),
            messageLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        messageLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            messageLabel.alpha = 1.0
            messageLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
                messageLabel.alpha = 0
                messageLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                messageLabel.removeFromSuperview()
            }
        }
    }
    
    private func animateLivesIcon() {
        // Animate the next icon that will be lost (the one at currentLives index)
        if currentLives > 0 && currentLives <= livesIconViews.count {
            let iconToAnimate = livesIconViews[currentLives - 1]
            UIView.animate(withDuration: 0.2, animations: {
                iconToAnimate.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                iconToAnimate.tintColor = .systemRed
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    iconToAnimate.transform = .identity
                }
            }
        }
    }
    
    private func checkLevelProgression() {
        // Progress to next level every 10 points
        let newLevel = (currentScore / 10) + 1
        if newLevel > currentLevel {
            currentLevel = newLevel
        }
    }
    
    private func endGame() {
        isGameOver = true
        stopGame()
        
        // Calculate game time
        let gameTime: TimeInterval
        if let startTime = gameStartTime {
            gameTime = Date().timeIntervalSince(startTime)
        } else {
            gameTime = 0
        }
        
        // Save game record with time
        let modeString = gameMode == .single ? "Single Mode" : "Challenge Mode"
        GameRecordManager.sharedInstance.saveGameRecord(score: currentScore, mode: modeString)
        
        // Save longest time record
        if gameTime > 0 {
            GameRecordManager.sharedInstance.saveLongestTimeRecord(time: gameTime, mode: modeString)
        }
        
        
        // Show game over alert
        let alert = UIAlertController(
            title: "Game Over",
            message: "Your score: \(currentScore)\nMode: \(modeString)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        
        alert.addAction(UIAlertAction(title: "Back to Menu", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func restartGame() {
        // Remove all tiles and arrows
        mahjongTiles.forEach { $0.removeFromSuperview() }
        activeArrows.forEach { $0.removeFromSuperview() }
        mahjongTiles.removeAll()
        activeArrows.removeAll()
        processedCollisions.removeAll()
        
        // Reset game
        hasInitializedGame = false
        if gameAreaView.bounds.width > 0 && gameAreaView.bounds.height > 0 {
            hasInitializedGame = true
            initializeGame()
            startGame()
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonTapped() {
        let alert = UIAlertController(
            title: "Exit Game",
            message: "Are you sure you want to exit? Your current progress will be saved.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            if let self = self, self.currentScore > 0 {
                let modeString = self.gameMode == .single ? "Single Mode" : "Challenge Mode"
                GameRecordManager.sharedInstance.saveGameRecord(score: self.currentScore, mode: modeString)
                
                // Save time record if game was played
                if let startTime = self.gameStartTime {
                    let gameTime = Date().timeIntervalSince(startTime)
                    GameRecordManager.sharedInstance.saveLongestTimeRecord(time: gameTime, mode: modeString)
                }
            }
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func pauseButtonTapped() {
        isGamePaused.toggle()
        pauseButton.isSelected = isGamePaused
        
        if isGamePaused {
            gameTimer?.invalidate()
            arrowSpawnTimer?.invalidate()
        } else {
            startGame()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Initialize game when layout is complete and bounds are valid
        if !hasInitializedGame && gameAreaView.bounds.width > 0 && gameAreaView.bounds.height > 0 {
            hasInitializedGame = true
            initializeGame()
            // Start game after initialization
            if view.window != nil {
                startGame()
            }
        }
        
        // Update tile positions if needed
        if !mahjongTiles.isEmpty && gameAreaView.bounds.width > 0 {
            let centerX = gameAreaView.bounds.width / 2
            let centerY = gameAreaView.bounds.height / 2
            
            if gameMode == .single {
                if let tile = mahjongTiles.first {
                    // Only update position if tile hasn't been manually moved by user
                    if !tilesManuallyPositioned.contains(tile.tileIdentifier) {
                        tile.center = CGPoint(x: centerX, y: centerY)
                    }
                }
            } else {
                // Challenge mode: update positions for 2 tiles
                if mahjongTiles.count == 2 && gameAreaView.bounds.width > 0 {
                    let spacing: CGFloat = 100
                    let startX = gameAreaView.bounds.width / 2 - spacing / 2
                    let centerY = gameAreaView.bounds.height / 2
                    
                    // Only update positions for tiles that haven't been manually moved
                    if !tilesManuallyPositioned.contains(mahjongTiles[0].tileIdentifier) {
                        mahjongTiles[0].center = CGPoint(x: startX, y: centerY)
                    }
                    if !tilesManuallyPositioned.contains(mahjongTiles[1].tileIdentifier) {
                        mahjongTiles[1].center = CGPoint(x: startX + spacing, y: centerY)
                    }
                } else if mahjongTiles.isEmpty {
                    // If no tiles exist, create them
                    updateTilesForLevel()
                }
            }
        }
    }
}

