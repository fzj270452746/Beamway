//
//  VisualThemeConfiguration.swift
//  Beamway
//
//  Visual theming and design system configuration
//

import UIKit

/// Central visual theme configuration and design system management
/// Provides consistent styling across all application components
final class VisualThemeConfiguration {

    // MARK: - Singleton Access

    /// Shared theme configuration instance
    static let shared = VisualThemeConfiguration()

    // MARK: - Color Palette

    /// Primary color palette for the application
    struct ColorPalette {
        /// Primary neon cyan accent color
        let primaryNeonCyan = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)

        /// Secondary orange accent color
        let secondaryOrangeAccent = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)

        /// Tertiary purple accent color
        let tertiaryPurpleAccent = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)

        /// Gold highlight color
        let goldHighlightTint = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)

        /// Danger/warning red color
        let dangerIndicatorRed = UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)

        /// Blue mode selection color
        let blueModeTint = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)

        /// Challenge mode red color
        let challengeModeTint = UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)

        /// Background deep dark color
        let backgroundDeepDark = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)

        /// Alternative background color
        let backgroundAlternative = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)

        /// Text primary white color
        let textPrimaryWhite = UIColor.white

        /// Text secondary faded color
        let textSecondaryFaded = UIColor.white.withAlphaComponent(0.7)

        /// Text tertiary dim color
        let textTertiaryDim = UIColor.white.withAlphaComponent(0.5)

        /// Border subtle color
        let borderSubtleTint = UIColor.white.withAlphaComponent(0.15)

        /// Card background color
        let cardBackgroundTint = UIColor.white.withAlphaComponent(0.08)
    }

    /// Application color palette
    let colorPalette = ColorPalette()

    // MARK: - Typography Styles

    /// Typography style configuration
    struct TypographyStyles {
        /// Title hero style (large titles)
        let titleHeroStyle = TypographyStyle(
            fontSize: 48,
            fontWeight: .black,
            letterSpacing: -1.5
        )

        /// Title large style
        let titleLargeStyle = TypographyStyle(
            fontSize: 32,
            fontWeight: .black,
            letterSpacing: -1.0
        )

        /// Title medium style
        let titleMediumStyle = TypographyStyle(
            fontSize: 28,
            fontWeight: .bold,
            letterSpacing: -0.5
        )

        /// Heading style
        let headingStyle = TypographyStyle(
            fontSize: 20,
            fontWeight: .bold,
            letterSpacing: 0
        )

        /// Subheading style
        let subheadingStyle = TypographyStyle(
            fontSize: 16,
            fontWeight: .semibold,
            letterSpacing: 0
        )

        /// Body text style
        let bodyTextStyle = TypographyStyle(
            fontSize: 14,
            fontWeight: .regular,
            letterSpacing: 0
        )

        /// Caption style
        let captionStyle = TypographyStyle(
            fontSize: 12,
            fontWeight: .medium,
            letterSpacing: 0.2
        )

        /// Micro text style
        let microTextStyle = TypographyStyle(
            fontSize: 10,
            fontWeight: .medium,
            letterSpacing: 0.3
        )

        /// Score display style
        let scoreDisplayStyle = TypographyStyle(
            fontSize: 28,
            fontWeight: .black,
            letterSpacing: 0,
            usesMonospacedDigits: true
        )

        /// Timer display style
        let timerDisplayStyle = TypographyStyle(
            fontSize: 18,
            fontWeight: .bold,
            letterSpacing: 0,
            usesMonospacedDigits: true
        )
    }

    /// Typography styles configuration
    let typographyStyles = TypographyStyles()

    // MARK: - Component Styles

    /// Card styling configuration
    struct CardStyle {
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let borderColor: UIColor
        let backgroundColor: UIColor
        let shadowColor: UIColor
        let shadowRadius: CGFloat
        let shadowOpacity: Float
        let shadowOffset: CGSize

        static let standard = CardStyle(
            cornerRadius: 20,
            borderWidth: 1,
            borderColor: UIColor.white.withAlphaComponent(0.15),
            backgroundColor: UIColor.white.withAlphaComponent(0.08),
            shadowColor: .black,
            shadowRadius: 10,
            shadowOpacity: 0.3,
            shadowOffset: CGSize(width: 0, height: 4)
        )

        static let highlighted = CardStyle(
            cornerRadius: 25,
            borderWidth: 1.5,
            borderColor: UIColor.white.withAlphaComponent(0.25),
            backgroundColor: UIColor.white.withAlphaComponent(0.12),
            shadowColor: .black,
            shadowRadius: 15,
            shadowOpacity: 0.4,
            shadowOffset: CGSize(width: 0, height: 6)
        )

        static let compact = CardStyle(
            cornerRadius: 15,
            borderWidth: 1,
            borderColor: UIColor.white.withAlphaComponent(0.1),
            backgroundColor: UIColor.white.withAlphaComponent(0.05),
            shadowColor: .black,
            shadowRadius: 5,
            shadowOpacity: 0.2,
            shadowOffset: CGSize(width: 0, height: 2)
        )
    }

    /// Button styling configuration
    struct ButtonStyle {
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let height: CGFloat
        let font: UIFont
        let pressedScale: CGFloat
        let pressedOpacity: CGFloat

        static let primary = ButtonStyle(
            cornerRadius: 18,
            borderWidth: 2,
            height: 60,
            font: UIFont.systemFont(ofSize: 20, weight: .bold),
            pressedScale: 0.95,
            pressedOpacity: 0.9
        )

        static let secondary = ButtonStyle(
            cornerRadius: 15,
            borderWidth: 1.5,
            height: 50,
            font: UIFont.systemFont(ofSize: 18, weight: .bold),
            pressedScale: 0.95,
            pressedOpacity: 0.85
        )

        static let compact = ButtonStyle(
            cornerRadius: 12,
            borderWidth: 1,
            height: 40,
            font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            pressedScale: 0.95,
            pressedOpacity: 0.8
        )

        static let icon = ButtonStyle(
            cornerRadius: 22,
            borderWidth: 1,
            height: 44,
            font: UIFont.systemFont(ofSize: 16, weight: .medium),
            pressedScale: 0.9,
            pressedOpacity: 0.8
        )
    }

    // MARK: - Effect Configurations

    /// Glow effect configuration
    struct GlowEffectStyle {
        let glowRadius: CGFloat
        let glowOpacity: Float
        let pulseEnabled: Bool
        let pulseMinRadius: CGFloat
        let pulseMaxRadius: CGFloat
        let pulseDuration: TimeInterval

        static let subtle = GlowEffectStyle(
            glowRadius: 10,
            glowOpacity: 0.4,
            pulseEnabled: false,
            pulseMinRadius: 0,
            pulseMaxRadius: 0,
            pulseDuration: 0
        )

        static let prominent = GlowEffectStyle(
            glowRadius: 20,
            glowOpacity: 0.8,
            pulseEnabled: true,
            pulseMinRadius: 15,
            pulseMaxRadius: 25,
            pulseDuration: 1.5
        )

        static let intense = GlowEffectStyle(
            glowRadius: 30,
            glowOpacity: 1.0,
            pulseEnabled: true,
            pulseMinRadius: 20,
            pulseMaxRadius: 40,
            pulseDuration: 1.0
        )
    }

    /// Gradient configuration
    struct GradientStyle {
        let colors: [UIColor]
        let locations: [NSNumber]
        let startPoint: CGPoint
        let endPoint: CGPoint

        static func overlayGradient() -> GradientStyle {
            return GradientStyle(
                colors: [
                    UIColor.black.withAlphaComponent(0.7),
                    UIColor.black.withAlphaComponent(0.3),
                    UIColor.black.withAlphaComponent(0.5),
                    UIColor.black.withAlphaComponent(0.8)
                ],
                locations: [0.0, 0.3, 0.7, 1.0],
                startPoint: CGPoint(x: 0.5, y: 0),
                endPoint: CGPoint(x: 0.5, y: 1)
            )
        }

        static func buttonGradient(primaryColor: UIColor) -> GradientStyle {
            return GradientStyle(
                colors: [primaryColor, primaryColor.withAlphaComponent(0.7)],
                locations: [0.0, 1.0],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }

        /// Create CAGradientLayer from style
        func createGradientLayer() -> CAGradientLayer {
            let layer = CAGradientLayer()
            layer.colors = colors.map { $0.cgColor }
            layer.locations = locations
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            return layer
        }
    }

    // MARK: - Layout Constants

    /// Standard spacing values
    struct LayoutSpacing {
        let microSpacing: CGFloat = 4
        let smallSpacing: CGFloat = 8
        let standardSpacing: CGFloat = 12
        let mediumSpacing: CGFloat = 16
        let largeSpacing: CGFloat = 20
        let extraLargeSpacing: CGFloat = 25
        let sectionSpacing: CGFloat = 30

        let horizontalMargin: CGFloat = 20
        let verticalMargin: CGFloat = 15
    }

    /// Layout spacing configuration
    let layoutSpacing = LayoutSpacing()

    // MARK: - Initialization

    private init() {}

    // MARK: - Convenience Methods

    /// Apply standard card styling to view
    func applyStandardCardStyling(to view: UIView, style: CardStyle = .standard) {
        view.backgroundColor = style.backgroundColor
        view.layer.cornerRadius = style.cornerRadius
        view.layer.borderWidth = style.borderWidth
        view.layer.borderColor = style.borderColor.cgColor
        view.layer.shadowColor = style.shadowColor.cgColor
        view.layer.shadowRadius = style.shadowRadius
        view.layer.shadowOpacity = style.shadowOpacity
        view.layer.shadowOffset = style.shadowOffset
    }

    /// Apply glow effect to layer
    func applyGlowEffect(to layer: CALayer, color: UIColor, style: GlowEffectStyle = .subtle) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = style.glowRadius
        layer.shadowOpacity = style.glowOpacity
    }

    /// Create styled label with typography
    func createStyledLabel(typography: TypographyStyle, textColor: UIColor? = nil) -> UILabel {
        let label = UILabel()
        label.font = typography.createFont()
        label.textColor = textColor ?? colorPalette.textPrimaryWhite
        return label
    }
}

// MARK: - Supporting Types

/// Typography style structure
struct TypographyStyle {
    let fontSize: CGFloat
    let fontWeight: UIFont.Weight
    let letterSpacing: CGFloat
    let usesMonospacedDigits: Bool

    init(fontSize: CGFloat, fontWeight: UIFont.Weight, letterSpacing: CGFloat, usesMonospacedDigits: Bool = false) {
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.letterSpacing = letterSpacing
        self.usesMonospacedDigits = usesMonospacedDigits
    }

    /// Create UIFont from style
    func createFont() -> UIFont {
        if usesMonospacedDigits {
            return UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        }
        return UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }

    /// Create attributed string with style
    func createAttributedString(_ text: String, color: UIColor = .white) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: createFont(),
            .foregroundColor: color,
            .kern: letterSpacing
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
}

/// Theme configuration protocol for themed components
protocol ThemeConfiguration {
    var primaryAccentColor: UIColor { get }
    var secondaryAccentColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var textPrimaryColor: UIColor { get }
    var textSecondaryColor: UIColor { get }
}

/// Default theme configuration
struct DefaultThemeConfiguration: ThemeConfiguration {
    let primaryAccentColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
    let secondaryAccentColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    let backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
    let textPrimaryColor = UIColor.white
    let textSecondaryColor = UIColor.white.withAlphaComponent(0.7)
}
