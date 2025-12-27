//
//  GameplayConstants.swift
//  Beamway
//
//  Gameplay related constants and configuration values
//

import UIKit

/// Central repository for all gameplay-related constant values
/// Provides type-safe access to game configuration parameters
enum GameplayConstants {

    // MARK: - Session Configuration

    /// Session-related constant values
    enum SessionConfiguration {
        /// Initial health points for single mode
        static let singleModeInitialHealth: Int = 3

        /// Initial health points for challenge mode
        static let challengeModeInitialHealth: Int = 3

        /// Initial tile count for single mode
        static let singleModeInitialTiles: Int = 1

        /// Initial tile count for challenge mode
        static let challengeModeInitialTiles: Int = 2

        /// Maximum active tiles allowed
        static let maximumActiveTiles: Int = 5

        /// Session timeout duration (seconds)
        static let sessionTimeoutDuration: TimeInterval = 3600

        /// Auto-save interval (seconds)
        static let autoSaveInterval: TimeInterval = 30
    }

    // MARK: - Projectile Configuration

    /// Projectile-related constant values
    enum ProjectileConfiguration {
        /// Base projectile width
        static let baseProjectileWidth: CGFloat = 30

        /// Base projectile height
        static let baseProjectileHeight: CGFloat = 30

        /// Minimum spawn interval (fastest)
        static let minimumSpawnIntervalSeconds: TimeInterval = 0.8

        /// Maximum spawn interval (slowest)
        static let maximumSpawnIntervalSeconds: TimeInterval = 3.0

        /// Difficulty progression duration (seconds to reach max difficulty)
        static let difficultyProgressionDuration: TimeInterval = 60.0

        /// Base projectile velocity (points per second)
        static let baseProjectileVelocity: CGFloat = 150

        /// Maximum projectile velocity multiplier
        static let maximumVelocityMultiplier: CGFloat = 1.5

        /// Collision detection padding
        static let collisionDetectionPadding: CGFloat = 5.0

        /// Maximum simultaneous projectiles
        static let maximumSimultaneousProjectiles: Int = 20
    }

    // MARK: - Block/Tile Configuration

    /// Block tile-related constant values
    enum BlockConfiguration {
        /// Base block width
        static let baseBlockWidth: CGFloat = 45

        /// Base block height
        static let baseBlockHeight: CGFloat = 65

        /// Block corner radius
        static let blockCornerRadius: CGFloat = 4.5

        /// Block border width
        static let blockBorderWidth: CGFloat = 2.0

        /// Drag gesture threshold (minimum movement to start drag)
        static let dragGestureThreshold: CGFloat = 5.0

        /// Block shadow radius
        static let blockShadowRadius: CGFloat = 4.0

        /// Block shadow opacity
        static let blockShadowOpacity: Float = 0.3

        /// Total available tile images
        static let availableTileImageCount: Int = 27

        /// Tile image prefix
        static let tileImagePrefix: String = "be "
    }

    // MARK: - Scoring Configuration

    /// Scoring-related constant values
    enum ScoringConfiguration {
        /// Base points per dodged projectile
        static let basePointsPerDodge: Int = 1

        /// Points required for level advancement
        static let pointsPerLevel: Int = 10

        /// Combo threshold for bonus activation
        static let comboThresholdForBonus: Int = 5

        /// Maximum combo display value
        static let maximumComboDisplay: Int = 99

        /// Combo decay delay (seconds before combo starts decaying)
        static let comboDecayDelay: TimeInterval = 2.0

        /// Score animation duration
        static let scoreAnimationDuration: TimeInterval = 0.2
    }

    // MARK: - Play Zone Configuration

    /// Play zone area configuration
    enum PlayZoneConfiguration {
        /// Play zone border width
        static let borderWidth: CGFloat = 4.0

        /// Play zone corner radius
        static let cornerRadius: CGFloat = 20.0

        /// Play zone dash pattern
        static let dashPatternLength: CGFloat = 15.0

        /// Play zone dash gap length
        static let dashPatternGap: CGFloat = 10.0

        /// Play zone horizontal padding
        static let horizontalPadding: CGFloat = 20.0

        /// Play zone top padding
        static let topPadding: CGFloat = 100.0

        /// Play zone bottom padding
        static let bottomPadding: CGFloat = 100.0

        /// Border animation duration
        static let borderAnimationDuration: TimeInterval = 1.0
    }

    // MARK: - Animation Timing

    /// Animation timing constants
    enum AnimationTiming {
        /// Standard animation duration
        static let standardDuration: TimeInterval = 0.3

        /// Quick animation duration
        static let quickDuration: TimeInterval = 0.15

        /// Slow animation duration
        static let slowDuration: TimeInterval = 0.5

        /// Spring damping ratio
        static let springDampingRatio: CGFloat = 0.8

        /// Spring initial velocity
        static let springInitialVelocity: CGFloat = 0.5

        /// Entrance animation delay increment
        static let entranceDelayIncrement: TimeInterval = 0.1

        /// Projectile fade in duration
        static let projectileFadeInDuration: TimeInterval = 0.2
    }

    // MARK: - Display Refresh

    /// Display refresh configuration
    enum DisplayRefresh {
        /// Target frame rate
        static let targetFrameRate: Int = 60

        /// Frame interval (seconds)
        static let frameInterval: TimeInterval = 1.0 / 60.0

        /// Minimum frame rate
        static let minimumFrameRate: Int = 30

        /// Timer update interval
        static let timerUpdateInterval: TimeInterval = 1.0
    }

    // MARK: - Asset Names

    /// Asset naming constants
    enum AssetNames {
        /// Background image name
        static let backgroundImage: String = "benImage"

        /// Tile image format template
        static func tileImageName(index: Int) -> String {
            return "be \(index)"
        }

        /// Generate random tile image name
        static func randomTileImageName() -> String {
            let randomIndex = Int.random(in: 0...26)
            return tileImageName(index: randomIndex)
        }
    }

    // MARK: - Persistence Keys

    /// UserDefaults and persistence key constants
    enum PersistenceKeys {
        /// Longest time record prefix
        static let longestTimeRecordPrefix: String = "longestTime_"

        /// High score record key
        static let highScoreRecordKey: String = "highScore"

        /// Total games played key
        static let totalGamesPlayedKey: String = "totalGamesPlayed"

        /// Achievements unlocked key
        static let achievementsUnlockedKey: String = "achievementsUnlocked"

        /// Settings enabled haptic feedback
        static let hapticFeedbackEnabledKey: String = "hapticFeedbackEnabled"

        /// Settings sound enabled key
        static let soundEnabledKey: String = "soundEnabled"

        /// Generate longest time key for mode
        static func longestTimeKey(for mode: String) -> String {
            return "\(longestTimeRecordPrefix)\(mode)"
        }
    }

    // MARK: - Core Data Configuration

    /// Core Data entity and attribute names
    enum CoreDataConfiguration {
        /// Game record entity name
        static let gameRecordEntityName: String = "GameRecordEntity"

        /// Score value attribute
        static let scoreValueAttribute: String = "scoreValue"

        /// Game mode attribute
        static let gameModeAttribute: String = "gameMode"

        /// Record date attribute
        static let recordDateAttribute: String = "recordDate"

        /// Record identifier attribute
        static let recordIdentifierAttribute: String = "recordIdentifier"

        /// Core data model name
        static let modelName: String = "Beamway"
    }

    // MARK: - Game Mode Identifiers

    /// Game mode identifier strings
    enum GameModeIdentifiers {
        /// Single mode identifier
        static let singleMode: String = "Single Mode"

        /// Challenge mode identifier
        static let challengeMode: String = "Challenge Mode"

        /// Convert category type to identifier
        static func identifier(for categoryType: GameCategoryType) -> String {
            switch categoryType {
            case .individualChallenge:
                return singleMode
            case .competitiveMultiBlock:
                return challengeMode
            }
        }
    }

    // MARK: - UI Element Tags

    /// UI element tag values for view identification
    enum UIElementTags {
        /// Stats panel total games tag
        static let totalGamesTag: Int = 100

        /// Stats panel high score tag
        static let highScoreTag: Int = 101

        /// Stats panel best time tag
        static let bestTimeTag: Int = 102

        /// HUD score display tag
        static let hudScoreTag: Int = 200

        /// HUD health display tag
        static let hudHealthTag: Int = 201

        /// HUD timer display tag
        static let hudTimerTag: Int = 202

        /// HUD combo display tag
        static let hudComboTag: Int = 203

        /// HUD level display tag
        static let hudLevelTag: Int = 204
    }
}

// MARK: - Computed Constants

extension GameplayConstants {

    /// Calculate spawn interval for current difficulty factor
    static func calculateSpawnInterval(difficultyFactor: CGFloat) -> TimeInterval {
        let maxInterval = ProjectileConfiguration.maximumSpawnIntervalSeconds
        let minInterval = ProjectileConfiguration.minimumSpawnIntervalSeconds
        return maxInterval - (maxInterval - minInterval) * Double(difficultyFactor)
    }

    /// Calculate velocity multiplier for current difficulty factor
    static func calculateVelocityMultiplier(difficultyFactor: CGFloat) -> CGFloat {
        return 1.0 + (ProjectileConfiguration.maximumVelocityMultiplier - 1.0) * difficultyFactor
    }

    /// Calculate level number from score
    static func calculateLevel(from score: Int) -> Int {
        return (score / ScoringConfiguration.pointsPerLevel) + 1
    }
}
