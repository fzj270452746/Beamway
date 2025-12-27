//
//  ModeSelectionConfigurators.swift
//  Beamway
//
//  UI configuration components for mode selection screen
//  Handles backdrop, spark effects, header, tiles, and explanation sections
//

import UIKit

// MARK: - Backdrop Configurator

/// Configures the background and gradient overlay for mode selection
final class ModeSelectionBackdropConfigurator {

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
        configureBackdropImage(in: parentView)
        configureGradientOverlay(in: parentView)
    }

    private func configureBackdropImage(in parentView: UIView) {
        if let backgroundImage = UIImage(named: "benImage") {
            backdropPictureHolder.image = backgroundImage
        } else {
            backdropPictureHolder.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
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
        let gradientStratum = CAGradientLayer()
        gradientStratum.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor(red: 0.1, green: 0.05, blue: 0.2, alpha: 0.6).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientStratum.locations = [0.0, 0.5, 1.0]
        gradientStratum.frame = UIScreen.main.bounds

        maskingPanel.layer.addSublayer(gradientStratum)
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

// MARK: - Spark Effect Configurator

/// Configures particle emission effects for mode selection screen
final class ModeSelectionSparkEffectConfigurator {

    // MARK: - Properties

    private let emitterLayer: CAEmitterLayer

    // MARK: - Initialization

    init(emitterLayer: CAEmitterLayer) {
        self.emitterLayer = emitterLayer
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureEmitterPosition()
        configureEmitterCell()
        parentView.layer.addSublayer(emitterLayer)
    }

    private func configureEmitterPosition() {
        let screenBounds = UIScreen.main.bounds
        emitterLayer.emitterPosition = CGPoint(x: screenBounds.width / 2, y: screenBounds.height + 50)
        emitterLayer.emitterSize = CGSize(width: screenBounds.width, height: 1)
        emitterLayer.emitterShape = .line
        emitterLayer.renderMode = .additive
    }

    private func configureEmitterCell() {
        let sparkCell = CAEmitterCell()
        sparkCell.birthRate = 2
        sparkCell.lifetime = 6
        sparkCell.velocity = -40
        sparkCell.velocityRange = 20
        sparkCell.emissionLongitude = -.pi / 2
        sparkCell.emissionRange = .pi / 6
        sparkCell.scale = 0.08
        sparkCell.scaleRange = 0.04
        sparkCell.alphaSpeed = -0.15
        sparkCell.color = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.5).cgColor
        sparkCell.contents = generateSparkImage()?.cgImage

        emitterLayer.emitterCells = [sparkCell]
    }

    private func generateSparkImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: 10, y: 10),
            startRadius: 0,
            endCenter: CGPoint(x: 10, y: 10),
            endRadius: 10,
            options: []
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Header Configurator

/// Configures the header section with title, subtitle, and back button
final class ModeSelectionHeaderConfigurator {

    // MARK: - Properties

    private let topSectionPanel: UIView
    private let headingMarker: UILabel
    private let captionMarker: UILabel
    private let returnAction: UIButton

    // MARK: - Initialization

    init(
        topSectionPanel: UIView,
        headingMarker: UILabel,
        captionMarker: UILabel,
        returnAction: UIButton
    ) {
        self.topSectionPanel = topSectionPanel
        self.headingMarker = headingMarker
        self.captionMarker = captionMarker
        self.returnAction = returnAction
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureTopSectionPanel(in: parentView)
        configureBackButton()
        configureHeadingLabel()
        configureCaptionLabel()
        setupConstraints(in: parentView)
    }

    private func configureTopSectionPanel(in parentView: UIView) {
        topSectionPanel.backgroundColor = .clear
        parentView.addSubview(topSectionPanel)
        topSectionPanel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureBackButton() {
        returnAction.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        returnAction.tintColor = .white
        returnAction.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        returnAction.layer.cornerRadius = 22
        returnAction.layer.borderWidth = 1
        returnAction.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        topSectionPanel.addSubview(returnAction)
        returnAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureHeadingLabel() {
        headingMarker.text = "SELECT MODE"
        headingMarker.textColor = .white
        headingMarker.font = UIFont.systemFont(ofSize: 32, weight: .black)
        headingMarker.textAlignment = .center
        headingMarker.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        headingMarker.layer.shadowOffset = .zero
        headingMarker.layer.shadowRadius = 15
        headingMarker.layer.shadowOpacity = 0.6
        topSectionPanel.addSubview(headingMarker)
        headingMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureCaptionLabel() {
        captionMarker.text = "Choose your challenge"
        captionMarker.textColor = UIColor.white.withAlphaComponent(0.6)
        captionMarker.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        captionMarker.textAlignment = .center
        topSectionPanel.addSubview(captionMarker)
        captionMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            topSectionPanel.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            topSectionPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            topSectionPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            topSectionPanel.heightAnchor.constraint(equalToConstant: 100),

            returnAction.leadingAnchor.constraint(equalTo: topSectionPanel.leadingAnchor, constant: 20),
            returnAction.topAnchor.constraint(equalTo: topSectionPanel.topAnchor),
            returnAction.widthAnchor.constraint(equalToConstant: 44),
            returnAction.heightAnchor.constraint(equalToConstant: 44),

            headingMarker.centerXAnchor.constraint(equalTo: topSectionPanel.centerXAnchor),
            headingMarker.topAnchor.constraint(equalTo: topSectionPanel.topAnchor, constant: 20),

            captionMarker.centerXAnchor.constraint(equalTo: topSectionPanel.centerXAnchor),
            captionMarker.topAnchor.constraint(equalTo: headingMarker.bottomAnchor, constant: 8)
        ])
    }
}

// MARK: - Category Tiles Configurator

/// Configures the mode selection card tiles
final class CategoryTilesConfigurator {

    // MARK: - Properties

    private let categoryTilesHolder: UIView
    private let soloModeTile: CategoryTilePanel
    private let competitiveModeTile: CategoryTilePanel

    // MARK: - Initialization

    init(
        categoryTilesHolder: UIView,
        soloModeTile: CategoryTilePanel,
        competitiveModeTile: CategoryTilePanel
    ) {
        self.categoryTilesHolder = categoryTilesHolder
        self.soloModeTile = soloModeTile
        self.competitiveModeTile = competitiveModeTile
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        configureTilesHolder(in: parentView)
        configureTiles()
        setupConstraints(in: parentView, belowView: belowView)
    }

    private func configureTilesHolder(in parentView: UIView) {
        categoryTilesHolder.backgroundColor = .clear
        parentView.addSubview(categoryTilesHolder)
        categoryTilesHolder.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTiles() {
        categoryTilesHolder.addSubview(soloModeTile)
        categoryTilesHolder.addSubview(competitiveModeTile)
        soloModeTile.translatesAutoresizingMaskIntoConstraints = false
        competitiveModeTile.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView, belowView: UIView) {
        NSLayoutConstraint.activate([
            categoryTilesHolder.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 30),
            categoryTilesHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 25),
            categoryTilesHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -25),
            categoryTilesHolder.heightAnchor.constraint(equalToConstant: 380),

            soloModeTile.topAnchor.constraint(equalTo: categoryTilesHolder.topAnchor),
            soloModeTile.leadingAnchor.constraint(equalTo: categoryTilesHolder.leadingAnchor),
            soloModeTile.trailingAnchor.constraint(equalTo: categoryTilesHolder.trailingAnchor),
            soloModeTile.heightAnchor.constraint(equalToConstant: 170),

            competitiveModeTile.topAnchor.constraint(equalTo: soloModeTile.bottomAnchor, constant: 20),
            competitiveModeTile.leadingAnchor.constraint(equalTo: categoryTilesHolder.leadingAnchor),
            competitiveModeTile.trailingAnchor.constraint(equalTo: categoryTilesHolder.trailingAnchor),
            competitiveModeTile.heightAnchor.constraint(equalToConstant: 170)
        ])
    }
}

// MARK: - Mode Explanation Configurator

/// Configures the tips/explanation section at the bottom
final class ModeExplanationConfigurator {

    // MARK: - Properties

    private let explanationHolder: UIView

    // MARK: - Initialization

    init(explanationHolder: UIView) {
        self.explanationHolder = explanationHolder
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        configureExplanationHolder(in: parentView)
        configureTipsContent()
        setupConstraints(in: parentView, belowView: belowView)
    }

    private func configureExplanationHolder(in parentView: UIView) {
        explanationHolder.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        explanationHolder.layer.cornerRadius = 20
        explanationHolder.layer.borderWidth = 1
        explanationHolder.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        parentView.addSubview(explanationHolder)
        explanationHolder.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTipsContent() {
        let tipsIcon = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        tipsIcon.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        tipsIcon.contentMode = .scaleAspectFit
        explanationHolder.addSubview(tipsIcon)
        tipsIcon.translatesAutoresizingMaskIntoConstraints = false

        let tipsLabel = UILabel()
        tipsLabel.text = "TIP: Start with Single Mode to learn the basics!"
        tipsLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        tipsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        tipsLabel.numberOfLines = 2
        explanationHolder.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tipsIcon.leadingAnchor.constraint(equalTo: explanationHolder.leadingAnchor, constant: 20),
            tipsIcon.centerYAnchor.constraint(equalTo: explanationHolder.centerYAnchor),
            tipsIcon.widthAnchor.constraint(equalToConstant: 24),
            tipsIcon.heightAnchor.constraint(equalToConstant: 24),

            tipsLabel.leadingAnchor.constraint(equalTo: tipsIcon.trailingAnchor, constant: 12),
            tipsLabel.trailingAnchor.constraint(equalTo: explanationHolder.trailingAnchor, constant: -20),
            tipsLabel.centerYAnchor.constraint(equalTo: explanationHolder.centerYAnchor)
        ])
    }

    private func setupConstraints(in parentView: UIView, belowView: UIView) {
        NSLayoutConstraint.activate([
            explanationHolder.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 25),
            explanationHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 25),
            explanationHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -25),
            explanationHolder.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
