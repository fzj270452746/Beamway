//
//  ViewComponentProtocols.swift
//  Beamway
//
//  UI component protocol definitions
//

import UIKit

// MARK: - View Configuration Protocols

/// Protocol for views that support programmatic configuration
protocol ProgrammaticViewConfigurable {
    /// Configure view hierarchy and add subviews
    func configureViewHierarchy()

    /// Configure layout constraints
    func configureLayoutConstraints()

    /// Configure visual styling and appearance
    func configureVisualStyling()

    /// Configure interaction handlers
    func configureInteractionHandlers()
}

extension ProgrammaticViewConfigurable {
    /// Default implementation for complete configuration
    func performCompleteConfiguration() {
        configureViewHierarchy()
        configureLayoutConstraints()
        configureVisualStyling()
        configureInteractionHandlers()
    }
}

/// Protocol for views with animated entrance
protocol AnimatedEntranceSupporting {
    /// Prepare view for entrance animation (set initial state)
    func prepareForEntranceAnimation()

    /// Execute entrance animation sequence
    func executeEntranceAnimationSequence(delay: TimeInterval, completion: (() -> Void)?)
}

/// Protocol for views with animated exit
protocol AnimatedExitSupporting {
    /// Execute exit animation sequence
    func executeExitAnimationSequence(completion: (() -> Void)?)
}

/// Combined protocol for full animation support
typealias FullAnimationSupporting = AnimatedEntranceSupporting & AnimatedExitSupporting

// MARK: - Interactive Component Protocols

/// Protocol for tappable interactive components
protocol TappableInteractiveComponent: AnyObject {
    /// Touch down state handler
    func handleTouchDownState()

    /// Touch up state handler
    func handleTouchUpState()

    /// Touch cancelled state handler
    func handleTouchCancelledState()
}

/// Protocol for pressable buttons with visual feedback
protocol PressableButtonProtocol: TappableInteractiveComponent {
    /// Scale transform for pressed state
    var pressedStateScale: CGFloat { get }

    /// Opacity for pressed state
    var pressedStateOpacity: CGFloat { get }

    /// Animation duration for state transitions
    var stateTransitionDuration: TimeInterval { get }
}

extension PressableButtonProtocol where Self: UIView {
    var pressedStateScale: CGFloat { return 0.95 }
    var pressedStateOpacity: CGFloat { return 0.85 }
    var stateTransitionDuration: TimeInterval { return 0.1 }

    func handleTouchDownState() {
        UIView.animate(withDuration: stateTransitionDuration) {
            self.transform = CGAffineTransform(scaleX: self.pressedStateScale, y: self.pressedStateScale)
            self.alpha = self.pressedStateOpacity
        }
    }

    func handleTouchUpState() {
        UIView.animate(
            withDuration: stateTransitionDuration * 2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    func handleTouchCancelledState() {
        UIView.animate(withDuration: stateTransitionDuration) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - Data Display Protocols

/// Protocol for views that display data with refresh capability
protocol DataDisplayRefreshable {
    associatedtype DisplayDataType

    /// Refresh display with new data
    func refreshDisplay(with data: DisplayDataType)

    /// Clear displayed data
    func clearDisplayedData()
}

/// Protocol for views with loading state
protocol LoadingStateDisplayable {
    /// Show loading indicator
    func showLoadingIndicator()

    /// Hide loading indicator
    func hideLoadingIndicator()

    /// Show error state with message
    func showErrorState(message: String)

    /// Show empty state with message
    func showEmptyState(message: String)
}

/// Protocol for views with content state management
protocol ContentStateManageable: LoadingStateDisplayable {
    /// Current content state
    var currentContentState: ContentDisplayState { get set }

    /// Transition to new content state
    func transitionToContentState(_ newState: ContentDisplayState, animated: Bool)
}

/// Content display state enumeration
enum ContentDisplayState {
    case loading
    case content
    case empty(message: String)
    case error(message: String)
}

// MARK: - Theme Support Protocols

/// Protocol for components supporting theming
protocol ThemeableComponent {
    /// Apply theme configuration
    func applyThemeConfiguration(_ theme: ThemeConfiguration)
}

/// Protocol for components with glow effects
protocol GlowEffectSupporting {
    /// Glow color for the component
    var glowEffectColor: UIColor { get }

    /// Glow radius
    var glowEffectRadius: CGFloat { get }

    /// Glow opacity
    var glowEffectOpacity: Float { get }

    /// Apply glow effect to layer
    func applyGlowEffect()

    /// Remove glow effect from layer
    func removeGlowEffect()
}

extension GlowEffectSupporting where Self: UIView {
    func applyGlowEffect() {
        layer.shadowColor = glowEffectColor.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = glowEffectRadius
        layer.shadowOpacity = glowEffectOpacity
    }

    func removeGlowEffect() {
        layer.shadowOpacity = 0
    }
}

/// Protocol for components with gradient backgrounds
protocol GradientBackgroundSupporting {
    /// Gradient colors array
    var gradientColors: [UIColor] { get }

    /// Gradient start point
    var gradientStartPoint: CGPoint { get }

    /// Gradient end point
    var gradientEndPoint: CGPoint { get }

    /// Apply gradient background
    func applyGradientBackground()
}

// MARK: - Reusable View Protocols

/// Protocol for reusable table/collection view cells
protocol ReusableCellIdentifiable {
    /// Reuse identifier for the cell
    static var cellReuseIdentifier: String { get }

    /// Nib name if cell is loaded from nib
    static var cellNibName: String? { get }
}

extension ReusableCellIdentifiable {
    static var cellReuseIdentifier: String {
        return String(describing: self)
    }

    static var cellNibName: String? {
        return nil
    }
}

/// Protocol for configurable table/collection view cells
protocol ConfigurableCellProtocol: ReusableCellIdentifiable {
    associatedtype CellDataType

    /// Configure cell with data
    func configureCell(with data: CellDataType)

    /// Reset cell to default state for reuse
    func resetCellForReuse()
}

// MARK: - View Controller Protocols

/// Protocol for view controllers with programmatic views
protocol ProgrammaticViewControllerProtocol {
    /// Create and configure the main view
    func createProgrammaticView() -> UIView

    /// Configure view controller appearance
    func configureViewControllerAppearance()

    /// Configure navigation items
    func configureNavigationItems()
}

/// Protocol for view controllers with refresh capability
protocol RefreshableViewControllerProtocol {
    /// Refresh view controller content
    func refreshViewControllerContent()

    /// Whether refresh is currently in progress
    var isRefreshInProgress: Bool { get }
}

/// Protocol for view controllers with dismissal capability
protocol DismissibleViewControllerProtocol: AnyObject {
    /// Dismiss view controller with animation
    func dismissViewController(animated: Bool, completion: (() -> Void)?)
}

// MARK: - HUD Component Protocols

/// Protocol for heads-up display components
protocol HUDComponentProtocol {
    /// Update HUD with current game state
    func updateHUDWithGameState(_ gameState: HUDGameStateData)
}

/// HUD game state data structure
struct HUDGameStateData {
    let currentScore: Int
    let currentHealth: Int
    let maximumHealth: Int
    let currentLevel: Int
    let elapsedTime: TimeInterval
    let currentCombo: Int

    static let initial = HUDGameStateData(
        currentScore: 0,
        currentHealth: 3,
        maximumHealth: 3,
        currentLevel: 1,
        elapsedTime: 0,
        currentCombo: 0
    )
}

/// Protocol for animated value display labels
protocol AnimatedValueDisplayProtocol {
    /// Current displayed value
    var currentDisplayedValue: Int { get }

    /// Update displayed value with animation
    func updateDisplayedValue(_ newValue: Int, animated: Bool)

    /// Execute pulse animation for value change
    func executePulseAnimation()
}
