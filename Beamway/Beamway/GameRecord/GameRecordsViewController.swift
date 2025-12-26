//
//  GameRecordsViewController.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class GameRecordsViewController: UIViewController {
    
    private let backgroundImageView: UIImageView
    private let overlayView: UIView
    private let containerView: UIView
    private let titleLabel: UILabel
    private let tableView: UITableView
    private let backButton: CustomBackButton
    private let emptyStateLabel: UILabel
    
    private var gameRecords: [GameRecordModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecordsInterface()
        loadGameRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGameRecords()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        backgroundImageView = UIImageView()
        overlayView = UIView()
        containerView = UIView()
        titleLabel = UILabel()
        tableView = UITableView()
        backButton = CustomBackButton()
        emptyStateLabel = UILabel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRecordsInterface() {
        view.backgroundColor = .black
        
        // Setup background
        if let backgroundImage = UIImage(named: "benImage") {
            backgroundImageView.image = backgroundImage
        } else {
            backgroundImageView.backgroundColor = .darkGray
        }
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup overlay
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup container
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let spacing: CGFloat = 40
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacing),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing)
        ])
        
        // Setup back button
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        containerView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Setup title
        titleLabel.text = "Game Records"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Setup table view
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GameRecordTableViewCell.self, forCellReuseIdentifier: "GameRecordCell")
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Setup empty state label
        emptyStateLabel.text = "No game records yet.\nPlay a game to see your records here!"
        emptyStateLabel.textColor = .white
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        containerView.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadGameRecords() {
        gameRecords = GameRecordManager.sharedInstance.fetchAllGameRecords()
        tableView.reloadData()
        emptyStateLabel.isHidden = !gameRecords.isEmpty
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension GameRecordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameRecordCell", for: indexPath) as! GameRecordTableViewCell
        let record = gameRecords[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GameRecordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = gameRecords[indexPath.row]
            GameRecordManager.sharedInstance.deleteGameRecord(identifier: record.identifier)
            gameRecords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyStateLabel.isHidden = !gameRecords.isEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - GameRecordTableViewCell

class GameRecordTableViewCell: UITableViewCell {
    
    private let containerView: UIView
    private let scoreLabel: UILabel
    private let modeLabel: UILabel
    private let dateLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        containerView = UIView()
        scoreLabel = UILabel()
        modeLabel = UILabel()
        dateLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        // Reduce side margins to increase cell width
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Score label
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        containerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Mode label
        modeLabel.textColor = .white
        modeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        modeLabel.numberOfLines = 1
        modeLabel.lineBreakMode = .byTruncatingTail
        containerView.addSubview(modeLabel)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 16),
            modeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            modeLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
        
        // Date label
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.alpha = 0.8
        dateLabel.numberOfLines = 1
        dateLabel.lineBreakMode = .byTruncatingTail
        containerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with record: GameRecordModel) {
        scoreLabel.text = "Score: \(record.score)"
        modeLabel.text = "Mode: \(record.mode)"
        dateLabel.text = record.formattedDate
    }
}

