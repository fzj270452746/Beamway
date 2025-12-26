//
//  MahjongTileView.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class MahjongTileView: UIView {
    
    private let tileImageView: UIImageView
    private let tileImageName: String
    
    var tileIdentifier: String
    
    init(imageName: String, identifier: String = UUID().uuidString) {
        self.tileImageName = imageName
        self.tileIdentifier = identifier
        
        tileImageView = UIImageView()
        tileImageView.contentMode = .scaleToFill
        tileImageView.clipsToBounds = true
        
        super.init(frame: .zero)
        
        setupTileView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTileView() {
        backgroundColor = .clear
        
        // Set tile image
        if let image = UIImage(named: tileImageName) {
            tileImageView.image = image
        } else {
            // Fallback to first available image
            tileImageView.image = UIImage(named: "be 0")
        }
        
        addSubview(tileImageView)
        tileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tileImageView.topAnchor.constraint(equalTo: topAnchor),
            tileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tileImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set corner radius and border
        layer.cornerRadius = 4.5
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        clipsToBounds = true
        
        // Add shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path for better performance
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.5).cgPath
    }
    
    func updateTileImage(imageName: String) {
        if let image = UIImage(named: imageName) {
            tileImageView.image = image
        }
    }
    
    func animateTileAppearance() {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    func animateTileMovement(to position: CGPoint, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = position
        }
    }
    
    func animateShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10, 10, -10, 10, -5, 5, -5, 5, 0]
        layer.add(animation, forKey: "shake")
        
        // Also add vertical shake for more realistic effect
        let verticalAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        verticalAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        verticalAnimation.duration = 0.5
        verticalAnimation.values = [-5, 5, -5, 5, -3, 3, -3, 3, 0]
        layer.add(verticalAnimation, forKey: "shakeVertical")
    }
}

