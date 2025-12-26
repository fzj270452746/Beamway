//
//  GameModeSelectionViewController.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class GameModeSelectionViewController: UIViewController {
    
    private let backgroundImageView: UIImageView
    private let overlayView: UIView
    private let containerView: UIView
    private let singleModeButton: UIButton
    private let challengeModeButton: UIButton
    private let backButton: CustomBackButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModeSelectionInterface()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        backgroundImageView = UIImageView()
        overlayView = UIView()
        containerView = UIView()
        singleModeButton = UIButton(type: .system)
        challengeModeButton = UIButton(type: .system)
        backButton = CustomBackButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupModeSelectionInterface() {
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
        
        // Setup mode buttons
        setupSingleModeButton()
        setupChallengeModeButton()
        
        let buttonStackView = UIStackView(arrangedSubviews: [singleModeButton, challengeModeButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 30
        buttonStackView.distribution = .fillEqually
        containerView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.75),
            buttonStackView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func setupSingleModeButton() {
        singleModeButton.setTitle("Single Mode", for: .normal)
        singleModeButton.setTitleColor(.white, for: .normal)
        singleModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        // Use a vibrant orange/amber color
        singleModeButton.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.85)
        singleModeButton.layer.cornerRadius = 15
        singleModeButton.layer.borderWidth = 2.5
        singleModeButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9).cgColor
        singleModeButton.addTarget(self, action: #selector(singleModeButtonTapped), for: .touchUpInside)
        
        // Add enhanced shadow and glow effect
        singleModeButton.layer.shadowColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.6).cgColor
        singleModeButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        singleModeButton.layer.shadowRadius = 12
        singleModeButton.layer.shadowOpacity = 0.8
    }
    
    private func setupChallengeModeButton() {
        challengeModeButton.setTitle("Challenge Mode", for: .normal)
        challengeModeButton.setTitleColor(.white, for: .normal)
        challengeModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        // Use a vibrant crimson/red color
        challengeModeButton.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 0.85)
        challengeModeButton.layer.cornerRadius = 15
        challengeModeButton.layer.borderWidth = 2.5
        challengeModeButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9).cgColor
        challengeModeButton.addTarget(self, action: #selector(challengeModeButtonTapped), for: .touchUpInside)
        
        // Add enhanced shadow and glow effect
        challengeModeButton.layer.shadowColor = UIColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 0.6).cgColor
        challengeModeButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        challengeModeButton.layer.shadowRadius = 12
        challengeModeButton.layer.shadowOpacity = 0.8
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func singleModeButtonTapped() {
        let gameViewController = MainGameViewController(gameMode: .single)
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true)
    }
    
    @objc private func challengeModeButtonTapped() {
        let gameViewController = MainGameViewController(gameMode: .challenge)
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true)
    }
}

