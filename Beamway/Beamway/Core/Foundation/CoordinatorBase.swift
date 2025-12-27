//
//  CoordinatorBase.swift
//  Beamway
//
//  Navigation coordination pattern implementation
//

import UIKit

/// Base protocol defining coordinator navigation pattern requirements
protocol NavigationCoordinatorProtocol: AnyObject {
    /// Child coordinators managed by this coordinator
    var subordinateCoordinators: [NavigationCoordinatorProtocol] { get set }

    /// Parent coordinator reference (weak to prevent retain cycles)
    var supervisorCoordinator: NavigationCoordinatorProtocol? { get set }

    /// Begin coordinator navigation flow
    func initiateNavigationFlow()

    /// Terminate coordinator and cleanup resources
    func terminateNavigationFlow()

    /// Add a child coordinator
    func attachSubordinateCoordinator(_ coordinator: NavigationCoordinatorProtocol)

    /// Remove a child coordinator
    func detachSubordinateCoordinator(_ coordinator: NavigationCoordinatorProtocol)
}

/// Abstract base class for coordinator pattern implementation
class NavigationCoordinatorBase: NavigationCoordinatorProtocol {

    // MARK: - Properties

    /// Array of child coordinators under this coordinator's management
    var subordinateCoordinators: [NavigationCoordinatorProtocol] = []

    /// Reference to parent coordinator for upward navigation
    weak var supervisorCoordinator: NavigationCoordinatorProtocol?

    /// Primary navigation controller for view controller presentation
    weak var primaryNavigationController: UINavigationController?

    /// Coordinator unique identifier for tracking and debugging
    let coordinatorIdentifier: String

    /// Flag indicating if coordinator is currently active
    private(set) var isCoordinatorActive: Bool = false

    /// Completion handler to be called when coordinator finishes
    var completionHandler: (() -> Void)?

    // MARK: - Initialization

    init(navigationController: UINavigationController? = nil, identifier: String = UUID().uuidString) {
        self.primaryNavigationController = navigationController
        self.coordinatorIdentifier = identifier
    }

    // MARK: - Navigation Flow Management

    /// Begin the coordinator's navigation flow (to be overridden by subclasses)
    func initiateNavigationFlow() {
        isCoordinatorActive = true
    }

    /// Terminate the coordinator and cleanup all resources
    func terminateNavigationFlow() {
        isCoordinatorActive = false

        // Terminate all child coordinators first
        subordinateCoordinators.forEach { childCoordinator in
            childCoordinator.terminateNavigationFlow()
        }
        subordinateCoordinators.removeAll()

        // Notify parent to remove this coordinator
        supervisorCoordinator?.detachSubordinateCoordinator(self)

        // Execute completion handler
        completionHandler?()
        completionHandler = nil
    }

    // MARK: - Child Coordinator Management

    /// Attach a subordinate coordinator to this coordinator's hierarchy
    func attachSubordinateCoordinator(_ coordinator: NavigationCoordinatorProtocol) {
        coordinator.supervisorCoordinator = self
        subordinateCoordinators.append(coordinator)
    }

    /// Detach a subordinate coordinator from this coordinator's hierarchy
    func detachSubordinateCoordinator(_ coordinator: NavigationCoordinatorProtocol) {
        subordinateCoordinators.removeAll { existingCoordinator in
            if let existing = existingCoordinator as? NavigationCoordinatorBase,
               let removing = coordinator as? NavigationCoordinatorBase {
                return existing.coordinatorIdentifier == removing.coordinatorIdentifier
            }
            return false
        }
    }

    // MARK: - Presentation Utilities

    /// Present a view controller modally with animation
    func presentControllerModally(_ viewController: UIViewController,
                                   animated: Bool = true,
                                   presentationStyle: UIModalPresentationStyle = .fullScreen,
                                   transitionStyle: UIModalTransitionStyle = .coverVertical,
                                   completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = presentationStyle
        viewController.modalTransitionStyle = transitionStyle
        primaryNavigationController?.present(viewController, animated: animated, completion: completion)
    }

    /// Push a view controller onto the navigation stack
    func pushControllerOntoStack(_ viewController: UIViewController, animated: Bool = true) {
        primaryNavigationController?.pushViewController(viewController, animated: animated)
    }

    /// Pop the top view controller from the navigation stack
    func popControllerFromStack(animated: Bool = true) {
        primaryNavigationController?.popViewController(animated: animated)
    }

    /// Pop to root view controller
    func popToRootController(animated: Bool = true) {
        primaryNavigationController?.popToRootViewController(animated: animated)
    }

    /// Dismiss currently presented view controller
    func dismissPresentedController(animated: Bool = true, completion: (() -> Void)? = nil) {
        primaryNavigationController?.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Application Root Coordinator

/// Main application coordinator managing top-level navigation flow
final class ApplicationRootCoordinator: NavigationCoordinatorBase {

    // MARK: - Properties

    /// Main application window reference
    private weak var applicationWindow: UIWindow?

    /// Current active scene coordinator
    private var activeSceneCoordinator: NavigationCoordinatorBase?

    // MARK: - Initialization

    init(window: UIWindow?) {
        self.applicationWindow = window
        super.init(identifier: "ApplicationRootCoordinator")
    }

    // MARK: - Flow Management

    override func initiateNavigationFlow() {
        super.initiateNavigationFlow()
        transitionToWelcomeScene()
    }

    /// Transition to welcome/home scene
    func transitionToWelcomeScene() {
        let welcomeCoordinator = WelcomeSceneCoordinator(window: applicationWindow)
        welcomeCoordinator.navigationEventHandler = { [weak self] event in
            self?.handleWelcomeSceneEvent(event)
        }
        attachSubordinateCoordinator(welcomeCoordinator)
        activeSceneCoordinator = welcomeCoordinator
        welcomeCoordinator.initiateNavigationFlow()
    }

    /// Transition to game session scene
    func transitionToGameSession(configuration: GameSessionConfiguration) {
        let gameCoordinator = GameSessionSceneCoordinator(
            window: applicationWindow,
            configuration: configuration
        )
        gameCoordinator.navigationEventHandler = { [weak self] event in
            self?.handleGameSessionEvent(event)
        }
        attachSubordinateCoordinator(gameCoordinator)
        activeSceneCoordinator = gameCoordinator
        gameCoordinator.initiateNavigationFlow()
    }

    // MARK: - Event Handling

    private func handleWelcomeSceneEvent(_ event: WelcomeSceneNavigationEvent) {
        switch event {
        case .requestedGameModeSelection:
            break // Handle mode selection
        case .requestedQuickPlay:
            let configuration = GameSessionConfiguration(categoryType: .individualChallenge)
            transitionToGameSession(configuration: configuration)
        case .requestedRulesDisplay:
            break // Handle rules display
        case .requestedHistoryDisplay:
            break // Handle history display
        case .requestedSettingsDisplay:
            break // Handle settings display
        }
    }

    private func handleGameSessionEvent(_ event: GameSessionNavigationEvent) {
        switch event {
        case .sessionCompleted:
            transitionToWelcomeScene()
        case .sessionAborted:
            transitionToWelcomeScene()
        case .requestedReplay:
            break // Handle replay
        }
    }
}

// MARK: - Scene Coordinators

/// Welcome scene coordinator for main menu navigation
final class WelcomeSceneCoordinator: NavigationCoordinatorBase {

    typealias NavigationEventHandler = (WelcomeSceneNavigationEvent) -> Void

    private weak var applicationWindow: UIWindow?
    var navigationEventHandler: NavigationEventHandler?

    init(window: UIWindow?) {
        self.applicationWindow = window
        super.init(identifier: "WelcomeSceneCoordinator")
    }

    override func initiateNavigationFlow() {
        super.initiateNavigationFlow()
        // Scene initialization handled by view controller
    }
}

/// Game session scene coordinator for gameplay navigation
final class GameSessionSceneCoordinator: NavigationCoordinatorBase {

    typealias NavigationEventHandler = (GameSessionNavigationEvent) -> Void

    private weak var applicationWindow: UIWindow?
    private let sessionConfiguration: GameSessionConfiguration
    var navigationEventHandler: NavigationEventHandler?

    init(window: UIWindow?, configuration: GameSessionConfiguration) {
        self.applicationWindow = window
        self.sessionConfiguration = configuration
        super.init(identifier: "GameSessionSceneCoordinator")
    }

    override func initiateNavigationFlow() {
        super.initiateNavigationFlow()
        // Session initialization handled by view controller
    }
}

// MARK: - Navigation Events

/// Welcome scene navigation events
enum WelcomeSceneNavigationEvent {
    case requestedGameModeSelection
    case requestedQuickPlay
    case requestedRulesDisplay
    case requestedHistoryDisplay
    case requestedSettingsDisplay
}

/// Game session navigation events
enum GameSessionNavigationEvent {
    case sessionCompleted
    case sessionAborted
    case requestedReplay
}

/// Game session configuration
struct GameSessionConfiguration {
    let categoryType: GameCategoryType
    let difficultyLevel: DifficultyLevel
    let enabledFeatures: SessionFeatureFlags

    init(categoryType: GameCategoryType,
         difficultyLevel: DifficultyLevel = .standard,
         enabledFeatures: SessionFeatureFlags = SessionFeatureFlags()) {
        self.categoryType = categoryType
        self.difficultyLevel = difficultyLevel
        self.enabledFeatures = enabledFeatures
    }
}

/// Game category type enumeration
enum GameCategoryType {
    case individualChallenge
    case competitiveMultiBlock
}

/// Difficulty level enumeration
enum DifficultyLevel {
    case beginner
    case standard
    case advanced
    case expert
}

/// Session feature flags
struct SessionFeatureFlags {
    var comboSystemEnabled: Bool = true
    var streakTrackingEnabled: Bool = true
    var hapticFeedbackEnabled: Bool = true
    var visualEffectsEnabled: Bool = true
}
