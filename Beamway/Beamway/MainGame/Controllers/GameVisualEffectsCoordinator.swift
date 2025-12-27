//
//  GameVisualEffectsCoordinator.swift
//  Beamway
//
//  Coordinates visual effects during gameplay including
//  damage indicators, screen shake, and level up effects
//

import UIKit

/// Coordinator for game visual effects
final class GameVisualEffectsCoordinator {

    // MARK: - Constants

    private struct EffectConstants {
        static let shakeValues: [CGFloat] = [-10, 10, -8, 8, -5, 5, 0]
        static let shakeDuration: TimeInterval = 0.3
        static let damageFlashDuration: TimeInterval = 0.3
        static let levelUpDisplayDuration: TimeInterval = 0.8
    }

    // MARK: - Properties

    private weak var parentView: UIView?

    // MARK: - Initialization

    init(parentView: UIView) {
        self.parentView = parentView
    }

    // MARK: - Screen Shake Effect

    func shakeScreen() {
        guard let view = parentView else { return }

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = EffectConstants.shakeDuration
        animation.values = EffectConstants.shakeValues
        view.layer.add(animation, forKey: "shake")
    }

    // MARK: - Damage Effect

    func showDamageEffect() {
        guard let view = parentView else { return }

        let damageView = UIView()
        damageView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        damageView.frame = view.bounds
        damageView.alpha = 0

        // Insert below HUD elements
        view.insertSubview(damageView, at: 0)

        UIView.animate(withDuration: 0.1, animations: {
            damageView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                damageView.alpha = 0
            }) { _ in
                damageView.removeFromSuperview()
            }
        }
    }

    // MARK: - Level Up Effect

    func showLevelUpEffect() {
        guard let view = parentView else { return }

        let levelUpLabel = UILabel()
        levelUpLabel.text = "LEVEL UP!"
        levelUpLabel.textColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
        levelUpLabel.font = UIFont.systemFont(ofSize: 36, weight: .black)
        levelUpLabel.textAlignment = .center
        levelUpLabel.alpha = 0
        levelUpLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        // Add glow effect
        levelUpLabel.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        levelUpLabel.layer.shadowOffset = .zero
        levelUpLabel.layer.shadowRadius = 15
        levelUpLabel.layer.shadowOpacity = 0.8

        view.addSubview(levelUpLabel)
        levelUpLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            levelUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelUpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            levelUpLabel.alpha = 1
            levelUpLabel.transform = .identity
        } completion: { _ in
            UIView.animate(
                withDuration: 0.3,
                delay: EffectConstants.levelUpDisplayDuration,
                options: .curveEaseOut
            ) {
                levelUpLabel.alpha = 0
                levelUpLabel.transform = CGAffineTransform(translationX: 0, y: -50)
            } completion: { _ in
                levelUpLabel.removeFromSuperview()
            }
        }
    }

    // MARK: - Score Popup Effect

    func showScorePopup(score: Int, at position: CGPoint) {
        guard let view = parentView else { return }

        let scorePopup = UILabel()
        scorePopup.text = "+\(score)"
        scorePopup.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        scorePopup.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scorePopup.textAlignment = .center
        scorePopup.alpha = 0

        view.addSubview(scorePopup)
        scorePopup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scorePopup.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: position.x),
            scorePopup.centerYAnchor.constraint(equalTo: view.topAnchor, constant: position.y)
        ])

        UIView.animate(withDuration: 0.2) {
            scorePopup.alpha = 1
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            options: .curveEaseOut
        ) {
            scorePopup.transform = CGAffineTransform(translationX: 0, y: -30)
            scorePopup.alpha = 0
        } completion: { _ in
            scorePopup.removeFromSuperview()
        }
    }

    // MARK: - Combo Explosion Effect

    func showComboExplosion(combo: Int, at position: CGPoint) {
        guard let view = parentView, combo >= 5 else { return }

        let comboLabel = UILabel()
        comboLabel.text = "COMBO x\(combo)!"
        comboLabel.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        comboLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

        // Add glow
        comboLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0).cgColor
        comboLabel.layer.shadowOffset = .zero
        comboLabel.layer.shadowRadius = 10
        comboLabel.layer.shadowOpacity = 0.8

        view.addSubview(comboLabel)
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8
        ) {
            comboLabel.alpha = 1
            comboLabel.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5) {
                comboLabel.alpha = 0
                comboLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            } completion: { _ in
                comboLabel.removeFromSuperview()
            }
        }
    }

    // MARK: - Particle Burst Effect

    func showParticleBurst(at position: CGPoint, color: UIColor) {
        guard let view = parentView else { return }

        let particleCount = 8
        let particleSize: CGFloat = 6

        for i in 0..<particleCount {
            let particle = UIView()
            particle.backgroundColor = color
            particle.layer.cornerRadius = particleSize / 2
            particle.frame = CGRect(x: position.x, y: position.y, width: particleSize, height: particleSize)
            view.addSubview(particle)

            let angle = CGFloat(i) * (2 * .pi / CGFloat(particleCount))
            let distance: CGFloat = 50

            let endX = position.x + cos(angle) * distance
            let endY = position.y + sin(angle) * distance

            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                options: .curveEaseOut
            ) {
                particle.center = CGPoint(x: endX, y: endY)
                particle.alpha = 0
                particle.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            } completion: { _ in
                particle.removeFromSuperview()
            }
        }
    }

    // MARK: - Flash Effect

    func flashScreen(color: UIColor, duration: TimeInterval = 0.2) {
        guard let view = parentView else { return }

        let flashView = UIView()
        flashView.backgroundColor = color
        flashView.frame = view.bounds
        flashView.alpha = 0
        view.insertSubview(flashView, at: 0)

        UIView.animate(withDuration: duration / 2) {
            flashView.alpha = 0.5
        } completion: { _ in
            UIView.animate(withDuration: duration / 2) {
                flashView.alpha = 0
            } completion: { _ in
                flashView.removeFromSuperview()
            }
        }
    }

    // MARK: - Pulse Effect

    func pulseView(_ targetView: UIView, scale: CGFloat = 1.1, duration: TimeInterval = 0.15) {
        UIView.animate(withDuration: duration, animations: {
            targetView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration) {
                targetView.transform = .identity
            }
        }
    }
}
