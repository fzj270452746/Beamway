//
//  DominoBlockPanel.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class DominoBlockPanel: UIView {

    private let blockPictureHolder: UIImageView
    private let blockPictureName: String

    var blockUniqueId: String

    init(pictureName: String, uniqueId: String = UUID().uuidString) {
        self.blockPictureName = pictureName
        self.blockUniqueId = uniqueId

        blockPictureHolder = UIImageView()
        blockPictureHolder.contentMode = .scaleToFill
        blockPictureHolder.clipsToBounds = true

        super.init(frame: .zero)

        configureDominoPanel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureDominoPanel() {
        backgroundColor = .clear

        // Set tile image
        if let image = UIImage(named: blockPictureName) {
            blockPictureHolder.image = image
        } else {
            // Fallback to first available image
            blockPictureHolder.image = UIImage(named: "be 0")
        }

        addSubview(blockPictureHolder)
        blockPictureHolder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blockPictureHolder.topAnchor.constraint(equalTo: topAnchor),
            blockPictureHolder.leadingAnchor.constraint(equalTo: leadingAnchor),
            blockPictureHolder.trailingAnchor.constraint(equalTo: trailingAnchor),
            blockPictureHolder.bottomAnchor.constraint(equalTo: bottomAnchor)
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

    func refreshBlockPicture(pictureName: String) {
        if let image = UIImage(named: pictureName) {
            blockPictureHolder.image = image
        }
    }

    func executeAppearanceMotion() {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    func executeTranslationMotion(to destination: CGPoint, interval: TimeInterval = 0.2) {
        UIView.animate(withDuration: interval, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = destination
        }
    }

    func executeVibrationMotion() {
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

