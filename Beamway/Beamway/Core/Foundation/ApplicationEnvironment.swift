//
//  ApplicationEnvironment.swift
//  Beamway
//
//  Deep refactored architecture
//

import UIKit

/// Central application environment configuration and runtime state management
/// Provides singleton access to global application settings and environment detection
final class ApplicationEnvironment {

    // MARK: - Singleton Access Point

    /// Shared environment instance for global access throughout the application
    static let shared = ApplicationEnvironment()

    // MARK: - Environment Properties

    /// Current device screen dimensions for layout calculations
    private(set) var displayDimensions: CGSize

    /// Safe area insets for content positioning
    private(set) var safeRegionInsets: UIEdgeInsets

    /// Device type classification for adaptive layouts
    private(set) var hardwareClassification: HardwareClassification

    /// Application build configuration environment
    private(set) var buildEnvironmentType: BuildEnvironmentType

    /// Current interface orientation state
    private(set) var orientationState: UIInterfaceOrientation

    /// Runtime feature availability flags
    private(set) var featureAvailability: FeatureAvailabilityFlags

    // MARK: - Initialization

    private init() {
        let screenBounds = UIScreen.main.bounds
        self.displayDimensions = screenBounds.size
        self.safeRegionInsets = .zero
        self.hardwareClassification = Self.determineHardwareClassification()
        self.buildEnvironmentType = Self.determineBuildEnvironment()
        self.orientationState = .portrait
        self.featureAvailability = FeatureAvailabilityFlags()

        configureEnvironmentObservers()
    }

    // MARK: - Configuration Methods

    /// Configure environment observers for runtime state changes
    private func configureEnvironmentObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationTransition(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryConstraint(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    /// Update safe area insets from window scene
    func synchronizeSafeRegionInsets(from windowScene: UIWindowScene?) {
        guard let windowScene = windowScene,
              let primaryWindow = windowScene.windows.first else {
            return
        }
        safeRegionInsets = primaryWindow.safeAreaInsets
    }

    /// Update display dimensions on screen size changes
    func synchronizeDisplayDimensions(_ newDimensions: CGSize) {
        guard newDimensions.width > 0 && newDimensions.height > 0 else { return }
        displayDimensions = newDimensions
    }

    // MARK: - Environment Detection

    /// Determine hardware classification based on device characteristics
    private static func determineHardwareClassification() -> HardwareClassification {
        let deviceModel = UIDevice.current.userInterfaceIdiom
        let screenScale = UIScreen.main.scale
        let screenSize = UIScreen.main.bounds.size

        switch deviceModel {
        case .phone:
            let maxDimension = max(screenSize.width, screenSize.height)
            if maxDimension >= 896 {
                return .modernSmartphone
            } else if maxDimension >= 736 {
                return .standardSmartphone
            } else {
                return .compactSmartphone
            }
        case .pad:
            if screenScale >= 2.0 && max(screenSize.width, screenSize.height) >= 1024 {
                return .modernTablet
            }
            return .standardTablet
        default:
            return .standardSmartphone
        }
    }

    /// Determine build environment from compilation flags
    private static func determineBuildEnvironment() -> BuildEnvironmentType {
        #if DEBUG
        return .developmentBuild
        #elseif STAGING
        return .stagingBuild
        #else
        return .productionBuild
        #endif
    }

    // MARK: - Notification Handlers

    @objc private func handleOrientationTransition(_ notification: Notification) {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            orientationState = .portrait
        case .portraitUpsideDown:
            orientationState = .portraitUpsideDown
        case .landscapeLeft:
            orientationState = .landscapeLeft
        case .landscapeRight:
            orientationState = .landscapeRight
        default:
            break
        }
    }

    @objc private func handleMemoryConstraint(_ notification: Notification) {
        featureAvailability.reduceFeatureSetForMemoryConstraint()
    }

    // MARK: - Convenience Accessors

    /// Check if device supports haptic feedback
    var supportsHapticFeedback: Bool {
        return featureAvailability.hapticEngineAvailable
    }

    /// Check if device has sufficient performance for complex animations
    var supportsComplexAnimations: Bool {
        return featureAvailability.complexAnimationsEnabled
    }

    /// Get appropriate content scale for current device
    var contentScaleFactor: CGFloat {
        return hardwareClassification.recommendedContentScale
    }
}

// MARK: - Supporting Types

/// Hardware classification enumeration for device-specific adaptations
enum HardwareClassification {
    case compactSmartphone
    case standardSmartphone
    case modernSmartphone
    case standardTablet
    case modernTablet

    /// Recommended content scale for this hardware class
    var recommendedContentScale: CGFloat {
        switch self {
        case .compactSmartphone:
            return 0.85
        case .standardSmartphone:
            return 1.0
        case .modernSmartphone:
            return 1.1
        case .standardTablet:
            return 1.2
        case .modernTablet:
            return 1.3
        }
    }

    /// Maximum concurrent animation count for this hardware class
    var maxConcurrentAnimations: Int {
        switch self {
        case .compactSmartphone:
            return 8
        case .standardSmartphone:
            return 12
        case .modernSmartphone:
            return 16
        case .standardTablet:
            return 20
        case .modernTablet:
            return 24
        }
    }
}

/// Build environment type enumeration
enum BuildEnvironmentType {
    case developmentBuild
    case stagingBuild
    case productionBuild

    /// Whether verbose logging should be enabled
    var verboseLoggingEnabled: Bool {
        return self == .developmentBuild
    }

    /// Whether analytics should be active
    var analyticsEnabled: Bool {
        return self != .developmentBuild
    }
}

/// Feature availability flags structure
struct FeatureAvailabilityFlags {
    var hapticEngineAvailable: Bool
    var complexAnimationsEnabled: Bool
    var particleEffectsEnabled: Bool
    var highQualityRenderingEnabled: Bool
    var backgroundProcessingEnabled: Bool

    init() {
        self.hapticEngineAvailable = UIDevice.current.userInterfaceIdiom == .phone
        self.complexAnimationsEnabled = true
        self.particleEffectsEnabled = true
        self.highQualityRenderingEnabled = true
        self.backgroundProcessingEnabled = true
    }

    /// Reduce feature set when memory is constrained
    mutating func reduceFeatureSetForMemoryConstraint() {
        particleEffectsEnabled = false
        highQualityRenderingEnabled = false
    }

    /// Restore full feature set
    mutating func restoreFullFeatureSet() {
        particleEffectsEnabled = true
        highQualityRenderingEnabled = true
    }
}
