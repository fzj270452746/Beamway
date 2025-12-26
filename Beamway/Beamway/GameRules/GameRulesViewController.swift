//
//  GameRulesViewController.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class GameRulesViewController: UIViewController {
    
    private let backgroundImageView: UIImageView
    private let overlayView: UIView
    private let containerView: UIView
    private let scrollView: UIScrollView
    private let contentView: UIView
    private let titleLabel: UILabel
    private let rulesTextView: UITextView
    private let backButton: CustomBackButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRulesInterface()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        backgroundImageView = UIImageView()
        overlayView = UIView()
        containerView = UIView()
        scrollView = UIScrollView()
        contentView = UIView()
        titleLabel = UILabel()
        rulesTextView = UITextView()
        backButton = CustomBackButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRulesInterface() {
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
        
        // Setup scroll view
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = true
        containerView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Setup content view
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Setup title
        titleLabel.text = "Game Rules"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // Setup rules text
        rulesTextView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        rulesTextView.textColor = .white
        rulesTextView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        rulesTextView.isEditable = false
        rulesTextView.isScrollEnabled = false
        rulesTextView.layer.cornerRadius = 15
        rulesTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let rulesText = """
        HOW TO PLAY:
        
        1. Move the mahjong tiles to avoid arrows shooting from all four sides of the screen.
        
        2. Each arrow you successfully dodge gives you 1 point.
        
        3. You have 3 lives per level. If you get hit by an arrow, you lose one life.
        
        4. Game Modes:
           • Single Mode: Control one mahjong tile to dodge arrows.
           • Challenge Mode: Start with one tile, and the number of tiles increases with each level (Level 1: 1 tile, Level 2: 2 tiles, and so on).
        
        5. The game ends when you lose all your lives.
        
        6. Your score and game mode will be saved in the game records.
        
        TIPS:
        • Move quickly but carefully
        • Watch all four sides of the screen
        • Practice makes perfect!
        """
        
        rulesTextView.text = rulesText
        contentView.addSubview(rulesTextView)
        rulesTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rulesTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            rulesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rulesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rulesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
}

