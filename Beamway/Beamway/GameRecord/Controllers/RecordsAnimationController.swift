//
//  RecordsAnimationController.swift
//  Beamway
//
//  Animation controllers for game records screen
//  Handles entrance animations for various UI elements
//

import UIKit

// MARK: - Records Animation Coordinator

/// Coordinates entrance animations for records screen
final class RecordsAnimationCoordinator {

    // MARK: - Animation Configuration

    struct AnimationConfiguration {
        static let topSectionDelay: TimeInterval = 0
        static let metricsDelay: TimeInterval = 0.1
        static let filterDelay: TimeInterval = 0.2
        static let tableDelay: TimeInterval = 0.3

        static let springDuration: TimeInterval = 0.4
        static let metricsDuration: TimeInterval = 0.5
        static let filterDuration: TimeInterval = 0.5
        static let tableDuration: TimeInterval = 0.4

        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5

        static let topSectionTranslation: CGFloat = -20
        static let filterTranslation: CGFloat = -30
        static let metricsScale: CGFloat = 0.95
    }

    // MARK: - Properties

    private weak var topSection: UIView?
    private weak var metricsPanel: UIView?
    private weak var filterHolder: UIView?
    private weak var tableView: UIView?

    // MARK: - Public Methods

    /// Register views for entrance animation
    func registerViewsForAnimation(
        topSection: UIView,
        metricsPanel: UIView,
        filterHolder: UIView,
        tableView: UIView
    ) {
        self.topSection = topSection
        self.metricsPanel = metricsPanel
        self.filterHolder = filterHolder
        self.tableView = tableView
    }

    /// Prepare views for entrance animation (set initial state)
    func prepareForEntranceAnimation() {
        prepareTopSection()
        prepareMetricsPanel()
        prepareFilterHolder()
        prepareTableView()
    }

    /// Execute the entrance animation sequence
    func executeEntranceAnimationSequence() {
        animateTopSection()
        animateMetricsPanel()
        animateFilterHolder()
        animateTableView()
    }

    // MARK: - Preparation Methods

    private func prepareTopSection() {
        topSection?.alpha = 0
        topSection?.transform = CGAffineTransform(
            translationX: 0,
            y: AnimationConfiguration.topSectionTranslation
        )
    }

    private func prepareMetricsPanel() {
        metricsPanel?.alpha = 0
        metricsPanel?.transform = CGAffineTransform(
            scaleX: AnimationConfiguration.metricsScale,
            y: AnimationConfiguration.metricsScale
        )
    }

    private func prepareFilterHolder() {
        filterHolder?.alpha = 0
        filterHolder?.transform = CGAffineTransform(
            translationX: AnimationConfiguration.filterTranslation,
            y: 0
        )
    }

    private func prepareTableView() {
        tableView?.alpha = 0
    }

    // MARK: - Animation Methods

    private func animateTopSection() {
        UIView.animate(
            withDuration: AnimationConfiguration.springDuration,
            delay: AnimationConfiguration.topSectionDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.topSection?.alpha = 1
            self?.topSection?.transform = .identity
        }
    }

    private func animateMetricsPanel() {
        UIView.animate(
            withDuration: AnimationConfiguration.metricsDuration,
            delay: AnimationConfiguration.metricsDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.metricsPanel?.alpha = 1
            self?.metricsPanel?.transform = .identity
        }
    }

    private func animateFilterHolder() {
        UIView.animate(
            withDuration: AnimationConfiguration.filterDuration,
            delay: AnimationConfiguration.filterDelay,
            usingSpringWithDamping: AnimationConfiguration.springDamping,
            initialSpringVelocity: AnimationConfiguration.springVelocity
        ) { [weak self] in
            self?.filterHolder?.alpha = 1
            self?.filterHolder?.transform = .identity
        }
    }

    private func animateTableView() {
        UIView.animate(
            withDuration: AnimationConfiguration.tableDuration,
            delay: AnimationConfiguration.tableDelay
        ) { [weak self] in
            self?.tableView?.alpha = 1
        }
    }
}

// MARK: - Cell Animation Coordinator

/// Coordinates animations for table view cells
final class RecordsCellAnimationCoordinator {

    // MARK: - Animation Configuration

    struct CellAnimationConfiguration {
        static let appearanceDuration: TimeInterval = 0.3
        static let appearanceScale: CGFloat = 0.95
        static let staggerDelay: TimeInterval = 0.05
    }

    // MARK: - Public Methods

    /// Animate cell appearance with stagger effect
    static func animateCellAppearance(
        cell: UITableViewCell,
        indexPath: IndexPath,
        tableView: UITableView
    ) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(
            scaleX: CellAnimationConfiguration.appearanceScale,
            y: CellAnimationConfiguration.appearanceScale
        )

        let delay = CellAnimationConfiguration.staggerDelay * Double(indexPath.row)

        UIView.animate(
            withDuration: CellAnimationConfiguration.appearanceDuration,
            delay: delay,
            options: .curveEaseOut
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    /// Animate cell deletion
    static func animateCellDeletion(
        cell: UITableViewCell,
        completion: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                cell.alpha = 0
                cell.transform = CGAffineTransform(
                    translationX: -cell.bounds.width,
                    y: 0
                )
            }
        ) { _ in
            completion()
        }
    }
}

// MARK: - Metrics Update Animation

/// Handles animations for metrics value updates
final class MetricsUpdateAnimator {

    // MARK: - Configuration

    struct UpdateConfiguration {
        static let scaleDuration: TimeInterval = 0.15
        static let scaleUp: CGFloat = 1.15
        static let returnDuration: TimeInterval = 0.2
    }

    // MARK: - Public Methods

    /// Animate value change with scale bounce effect
    static func animateValueUpdate(label: UILabel, newValue: String) {
        UIView.animate(
            withDuration: UpdateConfiguration.scaleDuration,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                label.transform = CGAffineTransform(
                    scaleX: UpdateConfiguration.scaleUp,
                    y: UpdateConfiguration.scaleUp
                )
            }
        ) { _ in
            label.text = newValue

            UIView.animate(
                withDuration: UpdateConfiguration.returnDuration,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.5
            ) {
                label.transform = .identity
            }
        }
    }

    /// Animate counter increment
    static func animateCounterIncrement(
        label: UILabel,
        from startValue: Int,
        to endValue: Int,
        duration: TimeInterval = 0.5
    ) {
        let steps = min(abs(endValue - startValue), 20)
        guard steps > 0 else {
            label.text = "\(endValue)"
            return
        }

        let stepDuration = duration / Double(steps)
        let increment = (endValue - startValue) / steps

        for i in 0...steps {
            let value = startValue + (increment * i)
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                label.text = "\(value)"
            }
        }
    }
}

// MARK: - Delete Confirmation Animation

/// Handles animations for delete confirmation
final class DeleteConfirmationAnimator {

    // MARK: - Configuration

    struct ConfirmationConfiguration {
        static let shakeDuration: TimeInterval = 0.05
        static let shakeRepetitions: Int = 3
        static let shakeOffset: CGFloat = 5
    }

    // MARK: - Public Methods

    /// Shake animation for delete button feedback
    static func animateDeleteButtonShake(_ button: UIButton) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = ConfirmationConfiguration.shakeDuration * Double(ConfirmationConfiguration.shakeRepetitions * 2)
        animation.values = [
            -ConfirmationConfiguration.shakeOffset,
            ConfirmationConfiguration.shakeOffset,
            -ConfirmationConfiguration.shakeOffset,
            ConfirmationConfiguration.shakeOffset,
            -ConfirmationConfiguration.shakeOffset / 2,
            ConfirmationConfiguration.shakeOffset / 2,
            0
        ]

        button.layer.add(animation, forKey: "shake")
    }
}

// MARK: - Filter Switch Animation

/// Handles animations for filter button transitions
final class FilterSwitchAnimator {

    // MARK: - Configuration

    struct SwitchConfiguration {
        static let transitionDuration: TimeInterval = 0.25
        static let backgroundAnimationDuration: TimeInterval = 0.2
    }

    // MARK: - Public Methods

    /// Animate filter button selection change
    static func animateFilterSelection(
        selectedButton: UIButton,
        deselectedButtons: [UIButton],
        selectedColor: UIColor
    ) {
        // Animate selected button
        UIView.animate(withDuration: SwitchConfiguration.backgroundAnimationDuration) {
            selectedButton.backgroundColor = selectedColor
            selectedButton.setTitleColor(.white, for: .normal)
        }

        // Animate deselected buttons
        for button in deselectedButtons {
            UIView.animate(withDuration: SwitchConfiguration.backgroundAnimationDuration) {
                button.backgroundColor = .clear
                button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            }
        }
    }

    /// Add bounce effect to selected filter
    static func addBounceEffect(to button: UIButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5
            ) {
                button.transform = .identity
            }
        }
    }
}
