//
//  ModeSelectionAnimationController.swift
//  Beamway
//
//  Animation controllers for mode selection screen
//  Handles entrance animations and floating elements
//

import UIKit

// MARK: - Animation Coordinator

/// Coordinates entrance animations for mode selection screen
final class ModeSelectionAnimationCoordinator {

    // MARK: - Animation Configuration

    struct AnimationConfiguration {
        static let headerDelay: TimeInterval = 0.1
        static let soloTileDelay: TimeInterval = 0.25
        static let competitiveTileDelay: TimeInterval = 0.35
        static let explanationDelay: TimeInterval = 0.5

        static let springDuration: TimeInterval = 0.5
        static let tileDuration: TimeInterval = 0.6
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5

        static let headerTranslation: CGFloat = -30
        static let soloTileTranslation: CGFloat = -50
        static let competitiveTileTranslation: CGFloat = 50
        static let explanationTranslation: CGFloat = 30
    }

    // MARK: - Properties

    private weak var topSection: UIView?
    private weak var soloTile: UIView?
    private weak var competitiveTile: UIView?
    private weak var explanationSection: UIView?

    // MARK: - Public Methods

    /// Register views for entrance animation
    func registerViewsForAnimation(
        topSection: UIView,
        soloTile: UIView,
        competitiveTile: UIView,
        explanationSection: UIView
    ) {
        self.topSection = topSection
        self.soloTile = soloTile
        self.competitiveTile = competitiveTile
        self.explanationSection = explanationSection
    }

    /// Prepare views for entrance animation (set initial state)
    func prepareForEntranceAnimation() {
        prepareTopSection()
        prepareSoloTile()
        prepareCompetitiveTile()
        prepareExplanationSection()
    }

    /// Execute the entrance animation sequence
    func executeEntranceAnimationSequence() {
        animateTopSection()
        animateSoloTile()
        animateCompetitiveTile()
        animateExplanationSection()
    }

    // MARK: - Preparation Methods

    private func prepareTopSection() {
        topSection?.alpha = 0
        topSection?.transform = CGAffineTransform(
            translationX: 0,
            y: AnimationConfiguration.headerTranslation
        )
    }

    private func prepareSoloTile() {
        soloTile?.alpha = 0
        soloTile?.transform = CGAffineTransform(
            translationX: AnimationConfiguration.soloTileTranslation,
            y: 0
        )
    }

    private func prepareCompetitiveTile() {
        competitiveTile?.alpha = 0
        competitiveTile?.transform = CGAffineTransform(
            translationX: AnimationConfiguration.competitiveTileTranslation,
            y: 0
        )
    }

    private func prepareExplanationSection() {
        explanationSection?.alpha = 0
        explanationSection?.transform = CGAffineTransform(
            translationX: 0,
            y: AnimationConfiguration.explanationTranslation
        )
    }

    // MARK: - Animation Methods

    private func animateTopSection() {
        UIView.animate(
            withDuration: AnimationConfiguration.springDuration,
            delay: AnimationConfiguration.headerDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.topSection?.alpha = 1
            self?.topSection?.transform = .identity
        }
    }

    private func animateSoloTile() {
        UIView.animate(
            withDuration: AnimationConfiguration.tileDuration,
            delay: AnimationConfiguration.soloTileDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.soloTile?.alpha = 1
            self?.soloTile?.transform = .identity
        }
    }

    private func animateCompetitiveTile() {
        UIView.animate(
            withDuration: AnimationConfiguration.tileDuration,
            delay: AnimationConfiguration.competitiveTileDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.competitiveTile?.alpha = 1
            self?.competitiveTile?.transform = .identity
        }
    }

    private func animateExplanationSection() {
        UIView.animate(
            withDuration: AnimationConfiguration.springDuration,
            delay: AnimationConfiguration.explanationDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.explanationSection?.alpha = 1
            self?.explanationSection?.transform = .identity
        }
    }
}

// MARK: - Floating Elements Controller

/// Controls floating decorative mahjong tile elements
final class ModeSelectionFloatingElementsController {

    // MARK: - Configuration

    struct FloatingConfiguration {
        static let elementCount: Int = 4
        static let elementAlpha: CGFloat = 0.1
        static let elementWidth: CGFloat = 35
        static let elementHeight: CGFloat = 50
        static let maxTileIndex: Int = 26

        static let minAnimationDuration: Double = 3.0
        static let maxAnimationDuration: Double = 5.0
        static let minXOffset: CGFloat = -20
        static let maxXOffset: CGFloat = 20
        static let minYOffset: CGFloat = -30
        static let maxYOffset: CGFloat = 30
        static let minRotation: CGFloat = -0.2
        static let maxRotation: CGFloat = 0.2
    }

    // MARK: - Properties

    private var floatingElements: [UIImageView] = []
    private var isAnimating: Bool = false

    // MARK: - Public Methods

    /// Setup floating mahjong tile elements in the view hierarchy
    func setupFloatingElements(in parentView: UIView, aboveView: UIView) {
        for _ in 0..<FloatingConfiguration.elementCount {
            let tileImageView = createFloatingTileView()
            positionFloatingTile(tileImageView, in: parentView)
            parentView.insertSubview(tileImageView, aboveSubview: aboveView)
            floatingElements.append(tileImageView)
        }
    }

    /// Start continuous floating animations
    func startAnimations() {
        guard !isAnimating else { return }
        isAnimating = true

        for element in floatingElements {
            executeFloatingAnimation(for: element)
        }
    }

    /// Stop all floating animations
    func stopAnimations() {
        isAnimating = false
        for element in floatingElements {
            element.layer.removeAllAnimations()
        }
    }

    /// Remove all floating elements from view hierarchy
    func removeAllElements() {
        stopAnimations()
        for element in floatingElements {
            element.removeFromSuperview()
        }
        floatingElements.removeAll()
    }

    // MARK: - Private Methods

    private func createFloatingTileView() -> UIImageView {
        let tileImageView = UIImageView()
        let randomIndex = Int.random(in: 0...FloatingConfiguration.maxTileIndex)
        let imageName = "be \(randomIndex)"
        tileImageView.image = UIImage(named: imageName)
        tileImageView.contentMode = .scaleAspectFit
        tileImageView.alpha = FloatingConfiguration.elementAlpha
        return tileImageView
    }

    private func positionFloatingTile(_ tileView: UIImageView, in parentView: UIView) {
        let screenBounds = UIScreen.main.bounds
        tileView.frame = CGRect(
            x: CGFloat.random(in: 0...screenBounds.width),
            y: CGFloat.random(in: 0...screenBounds.height),
            width: FloatingConfiguration.elementWidth,
            height: FloatingConfiguration.elementHeight
        )
    }

    private func executeFloatingAnimation(for tile: UIImageView) {
        guard isAnimating else { return }

        let duration = Double.random(
            in: FloatingConfiguration.minAnimationDuration...FloatingConfiguration.maxAnimationDuration
        )
        let xOffset = CGFloat.random(
            in: FloatingConfiguration.minXOffset...FloatingConfiguration.maxXOffset
        )
        let yOffset = CGFloat.random(
            in: FloatingConfiguration.minYOffset...FloatingConfiguration.maxYOffset
        )
        let rotation = CGFloat.random(
            in: FloatingConfiguration.minRotation...FloatingConfiguration.maxRotation
        )

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            tile.center = CGPoint(
                x: tile.center.x + xOffset,
                y: tile.center.y + yOffset
            )
            tile.transform = CGAffineTransform(rotationAngle: rotation)
        } completion: { [weak self] _ in
            self?.executeFloatingAnimation(for: tile)
        }
    }
}

// MARK: - Tile Selection Animation Handler

/// Handles tap animation for mode selection tiles
final class TileSelectionAnimationHandler {

    // MARK: - Configuration

    struct SelectionConfiguration {
        static let pressScale: CGFloat = 0.97
        static let pressAlpha: CGFloat = 0.9
        static let pressDuration: TimeInterval = 0.1
        static let releaseDuration: TimeInterval = 0.2
        static let releaseDamping: CGFloat = 0.5
        static let releaseVelocity: CGFloat = 0.5
    }

    // MARK: - Public Methods

    /// Execute selection animation with completion handler
    static func executeSelectionAnimation(
        on view: UIView,
        completion: @escaping () -> Void
    ) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Press animation
        UIView.animate(
            withDuration: SelectionConfiguration.pressDuration,
            animations: {
                view.transform = CGAffineTransform(
                    scaleX: SelectionConfiguration.pressScale,
                    y: SelectionConfiguration.pressScale
                )
                view.alpha = SelectionConfiguration.pressAlpha
            }
        ) { _ in
            // Release animation
            UIView.animate(
                withDuration: SelectionConfiguration.releaseDuration,
                delay: 0,
                usingSpringWithDamping: SelectionConfiguration.releaseDamping,
                initialSpringVelocity: SelectionConfiguration.releaseVelocity
            ) {
                view.transform = .identity
                view.alpha = 1.0
            } completion: { _ in
                completion()
            }
        }
    }
}

// MARK: - Arrow Pulse Animation Controller

/// Controls the arrow pulse animation on mode tiles
final class ArrowPulseAnimationController {

    // MARK: - Configuration

    struct PulseConfiguration {
        static let duration: TimeInterval = 1.0
        static let translationX: CGFloat = 5
    }

    // MARK: - Public Methods

    /// Start continuous arrow pulse animation
    static func startPulseAnimation(on imageView: UIImageView) {
        UIView.animate(
            withDuration: PulseConfiguration.duration,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            imageView.transform = CGAffineTransform(
                translationX: PulseConfiguration.translationX,
                y: 0
            )
        }
    }

    /// Stop arrow pulse animation
    static func stopPulseAnimation(on imageView: UIImageView) {
        imageView.layer.removeAllAnimations()
        imageView.transform = .identity
    }
}
