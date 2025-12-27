//
//  ReturnNavigator.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

class ReturnNavigator: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureReturnNavigator()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureReturnNavigator()
    }

    private func configureReturnNavigator() {
        // Create custom back button appearance
        setTitle("← Back", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor

        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.5

        // Add padding
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        // Add hover/press effect
        addTarget(self, action: #selector(navigatorTouched), for: .touchDown)
        addTarget(self, action: #selector(navigatorUntouched), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func navigatorTouched() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        }
    }

    @objc private func navigatorUntouched() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
}

