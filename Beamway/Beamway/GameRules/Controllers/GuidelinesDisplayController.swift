//
//  GuidelinesDisplayController.swift
//  Beamway
//
//  Main game rules controller - Refactored for modularity
//  Coordinates between UI components, content, and animations
//

import UIKit

/// Main game rules view controller
class GuidelinesDisplayController: UIViewController {

    // MARK: - Subsystem Controllers

    /// Animation coordinator for entrance effects
    private lazy var animationCoordinator: RulesEntranceAnimationCoordinator = {
        RulesEntranceAnimationCoordinator()
    }()

    /// Content builder for rules sections
    private lazy var contentBuilder: GuidelinesContentBuilder = {
        GuidelinesContentBuilder()
    }()

    // MARK: - UI Components

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView
    private let topSectionPanel: UIView
    private let returnAction: UIButton
    private let headingMarker: UILabel
    private let scrollableArea: UIScrollView
    private let contentArrangement: UIStackView

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGuidelinesLayout()
        executeEntranceAnimation()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Initialization

    init() {
        backdropPictureHolder = UIImageView()
        maskingPanel = UIView()
        topSectionPanel = UIView()
        returnAction = UIButton(type: .system)
        headingMarker = UILabel()
        scrollableArea = UIScrollView()
        contentArrangement = UIStackView()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Interface

    private func configureGuidelinesLayout() {
        view.backgroundColor = .black

        configureBackdrop()
        configureTopSection()
        configureScrollableArea()
        configureGuidelinesContent()
    }

    private func configureBackdrop() {
        let backdropConfigurator = RulesBackdropConfigurator(
            backdropPictureHolder: backdropPictureHolder,
            maskingPanel: maskingPanel
        )
        backdropConfigurator.configure(in: view)
    }

    private func configureTopSection() {
        let headerConfigurator = RulesHeaderConfigurator(
            topSectionPanel: topSectionPanel,
            returnAction: returnAction,
            headingMarker: headingMarker
        )
        headerConfigurator.configure(in: view)

        returnAction.addTarget(self, action: #selector(returnActionTouched), for: .touchUpInside)
    }

    private func configureScrollableArea() {
        let scrollConfigurator = RulesScrollAreaConfigurator(
            scrollableArea: scrollableArea,
            contentArrangement: contentArrangement
        )
        scrollConfigurator.configure(in: view, belowView: topSectionPanel)
    }

    private func configureGuidelinesContent() {
        // Build all content sections using content builder
        let contentSections = contentBuilder.buildAllSections()

        for section in contentSections {
            contentArrangement.addArrangedSubview(section)
        }
    }

    // MARK: - Animations

    private func executeEntranceAnimation() {
        animationCoordinator.registerViewsForAnimation(
            headerSection: topSectionPanel,
            contentViews: contentArrangement.arrangedSubviews
        )

        animationCoordinator.prepareForEntranceAnimation()
        animationCoordinator.executeEntranceAnimationSequence()
    }

    // MARK: - Actions

    @objc private func returnActionTouched() {
        dismiss(animated: true)
    }
}
