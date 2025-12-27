//
//  MatchHistoriesController.swift
//  Beamway
//
//  Main game records controller - Refactored for modularity
//  Coordinates between UI components, data management, and filtering
//

import UIKit

/// Main game records view controller
class MatchHistoriesController: UIViewController {

    // MARK: - Subsystem Controllers

    /// Animation coordinator for entrance effects
    private lazy var animationCoordinator: RecordsAnimationCoordinator = {
        RecordsAnimationCoordinator()
    }()

    /// Data manager for records handling
    private lazy var dataManager: RecordsDataManager = {
        RecordsDataManager()
    }()

    // MARK: - UI Components

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView
    private let topSectionPanel: UIView
    private let returnAction: UIButton
    private let headingMarker: UILabel
    private let purgeAction: UIButton

    // Stats Summary
    private let metricsSummaryPanel: UIView

    // Segmented Control for filtering
    private let categoryFilterHolder: UIView
    private let entireAction: UIButton
    private let soloAction: UIButton
    private let competitiveAction: UIButton

    // Records Table
    private let historyList: UITableView
    private let vacantStatePanel: UIView
    private let vacantSymbol: UIImageView
    private let vacantMarker: UILabel

    // MARK: - State

    private var activeCategoryFilter: String = "All"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHistoriesLayout()
        retrieveHistories()
        executeEntranceAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveHistories()
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
        purgeAction = UIButton(type: .system)

        metricsSummaryPanel = UIView()

        categoryFilterHolder = UIView()
        entireAction = UIButton(type: .system)
        soloAction = UIButton(type: .system)
        competitiveAction = UIButton(type: .system)

        historyList = UITableView(frame: .zero, style: .plain)
        vacantStatePanel = UIView()
        vacantSymbol = UIImageView()
        vacantMarker = UILabel()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Interface

    private func configureHistoriesLayout() {
        view.backgroundColor = .black

        configureBackdrop()
        configureTopSection()
        configureMetricsSummary()
        configureCategoryFilters()
        configureHistoryList()
        configureVacantState()
    }

    private func configureBackdrop() {
        let backdropConfigurator = RecordsBackdropConfigurator(
            backdropPictureHolder: backdropPictureHolder,
            maskingPanel: maskingPanel
        )
        backdropConfigurator.configure(in: view)
    }

    private func configureTopSection() {
        let headerConfigurator = RecordsHeaderConfigurator(
            topSectionPanel: topSectionPanel,
            returnAction: returnAction,
            headingMarker: headingMarker,
            purgeAction: purgeAction
        )
        headerConfigurator.configure(in: view)

        returnAction.addTarget(self, action: #selector(returnActionTouched), for: .touchUpInside)
        purgeAction.addTarget(self, action: #selector(purgeAllTouched), for: .touchUpInside)
    }

    private func configureMetricsSummary() {
        let metricsConfigurator = RecordsMetricsSummaryConfigurator(
            metricsSummaryPanel: metricsSummaryPanel
        )
        metricsConfigurator.configure(in: view, belowView: topSectionPanel)
    }

    private func configureCategoryFilters() {
        let filterConfigurator = RecordsCategoryFilterConfigurator(
            categoryFilterHolder: categoryFilterHolder,
            entireAction: entireAction,
            soloAction: soloAction,
            competitiveAction: competitiveAction
        )
        filterConfigurator.configure(in: view, belowView: metricsSummaryPanel)

        entireAction.addTarget(self, action: #selector(categoryFilterTouched(_:)), for: .touchUpInside)
        soloAction.addTarget(self, action: #selector(categoryFilterTouched(_:)), for: .touchUpInside)
        competitiveAction.addTarget(self, action: #selector(categoryFilterTouched(_:)), for: .touchUpInside)
    }

    private func configureHistoryList() {
        let tableConfigurator = RecordsTableConfigurator(
            historyList: historyList
        )
        tableConfigurator.configure(in: view, belowView: categoryFilterHolder)

        historyList.delegate = self
        historyList.dataSource = self
        historyList.register(MatchHistoryItem.self, forCellReuseIdentifier: MatchHistoryItem.reuseIdentifier)
    }

    private func configureVacantState() {
        let vacantConfigurator = RecordsVacantStateConfigurator(
            vacantStatePanel: vacantStatePanel,
            vacantSymbol: vacantSymbol,
            vacantMarker: vacantMarker
        )
        vacantConfigurator.configure(in: view, centeredIn: historyList)
    }

    // MARK: - Data Loading

    private func retrieveHistories() {
        dataManager.loadAllHistories()
        executeCategoryFilter()
        refreshMetricsDisplay()
    }

    private func executeCategoryFilter() {
        dataManager.applyFilter(activeCategoryFilter)
        historyList.reloadData()
        vacantStatePanel.isHidden = !dataManager.filteredHistories.isEmpty
    }

    private func refreshMetricsDisplay() {
        let metrics = dataManager.calculateMetrics()

        // Update stat labels using tags
        if let gamesLabel = metricsSummaryPanel.viewWithTag(RecordsMetricsSummaryConfigurator.MetricsTags.totalGames) as? UILabel {
            gamesLabel.text = "\(metrics.totalGames)"
        }
        if let scoreLabel = metricsSummaryPanel.viewWithTag(RecordsMetricsSummaryConfigurator.MetricsTags.highScore) as? UILabel {
            scoreLabel.text = "\(metrics.highScore)"
        }
        if let timeLabel = metricsSummaryPanel.viewWithTag(RecordsMetricsSummaryConfigurator.MetricsTags.bestTime) as? UILabel {
            timeLabel.text = metrics.formattedBestTime
        }
    }

    // MARK: - Animations

    private func executeEntranceAnimation() {
        animationCoordinator.registerViewsForAnimation(
            topSection: topSectionPanel,
            metricsPanel: metricsSummaryPanel,
            filterHolder: categoryFilterHolder,
            tableView: historyList
        )

        animationCoordinator.prepareForEntranceAnimation()
        animationCoordinator.executeEntranceAnimationSequence()
    }

    // MARK: - Category Filter Updates

    private func refreshCategoryButtonStates() {
        let filterUpdater = CategoryFilterStateUpdater(
            entireAction: entireAction,
            soloAction: soloAction,
            competitiveAction: competitiveAction
        )
        filterUpdater.updateStates(selectedFilter: activeCategoryFilter)
    }

    // MARK: - Actions

    @objc private func returnActionTouched() {
        dismiss(animated: true)
    }

    @objc private func purgeAllTouched() {
        guard !dataManager.allHistories.isEmpty else { return }

        let alertPresenter = RecordsAlertPresenter()
        alertPresenter.presentClearAllConfirmation(from: self) { [weak self] in
            MatchHistoryHandler.globalHandler.removeAllMatchHistories()
            self?.retrieveHistories()
        }
    }

    @objc private func categoryFilterTouched(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        activeCategoryFilter = title
        refreshCategoryButtonStates()
        executeCategoryFilter()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MatchHistoriesController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.filteredHistories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MatchHistoryItem.reuseIdentifier,
            for: indexPath
        ) as! MatchHistoryItem

        let record = dataManager.filteredHistories[indexPath.row]
        cell.populateWith(record: record, rank: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MatchHistoryItem.preferredHeight
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            let record = self.dataManager.filteredHistories[indexPath.row]
            MatchHistoryHandler.globalHandler.removeMatchHistory(uniqueId: record.uniqueId)
            self.retrieveHistories()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = UIColor.systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
