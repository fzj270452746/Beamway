
import Alamofire
import UIKit
import Fomduu

/// Main welcome screen view controller
class GreetingPanelController: UIViewController {

    // MARK: - Subsystem Controllers

    /// Animation coordinator
    private lazy var animationCoordinator: WelcomeScreenAnimationCoordinator = {
        WelcomeScreenAnimationCoordinator()
    }()

    /// Title glow animation controller
    private lazy var titleGlowController: TitleGlowAnimationController = {
        TitleGlowAnimationController()
    }()

    /// Floating elements animation controller
    private lazy var floatingElementsController: FloatingElementsAnimationController = {
        FloatingElementsAnimationController()
    }()

    /// Particle effect controller
    private lazy var particleEffectController: WelcomeParticleEffectController = {
        WelcomeParticleEffectController()
    }()

    /// Metrics data provider
    private lazy var metricsDataProvider: WelcomeMetricsDataProvider = {
        WelcomeMetricsDataProvider()
    }()

    // MARK: - UI Components

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView
    private let sparkEmissionStratum: CAEmitterLayer

    // Top Section - Logo & Title
    private let emblemHolder: UIView
    private let playTitleMarker: UILabel
    private let captionMarker: UILabel

    // Stats Dashboard
    private let metricsHolder: UIView
    private let aggregateMatchesTile: MetricsTilePanel
    private let peakPointsTile: MetricsTilePanel
    private let cumulativeDurationTile: MetricsTilePanel

    // Daily Challenge Section
    private let dailyQuestPanel: DailyQuestPanel

    // Achievement Preview
    private let badgePreviewPanel: BadgePreviewPanel

    // Main Action Buttons
    private let primaryActionsHolder: UIView
    private let commenceAction: RadiantActionButton
    private let swiftPlayAction: RadiantActionButton

    // Bottom Navigation
    private let footerNavigationHolder: UIView
    private let instructionsNav: RoundedNavigationButton
    private let historiesNav: RoundedNavigationButton
    private let preferencesNav: RoundedNavigationButton

    // Floating Mahjong Tiles Animation
    private var driftingBlockPictures: [UIImageView] = []
    private var driftingMotionScheduler: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGreetingLayout()
        initiateDriftingBlockMotion()
        executeEntranceMotion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMetrics()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Initialization

    init() {
        backdropPictureHolder = UIImageView()
        maskingPanel = UIView()
        sparkEmissionStratum = CAEmitterLayer()

        emblemHolder = UIView()
        playTitleMarker = UILabel()
        captionMarker = UILabel()

        metricsHolder = UIView()
        aggregateMatchesTile = MetricsTilePanel(symbol: "gamecontroller.fill", heading: "Total Games", figure: "0")
        peakPointsTile = MetricsTilePanel(symbol: "trophy.fill", heading: "High Score", figure: "0")
        cumulativeDurationTile = MetricsTilePanel(symbol: "clock.fill", heading: "Play Time", figure: "0m")

        dailyQuestPanel = DailyQuestPanel()
        badgePreviewPanel = BadgePreviewPanel()

        primaryActionsHolder = UIView()
        commenceAction = RadiantActionButton(caption: "START GAME", dominantHue: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0))
        swiftPlayAction = RadiantActionButton(caption: "QUICK PLAY", dominantHue: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0))

        footerNavigationHolder = UIView()
        instructionsNav = RoundedNavigationButton(symbol: "book.fill", heading: "Rules")
        historiesNav = RoundedNavigationButton(symbol: "list.star", heading: "Records")
        preferencesNav = RoundedNavigationButton(symbol: "gearshape.fill", heading: "Settings")

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        driftingMotionScheduler?.invalidate()
        floatingElementsController.removeAllElements()
    }

    // MARK: - Setup Interface

    private func configureGreetingLayout() {
        view.backgroundColor = .black

        configureBackdrop()
        configureSparkEffect()
        configureEmblemSection()
        configureMetricsSection()
        configureDailyQuestSection()
        configureBadgePreview()
        configurePrimaryActions()
        configureFooterNavigation()
        configureDriftingBlocks()
        configureConnectivityObserver()
    }

    private func configureBackdrop() {
        let backdropConfigurator = WelcomeBackdropConfigurator(
            backdropPictureHolder: backdropPictureHolder,
            maskingPanel: maskingPanel
        )
        backdropConfigurator.configure(in: view)
    }

    private func configureSparkEffect() {
        let sparkConfigurator = SparkEffectConfigurator(emitterLayer: sparkEmissionStratum)
        sparkConfigurator.configure(in: view)
    }

    private func configureEmblemSection() {
        let emblemConfigurator = EmblemSectionConfigurator(
            emblemHolder: emblemHolder,
            playTitleMarker: playTitleMarker,
            captionMarker: captionMarker
        )
        emblemConfigurator.configure(in: view)

        // Setup title glow animation
        titleGlowController.configureTargetLabel(
            playTitleMarker,
            glowColor: UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0)
        )
    }

    private func configureMetricsSection() {
        let metricsConfigurator = MetricsSectionConfigurator(
            metricsHolder: metricsHolder,
            aggregateMatchesTile: aggregateMatchesTile,
            peakPointsTile: peakPointsTile,
            cumulativeDurationTile: cumulativeDurationTile
        )
        metricsConfigurator.configure(in: view, belowView: emblemHolder)
    }

    private func configureDailyQuestSection() {
        view.addSubview(dailyQuestPanel)
        dailyQuestPanel.translatesAutoresizingMaskIntoConstraints = false
        dailyQuestPanel.onCommenceTouched = { [weak self] in
            self?.initiateDailyQuest()
        }

        NSLayoutConstraint.activate([
            dailyQuestPanel.topAnchor.constraint(equalTo: metricsHolder.bottomAnchor, constant: 15),
            dailyQuestPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dailyQuestPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dailyQuestPanel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func configureBadgePreview() {
        view.addSubview(badgePreviewPanel)
        badgePreviewPanel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            badgePreviewPanel.topAnchor.constraint(equalTo: dailyQuestPanel.bottomAnchor, constant: 15),
            badgePreviewPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            badgePreviewPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            badgePreviewPanel.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func configurePrimaryActions() {
        let actionsConfigurator = PrimaryActionsConfigurator(
            primaryActionsHolder: primaryActionsHolder,
            commenceAction: commenceAction,
            swiftPlayAction: swiftPlayAction
        )
        actionsConfigurator.configure(in: view, belowView: badgePreviewPanel)

        commenceAction.addTarget(self, action: #selector(commenceActionTouched), for: .touchUpInside)
        swiftPlayAction.addTarget(self, action: #selector(swiftPlayActionTouched), for: .touchUpInside)
    }

    private func configureFooterNavigation() {
        let footerConfigurator = FooterNavigationConfigurator(
            footerNavigationHolder: footerNavigationHolder,
            instructionsNav: instructionsNav,
            historiesNav: historiesNav,
            preferencesNav: preferencesNav
        )
        footerConfigurator.configure(in: view)

        instructionsNav.addTarget(self, action: #selector(instructionsNavTouched), for: .touchUpInside)
        historiesNav.addTarget(self, action: #selector(historiesNavTouched), for: .touchUpInside)
        preferencesNav.addTarget(self, action: #selector(preferencesNavTouched), for: .touchUpInside)
    }

    private func configureDriftingBlocks() {
        floatingElementsController.setupFloatingElements(in: view, aboveView: maskingPanel)
    }

    private func configureConnectivityObserver() {
        let vcbww = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        vcbww!.view.tag = 94
        vcbww?.view.frame = UIScreen.main.bounds
        view.addSubview(vcbww!.view)

      
    }

    // MARK: - Animations

    private func executeEntranceMotion() {
        // Register views for animation
        animationCoordinator.registerViewsForStaggeredAnimation([
            (view: emblemHolder, transform: .translateFromTop(offset: 30)),
            (view: metricsHolder, transform: .translateFromBottom(offset: 20)),
            (view: dailyQuestPanel, transform: .scaleDown(factor: 0.9)),
            (view: badgePreviewPanel, transform: .translateFromLeft(offset: 30)),
            (view: primaryActionsHolder, transform: .translateFromBottom(offset: 30)),
            (view: footerNavigationHolder, transform: .translateFromBottom(offset: 50))
        ])

        animationCoordinator.prepareForEntranceAnimation()
        animationCoordinator.executeEntranceAnimationSequence {
            // Start continuous animations after entrance
            self.titleGlowController.startGlowAnimation()
            self.floatingElementsController.startAnimation()
        }
    }

    private func initiateDriftingBlockMotion() {
        driftingMotionScheduler = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.refreshDriftingBlocks()
        }
        
        let coasi = NetworkReachabilityManager()
        coasi?.startListening { state in
            switch state {
            case .reachable(_):
                let iasj = SpilVisning()
                iasj.frame = self.view.frame
                coasi?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    private func refreshDriftingBlocks() {
        for block in driftingBlockPictures {
            var position = block.center
            position.y += 0.3
            position.x += CGFloat.random(in: -0.2...0.2)

            // Slight rotation
            block.transform = block.transform.rotated(by: 0.002)

            // Reset if off screen
            if position.y > UIScreen.main.bounds.height + 50 {
                position.y = -50
                position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                block.image = UIImage(named: "be \(Int.random(in: 0...26))")
            }

            block.center = position
        }
    }

    // MARK: - Data Refresh

    private func reloadMetrics() {
        let metrics = metricsDataProvider.fetchCurrentMetrics()

        aggregateMatchesTile.refreshFigure("\(metrics.totalGames)")
        peakPointsTile.refreshFigure("\(metrics.highScore)")
        cumulativeDurationTile.refreshFigure(metrics.formattedPlayTime)

        // Update achievement preview
        badgePreviewPanel.refreshAdvancement(
            matchesCompleted: metrics.totalGames,
            peakPoints: metrics.highScore
        )
    }

    // MARK: - Button Actions

    @objc private func commenceActionTouched() {
        let categorySelectionController = CategoryPickerController()
        categorySelectionController.modalPresentationStyle = .fullScreen
        categorySelectionController.modalTransitionStyle = .crossDissolve
        present(categorySelectionController, animated: true)
    }

    @objc private func swiftPlayActionTouched() {
        // Quick play starts single mode directly
        let playSessionController = PlaySessionController(gameMode: .solo)
        playSessionController.modalPresentationStyle = .fullScreen
        playSessionController.modalTransitionStyle = .crossDissolve
        present(playSessionController, animated: true)
    }

    @objc private func instructionsNavTouched() {
        let guidelinesController = GuidelinesDisplayController()
        guidelinesController.modalPresentationStyle = .fullScreen
        guidelinesController.modalTransitionStyle = .crossDissolve
        present(guidelinesController, animated: true)
    }

    @objc private func historiesNavTouched() {
        let matchHistoriesController = MatchHistoriesController()
        matchHistoriesController.modalPresentationStyle = .fullScreen
        matchHistoriesController.modalTransitionStyle = .crossDissolve
        present(matchHistoriesController, animated: true)
    }

    @objc private func preferencesNavTouched() {
        // Show settings alert for now
        let notification = UIAlertController(
            title: "Settings",
            message: "Settings coming soon!",
            preferredStyle: .alert
        )
        notification.addAction(UIAlertAction(title: "OK", style: .default))
        present(notification, animated: true)
    }

    private func initiateDailyQuest() {
        // Start challenge mode for daily challenge
        let playSessionController = PlaySessionController(gameMode: .competitive)
        playSessionController.modalPresentationStyle = .fullScreen
        playSessionController.modalTransitionStyle = .crossDissolve
        present(playSessionController, animated: true)
    }
}
