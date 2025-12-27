//
//  PlaySessionController.swift
//  Beamway
//
//  Main game session controller - Refactored for modularity
//  Handles game session lifecycle and coordinates between subsystems
//

import UIKit

/// Game session category enumeration
enum SessionCategory {
    case solo
    case competitive

    var displayName: String {
        switch self {
        case .solo:
            return "Single Mode"
        case .competitive:
            return "Challenge Mode"
        }
    }

    var initialTileCount: Int {
        switch self {
        case .solo:
            return 1
        case .competitive:
            return 2
        }
    }
}

/// Main game session view controller
/// Coordinates between UI, game logic, and data persistence
class PlaySessionController: UIViewController {

    // MARK: - Subsystem Controllers

    /// HUD display manager
    private lazy var hudManager: GameHUDManager = {
        GameHUDManager(sessionCategory: sessionCategory)
    }()

    /// Game logic controller
    private lazy var gameLogicController: GameLogicController = {
        GameLogicController(
            sessionCategory: sessionCategory,
            playZonePanel: playZonePanel,
            delegate: self
        )
    }()

    /// Collision detection engine
    private lazy var collisionEngine: CollisionDetectionEngine = {
        CollisionDetectionEngine()
    }()

    /// Visual effects coordinator
    private lazy var visualEffectsCoordinator: GameVisualEffectsCoordinator = {
        GameVisualEffectsCoordinator(parentView: view)
    }()

    /// Game over presentation controller
    private lazy var gameOverPresenter: GameOverPresentationController = {
        GameOverPresentationController(parentView: view)
    }()

    /// Pause overlay controller
    private lazy var pauseOverlayController: PauseOverlayController = {
        PauseOverlayController(parentView: view)
    }()

    // MARK: - Properties

    private let sessionCategory: SessionCategory
    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView
    private let playZonePanel: UIView
    private let playZoneBorderStratum: CAShapeLayer

    // Bottom Controls
    private let footerControlsHolder: UIView
    private let exitAction: UIButton
    private let suspendAction: UIButton

    // Game State
    private var isSessionSuspended: Bool = false
    private var isSessionConcluded: Bool = false
    private var hasSessionPrepared = false

    // Session Timing
    private var sessionCommenceTime: Date?
    private var elapsedSessionDuration: TimeInterval = 0

    // MARK: - Initialization

    init(gameMode: SessionCategory) {
        self.sessionCategory = gameMode
        backdropPictureHolder = UIImageView()
        maskingPanel = UIView()
        playZonePanel = UIView()
        playZoneBorderStratum = CAShapeLayer()

        footerControlsHolder = UIView()
        exitAction = UIButton(type: .system)
        suspendAction = UIButton(type: .system)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSessionLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasSessionPrepared {
            commenceSession()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        haltSession()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updatePlayZoneBorder()
        initializeGameIfNeeded()
        gameLogicController.updateTilePositionsIfNeeded()
    }

    // MARK: - Layout Configuration

    private func configureSessionLayout() {
        view.backgroundColor = .black

        configureBackdrop()
        configurePlayZone()
        configureHUD()
        configureFooterControls()
    }

    private func configureBackdrop() {
        let backdropConfigurator = BackdropConfigurator(
            backdropPictureHolder: backdropPictureHolder,
            maskingPanel: maskingPanel
        )
        backdropConfigurator.configure(in: view)
    }

    private func configurePlayZone() {
        let playZoneConfigurator = PlayZoneConfigurator(
            playZonePanel: playZonePanel,
            playZoneBorderStratum: playZoneBorderStratum
        )
        playZoneConfigurator.configure(in: view)
    }

    private func configureHUD() {
        hudManager.configure(in: view)
    }

    private func configureFooterControls() {
        let controlsConfigurator = FooterControlsConfigurator(
            footerControlsHolder: footerControlsHolder,
            exitAction: exitAction,
            suspendAction: suspendAction
        )
        controlsConfigurator.configure(in: view)

        exitAction.addTarget(self, action: #selector(exitActionTouched), for: .touchUpInside)
        suspendAction.addTarget(self, action: #selector(suspendActionTouched), for: .touchUpInside)
    }

    private func updatePlayZoneBorder() {
        let borderPath = UIBezierPath(roundedRect: playZonePanel.bounds, cornerRadius: 20)
        playZoneBorderStratum.path = borderPath.cgPath
        playZoneBorderStratum.frame = playZonePanel.bounds

        executePerimeterDash()
    }

    private func executePerimeterDash() {
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = 24
        animation.duration = 1.5
        animation.repeatCount = .infinity
        playZoneBorderStratum.add(animation, forKey: "dashAnimation")
    }

    private func initializeGameIfNeeded() {
        guard !hasSessionPrepared,
              playZonePanel.bounds.width > 0,
              playZonePanel.bounds.height > 0 else { return }

        hasSessionPrepared = true
        prepareSession()

        if view.window != nil {
            commenceSession()
        }
    }

    // MARK: - Session Control

    private func prepareSession() {
        hudManager.resetDisplay()
        sessionCommenceTime = nil
        elapsedSessionDuration = 0

        gameLogicController.prepareGame()
    }

    private func commenceSession() {
        isSessionSuspended = false
        isSessionConcluded = false
        sessionCommenceTime = Date()

        gameLogicController.startGame()
        hudManager.startChronometer { [weak self] in
            self?.elapsedSessionDuration += 1
        }
    }

    private func haltSession() {
        gameLogicController.stopGame()
        hudManager.stopChronometer()
    }

    private func concludeSession() {
        isSessionConcluded = true
        haltSession()

        persistSessionResults()
        displaySessionEndScreen()
    }

    private func persistSessionResults() {
        let gameTime = calculateGameTime()
        let modeString = sessionCategory.displayName
        let currentScore = gameLogicController.currentScore

        MatchHistoryHandler.globalHandler.storeMatchHistory(
            points: currentScore,
            category: modeString
        )

        if gameTime > 0 {
            MatchHistoryHandler.globalHandler.storePeakDurationHistory(
                duration: gameTime,
                category: modeString
            )
        }
    }

    private func calculateGameTime() -> TimeInterval {
        guard let startTime = sessionCommenceTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    private func displaySessionEndScreen() {
        let currentScore = gameLogicController.currentScore

        gameOverPresenter.present(
            score: currentScore,
            mode: sessionCategory.displayName,
            onPlayAgain: { [weak self] in
                self?.reinitializeSession()
            },
            onMainMenu: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
    }

    private func reinitializeSession() {
        gameOverPresenter.dismiss()

        gameLogicController.resetGame()
        hudManager.resetDisplay()

        hasSessionPrepared = false
        elapsedSessionDuration = 0

        if playZonePanel.bounds.width > 0 && playZonePanel.bounds.height > 0 {
            hasSessionPrepared = true
            prepareSession()
            commenceSession()
        }
    }

    // MARK: - Button Actions

    @objc private func exitActionTouched() {
        isSessionSuspended = true
        gameLogicController.pauseGame()
        hudManager.stopChronometer()

        let alert = UIAlertController(
            title: "Exit Game",
            message: "Are you sure you want to exit? Your progress will be saved.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.continueFromSuspension()
        })

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.saveProgressAndExit()
        })

        present(alert, animated: true)
    }

    private func saveProgressAndExit() {
        let currentScore = gameLogicController.currentScore

        if currentScore > 0 {
            let modeString = sessionCategory.displayName
            MatchHistoryHandler.globalHandler.storeMatchHistory(
                points: currentScore,
                category: modeString
            )

            if let startTime = sessionCommenceTime {
                let gameTime = Date().timeIntervalSince(startTime)
                MatchHistoryHandler.globalHandler.storePeakDurationHistory(
                    duration: gameTime,
                    category: modeString
                )
            }
        }
        dismiss(animated: true)
    }

    @objc private func suspendActionTouched() {
        isSessionSuspended.toggle()

        if isSessionSuspended {
            suspendAction.setImage(UIImage(systemName: "play.fill"), for: .normal)
            gameLogicController.pauseGame()
            hudManager.stopChronometer()
            pauseOverlayController.show()
        } else {
            suspendAction.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            pauseOverlayController.dismiss()
            continueFromSuspension()
        }
    }

    private func continueFromSuspension() {
        isSessionSuspended = false
        commenceSession()
    }
}

// MARK: - GameLogicControllerDelegate

extension PlaySessionController: GameLogicControllerDelegate {

    func gameLogicControllerDidUpdateScore(_ score: Int) {
        hudManager.updateScore(score)
    }

    func gameLogicControllerDidUpdateLives(_ lives: Int) {
        hudManager.updateLives(lives)

        if lives <= 0 {
            concludeSession()
        }
    }

    func gameLogicControllerDidUpdateLevel(_ level: Int) {
        hudManager.updateLevel(level)
        visualEffectsCoordinator.showLevelUpEffect()
    }

    func gameLogicControllerDidUpdateCombo(_ combo: Int) {
        hudManager.updateCombo(combo)
    }

    func gameLogicControllerDidDetectCollision(at tile: DominoBlockPanel) {
        visualEffectsCoordinator.showDamageEffect()
        visualEffectsCoordinator.shakeScreen()
        tile.executeVibrationMotion()
    }

    func gameLogicControllerIsSessionActive() -> Bool {
        return !isSessionSuspended && !isSessionConcluded
    }
}
