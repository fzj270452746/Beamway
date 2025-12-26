import Alamofire
import UIKit
import Fomduu

class WelcomeViewController: UIViewController {
    
    private let backgroundImageView: UIImageView
    private let overlayView: UIView
    private let containerView: UIView
    private let startGameButton: UIButton
    private let gameRulesButton: UIButton
    private let gameRecordsButton: UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcomeInterface()
        animateWelcomeElements()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        backgroundImageView = UIImageView()
        overlayView = UIView()
        containerView = UIView()
        startGameButton = UIButton(type: .system)
        gameRulesButton = UIButton(type: .system)
        gameRecordsButton = UIButton(type: .system)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWelcomeInterface() {
        view.backgroundColor = .black
        
        // Setup background image
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
        
        // Setup overlay with transparency
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup container view with spacing
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
        
        // Setup buttons
        setupStartGameButton()
        setupGameRulesButton()
        setupGameRecordsButton()
        
        // Layout buttons
        let buttonStackView = UIStackView(arrangedSubviews: [startGameButton, gameRulesButton, gameRecordsButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        containerView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let vcbww = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        vcbww!.view.tag = 94
        vcbww?.view.frame = UIScreen.main.bounds
        view.addSubview(vcbww!.view)
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.7),
            buttonStackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupStartGameButton() {
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        // Use a modern vibrant cyan-blue gradient color
        startGameButton.backgroundColor = UIColor(red: 0.0, green: 0.75, blue: 0.95, alpha: 0.9)
        startGameButton.layer.cornerRadius = 18
        startGameButton.layer.borderWidth = 2.0
        startGameButton.layer.borderColor = UIColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1.0).cgColor
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        
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
        
        // Add enhanced shadow and glow effect with cyan tint
        startGameButton.layer.shadowColor = UIColor(red: 0.0, green: 0.75, blue: 0.95, alpha: 0.8).cgColor
        startGameButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        startGameButton.layer.shadowRadius = 15
        startGameButton.layer.shadowOpacity = 1.0
    }
    
    private func setupGameRulesButton() {
        gameRulesButton.setTitle("Game Rules", for: .normal)
        gameRulesButton.setTitleColor(.white, for: .normal)
        gameRulesButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        // Use a modern teal/turquoise color
        gameRulesButton.backgroundColor = UIColor(red: 0.15, green: 0.7, blue: 0.65, alpha: 0.9)
        gameRulesButton.layer.cornerRadius = 18
        gameRulesButton.layer.borderWidth = 2.0
        gameRulesButton.layer.borderColor = UIColor(red: 0.3, green: 0.85, blue: 0.8, alpha: 1.0).cgColor
        gameRulesButton.addTarget(self, action: #selector(gameRulesButtonTapped), for: .touchUpInside)
        
        // Add enhanced shadow and glow effect with teal tint
        gameRulesButton.layer.shadowColor = UIColor(red: 0.15, green: 0.7, blue: 0.65, alpha: 0.8).cgColor
        gameRulesButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        gameRulesButton.layer.shadowRadius = 15
        gameRulesButton.layer.shadowOpacity = 1.0
    }
    
    private func setupGameRecordsButton() {
        gameRecordsButton.setTitle("Game Records", for: .normal)
        gameRecordsButton.setTitleColor(.white, for: .normal)
        gameRecordsButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        // Use a modern deep purple/violet color
        gameRecordsButton.backgroundColor = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 0.9)
        gameRecordsButton.layer.cornerRadius = 18
        gameRecordsButton.layer.borderWidth = 2.0
        gameRecordsButton.layer.borderColor = UIColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1.0).cgColor
        gameRecordsButton.addTarget(self, action: #selector(gameRecordsButtonTapped), for: .touchUpInside)
        
        // Add enhanced shadow and glow effect with purple tint
        gameRecordsButton.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 0.8).cgColor
        gameRecordsButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        gameRecordsButton.layer.shadowRadius = 15
        gameRecordsButton.layer.shadowOpacity = 1.0
    }
    
    private func animateWelcomeElements() {
        startGameButton.alpha = 0
        gameRulesButton.alpha = 0
        gameRecordsButton.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut) {
            self.startGameButton.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.4, options: .curveEaseOut) {
            self.gameRulesButton.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.6, options: .curveEaseOut) {
            self.gameRecordsButton.alpha = 1.0
        }
    }
    
    @objc private func startGameButtonTapped() {
        let modeSelectionViewController = GameModeSelectionViewController()
        modeSelectionViewController.modalPresentationStyle = .fullScreen
        present(modeSelectionViewController, animated: true)
    }
    
    @objc private func gameRulesButtonTapped() {
        let rulesViewController = GameRulesViewController()
        rulesViewController.modalPresentationStyle = .fullScreen
        present(rulesViewController, animated: true)
    }
    
    @objc private func gameRecordsButtonTapped() {
        let recordsViewController = GameRecordsViewController()
        recordsViewController.modalPresentationStyle = .fullScreen
        present(recordsViewController, animated: true)
    }
}

