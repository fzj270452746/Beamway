//
//  BackdropConfigurator.swift
//  Beamway
//
//  Configures the background and overlay layers for game screens
//

import UIKit

/// Configurator for backdrop and overlay setup
final class BackdropConfigurator {

    // MARK: - Properties

    private let backdropPictureHolder: UIImageView
    private let maskingPanel: UIView

    // MARK: - Initialization

    init(backdropPictureHolder: UIImageView, maskingPanel: UIView) {
        self.backdropPictureHolder = backdropPictureHolder
        self.maskingPanel = maskingPanel
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureBackgroundImage(in: parentView)
        configureGradientOverlay(in: parentView)
    }

    private func configureBackgroundImage(in parentView: UIView) {
        if let backgroundImage = UIImage(named: "benImage") {
            backdropPictureHolder.image = backgroundImage
        } else {
            backdropPictureHolder.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        }
        backdropPictureHolder.contentMode = .scaleAspectFill
        backdropPictureHolder.clipsToBounds = true
        parentView.addSubview(backdropPictureHolder)
        backdropPictureHolder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdropPictureHolder.topAnchor.constraint(equalTo: parentView.topAnchor),
            backdropPictureHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            backdropPictureHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            backdropPictureHolder.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }

    private func configureGradientOverlay(in parentView: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = UIScreen.main.bounds
        maskingPanel.layer.addSublayer(gradientLayer)
        parentView.addSubview(maskingPanel)
        maskingPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maskingPanel.topAnchor.constraint(equalTo: parentView.topAnchor),
            maskingPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            maskingPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            maskingPanel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
}

/// Configurator for alternate gradient styles
final class GradientStyleConfigurator {

    // MARK: - Gradient Styles

    enum GradientStyle {
        case darkGame
        case purpleAccent
        case cyanAccent
        case goldAccent

        var colors: [CGColor] {
            switch self {
            case .darkGame:
                return [
                    UIColor.black.withAlphaComponent(0.6).cgColor,
                    UIColor.black.withAlphaComponent(0.2).cgColor,
                    UIColor.black.withAlphaComponent(0.4).cgColor
                ]
            case .purpleAccent:
                return [
                    UIColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 0.8).cgColor,
                    UIColor.black.withAlphaComponent(0.3).cgColor,
                    UIColor(red: 0.1, green: 0.05, blue: 0.2, alpha: 0.7).cgColor
                ]
            case .cyanAccent:
                return [
                    UIColor(red: 0.0, green: 0.15, blue: 0.2, alpha: 0.8).cgColor,
                    UIColor.black.withAlphaComponent(0.3).cgColor,
                    UIColor(red: 0.0, green: 0.1, blue: 0.15, alpha: 0.7).cgColor
                ]
            case .goldAccent:
                return [
                    UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 0.8).cgColor,
                    UIColor.black.withAlphaComponent(0.3).cgColor,
                    UIColor(red: 0.15, green: 0.1, blue: 0.05, alpha: 0.7).cgColor
                ]
            }
        }

        var locations: [NSNumber] {
            return [0.0, 0.5, 1.0]
        }
    }

    // MARK: - Configuration

    static func createGradientLayer(style: GradientStyle, frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = style.colors
        gradientLayer.locations = style.locations
        gradientLayer.frame = frame
        return gradientLayer
    }

    static func applyGradient(to view: UIView, style: GradientStyle) {
        let gradientLayer = createGradientLayer(style: style, frame: view.bounds)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
