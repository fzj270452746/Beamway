//
//  CategoryPickerController.swift
//  Beamway
//
//  Main mode selection controller - Refactored for modularity
//  Coordinates between UI components, animations, and navigation
//

import UIKit

/// Main mode selection view controller
class CategoryPickerController: UIViewController {

    // MARK: - Subsystem Controllers

    /// Animation coordinator for entrance effects
    private lazy var animationCoordinator: ModeSelectionAnimationCoordinator = {
        ModeSelectionAnimationCoordinator()
    }()

    /// Floating elements controller
    private lazy var floatingElementsController: ModeSelectionFloatingElementsController = {
        ModeSelectionFloatingElementsController()
    }()

    // MARK: - UI Components

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView
    private let sparkEmissionStratum: CAEmitterLayer

    // Header Section
    private let topSectionPanel: UIView
    private let headingMarker: UILabel
    private let captionMarker: UILabel
    private let returnAction: UIButton

    // Mode Cards Container
    private let categoryTilesHolder: UIView
    private let soloModeTile: CategoryTilePanel
    private let competitiveModeTile: CategoryTilePanel

    // Explanation Section
    private let explanationHolder: UIView

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCategoryPickerLayout()
        executeEntranceAnimation()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Initialization

    init() {
        backdropPictureHolder = UIImageView()
        maskingPanel = UIView()
        sparkEmissionStratum = CAEmitterLayer()

        topSectionPanel = UIView()
        headingMarker = UILabel()
        captionMarker = UILabel()
        returnAction = UIButton(type: .system)

        categoryTilesHolder = UIView()
        soloModeTile = CategoryTilePanel(
            mode: .solo,
            title: "SINGLE",
            subtitle: "Classic Mode",
            description: "Control one tile and survive as long as possible",
            icon: "person.fill",
            primaryColor: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        )
        competitiveModeTile = CategoryTilePanel(
            mode: .competitive,
            title: "CHALLENGE",
            subtitle: "Expert Mode",
            description: "Control multiple tiles with increasing difficulty",
            icon: "bolt.fill",
            primaryColor: UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
        )

        explanationHolder = UIView()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        floatingElementsController.stopAnimations()
    }

    // MARK: - Setup Interface

    private func configureCategoryPickerLayout() {
        view.backgroundColor = .black

        configureBackdrop()
        configureSparkEffect()
        configureDriftingBlocks()
        configureTopSection()
        configureCategoryTiles()
        configureExplanationSection()
    }

    private func configureBackdrop() {
        let backdropConfigurator = ModeSelectionBackdropConfigurator(
            backdropPictureHolder: backdropPictureHolder,
            maskingPanel: maskingPanel
        )
        backdropConfigurator.configure(in: view)
    }

    private func configureSparkEffect() {
        let sparkConfigurator = ModeSelectionSparkEffectConfigurator(
            emitterLayer: sparkEmissionStratum
        )
        sparkConfigurator.configure(in: view)
    }

    private func configureDriftingBlocks() {
        floatingElementsController.setupFloatingElements(
            in: view,
            aboveView: maskingPanel
        )
        floatingElementsController.startAnimations()
    }

    private func configureTopSection() {
        let headerConfigurator = ModeSelectionHeaderConfigurator(
            topSectionPanel: topSectionPanel,
            headingMarker: headingMarker,
            captionMarker: captionMarker,
            returnAction: returnAction
        )
        headerConfigurator.configure(in: view)

        returnAction.addTarget(self, action: #selector(returnActionTouched), for: .touchUpInside)
    }

    private func configureCategoryTiles() {
        let tilesConfigurator = CategoryTilesConfigurator(
            categoryTilesHolder: categoryTilesHolder,
            soloModeTile: soloModeTile,
            competitiveModeTile: competitiveModeTile
        )
        tilesConfigurator.configure(in: view, belowView: topSectionPanel)

        // Setup tile callbacks
        soloModeTile.onTileTouched = { [weak self] in
            self?.initiateSession(mode: .solo)
        }
        competitiveModeTile.onTileTouched = { [weak self] in
            self?.initiateSession(mode: .competitive)
        }
    }

    private func configureExplanationSection() {
        let explanationConfigurator = ModeExplanationConfigurator(
            explanationHolder: explanationHolder
        )
        explanationConfigurator.configure(in: view, belowView: categoryTilesHolder)
    }

    // MARK: - Animations

    private func executeEntranceAnimation() {
        // Register views for animation
        animationCoordinator.registerViewsForAnimation(
            topSection: topSectionPanel,
            soloTile: soloModeTile,
            competitiveTile: competitiveModeTile,
            explanationSection: explanationHolder
        )

        // Prepare initial state
        animationCoordinator.prepareForEntranceAnimation()

        // Execute entrance sequence
        animationCoordinator.executeEntranceAnimationSequence()
    }

    // MARK: - Actions

    @objc private func returnActionTouched() {
        dismiss(animated: true)
    }

    private func initiateSession(mode: SessionCategory) {
        let sessionController = PlaySessionController(gameMode: mode)
        sessionController.modalPresentationStyle = .fullScreen
        sessionController.modalTransitionStyle = .crossDissolve
        present(sessionController, animated: true)
    }
}
