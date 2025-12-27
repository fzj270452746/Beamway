//
//  RulesAnimationController.swift
//  Beamway
//
//  Animation controllers for game rules screen
//  Handles entrance animations for header and content sections
//

import UIKit

// MARK: - Rules Entrance Animation Coordinator

/// Coordinates entrance animations for rules screen
final class RulesEntranceAnimationCoordinator {

    // MARK: - Animation Configuration

    struct AnimationConfiguration {
        static let headerDelay: TimeInterval = 0
        static let contentBaseDelay: TimeInterval = 0.1
        static let contentStaggerDelay: TimeInterval = 0.1

        static let headerDuration: TimeInterval = 0.4
        static let contentDuration: TimeInterval = 0.5

        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5

        static let headerTranslation: CGFloat = -20
        static let contentTranslation: CGFloat = 30
    }

    // MARK: - Properties

    private weak var headerSection: UIView?
    private var contentViews: [UIView] = []

    // MARK: - Public Methods

    /// Register views for entrance animation
    func registerViewsForAnimation(
        headerSection: UIView,
        contentViews: [UIView]
    ) {
        self.headerSection = headerSection
        self.contentViews = contentViews
    }

    /// Prepare views for entrance animation (set initial state)
    func prepareForEntranceAnimation() {
        prepareHeaderSection()
        prepareContentViews()
    }

    /// Execute the entrance animation sequence
    func executeEntranceAnimationSequence() {
        animateHeaderSection()
        animateContentViews()
    }

    // MARK: - Preparation Methods

    private func prepareHeaderSection() {
        headerSection?.alpha = 0
        headerSection?.transform = CGAffineTransform(
            translationX: 0,
            y: AnimationConfiguration.headerTranslation
        )
    }

    private func prepareContentViews() {
        for contentView in contentViews {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(
                translationX: 0,
                y: AnimationConfiguration.contentTranslation
            )
        }
    }

    // MARK: - Animation Methods

    private func animateHeaderSection() {
        UIView.animate(
            withDuration: AnimationConfiguration.headerDuration,
            delay: AnimationConfiguration.headerDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.headerSection?.alpha = 1
            self?.headerSection?.transform = .identity
        }
    }

    private func animateContentViews() {
        for (index, contentView) in contentViews.enumerated() {
            let delay = AnimationConfiguration.contentBaseDelay +
                (Double(index) * AnimationConfiguration.contentStaggerDelay)

            UIView.animate(
                withDuration: AnimationConfiguration.contentDuration,
                delay: delay,
                usingSpringWithDamping: AnimationConfiguration.springDamping,
                initialSpringVelocity: AnimationConfiguration.springVelocity
            ) {
                contentView.alpha = 1
                contentView.transform = .identity
            }
        }
    }
}

// MARK: - Card Expansion Animation Handler

/// Handles expand/collapse animations for rule cards
final class CardExpansionAnimationHandler {

    // MARK: - Configuration

    struct ExpansionConfiguration {
        static let expandDuration: TimeInterval = 0.3
        static let collapseDuration: TimeInterval = 0.25
        static let springDamping: CGFloat = 0.7
        static let springVelocity: CGFloat = 0.5
    }

    // MARK: - Public Methods

    /// Animate card expansion
    static func animateExpansion(
        card: UIView,
        contentView: UIView,
        isExpanded: Bool,
        completion: (() -> Void)? = nil
    ) {
        let duration = isExpanded ?
            ExpansionConfiguration.expandDuration :
            ExpansionConfiguration.collapseDuration

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: ExpansionConfiguration.springDamping,
            initialSpringVelocity: ExpansionConfiguration.springVelocity,
            options: .curveEaseInOut
        ) {
            contentView.alpha = isExpanded ? 1 : 0
            contentView.isHidden = !isExpanded
            card.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    /// Animate indicator rotation
    static func animateIndicatorRotation(
        indicator: UIImageView,
        isExpanded: Bool
    ) {
        UIView.animate(withDuration: 0.25) {
            let angle: CGFloat = isExpanded ? .pi / 2 : 0
            indicator.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}

// MARK: - Scroll Reveal Animation Controller

/// Controls reveal animations as user scrolls
final class ScrollRevealAnimationController {

    // MARK: - Configuration

    struct RevealConfiguration {
        static let revealThreshold: CGFloat = 50
        static let revealDuration: TimeInterval = 0.4
        static let initialOffset: CGFloat = 20
        static let initialAlpha: CGFloat = 0
    }

    // MARK: - Properties

    private var revealedViews: Set<Int> = []

    // MARK: - Public Methods

    /// Check and reveal views based on scroll position
    func checkAndRevealViews(
        in scrollView: UIScrollView,
        views: [UIView]
    ) {
        let scrollOffset = scrollView.contentOffset.y
        let visibleHeight = scrollView.bounds.height

        for (index, view) in views.enumerated() {
            guard !revealedViews.contains(index) else { continue }

            let viewFrame = view.frame
            let viewTop = viewFrame.origin.y

            if viewTop < scrollOffset + visibleHeight - RevealConfiguration.revealThreshold {
                revealView(view, at: index)
            }
        }
    }

    /// Prepare views for scroll reveal
    func prepareViewsForReveal(_ views: [UIView]) {
        for view in views {
            view.alpha = RevealConfiguration.initialAlpha
            view.transform = CGAffineTransform(
                translationX: 0,
                y: RevealConfiguration.initialOffset
            )
        }
    }

    /// Reset reveal state
    func resetRevealState() {
        revealedViews.removeAll()
    }

    // MARK: - Private Methods

    private func revealView(_ view: UIView, at index: Int) {
        revealedViews.insert(index)

        UIView.animate(
            withDuration: RevealConfiguration.revealDuration,
            delay: 0,
            options: .curveEaseOut
        ) {
            view.alpha = 1
            view.transform = .identity
        }
    }
}

// MARK: - Parallax Animation Controller

/// Controls parallax scrolling effects
final class ParallaxAnimationController {

    // MARK: - Configuration

    struct ParallaxConfiguration {
        static let headerParallaxFactor: CGFloat = 0.5
        static let backgroundParallaxFactor: CGFloat = 0.3
    }

    // MARK: - Public Methods

    /// Apply parallax effect to header based on scroll offset
    static func applyHeaderParallax(
        to headerView: UIView,
        scrollOffset: CGFloat
    ) {
        let parallaxOffset = scrollOffset * ParallaxConfiguration.headerParallaxFactor
        headerView.transform = CGAffineTransform(translationX: 0, y: parallaxOffset)
    }

    /// Apply parallax effect to background
    static func applyBackgroundParallax(
        to backgroundView: UIView,
        scrollOffset: CGFloat
    ) {
        let parallaxOffset = scrollOffset * ParallaxConfiguration.backgroundParallaxFactor
        backgroundView.transform = CGAffineTransform(translationX: 0, y: -parallaxOffset)
    }

    /// Reset all parallax transforms
    static func resetParallax(headerView: UIView, backgroundView: UIView) {
        headerView.transform = .identity
        backgroundView.transform = .identity
    }
}

// MARK: - Highlight Animation Handler

/// Handles highlight animations for interactive elements
final class HighlightAnimationHandler {

    // MARK: - Configuration

    struct HighlightConfiguration {
        static let highlightScale: CGFloat = 0.98
        static let highlightDuration: TimeInterval = 0.1
        static let returnDuration: TimeInterval = 0.15
    }

    // MARK: - Public Methods

    /// Apply highlight effect on touch
    static func applyHighlight(to view: UIView) {
        UIView.animate(withDuration: HighlightConfiguration.highlightDuration) {
            view.transform = CGAffineTransform(
                scaleX: HighlightConfiguration.highlightScale,
                y: HighlightConfiguration.highlightScale
            )
            view.alpha = 0.9
        }
    }

    /// Remove highlight effect
    static func removeHighlight(from view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: HighlightConfiguration.returnDuration,
            delay: 0,
            options: .curveEaseOut
        ) {
            view.transform = .identity
            view.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
}
