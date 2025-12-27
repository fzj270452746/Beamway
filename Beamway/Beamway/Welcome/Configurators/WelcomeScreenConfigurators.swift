//
//  WelcomeScreenConfigurators.swift
//  Beamway
//
//  Configurators for setting up welcome screen UI sections
//

import UIKit

// MARK: - Welcome Backdrop Configurator

/// Configurator for welcome screen backdrop and gradient overlay
final class WelcomeBackdropConfigurator {

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
        if let backdropPicture = UIImage(named: "benImage") {
            backdropPictureHolder.image = backdropPicture
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
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientStratum.locations = [0.0, 0.3, 0.7, 1.0]
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

/// Configurator for particle spark effect
final class SparkEffectConfigurator {

    // MARK: - Properties

    private let emitterLayer: CAEmitterLayer

    // MARK: - Initialization

    init(emitterLayer: CAEmitterLayer) {
        self.emitterLayer = emitterLayer
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        emitterLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        emitterLayer.emitterShape = .line
        emitterLayer.renderMode = .additive

        let sparkParticle = createSparkParticle()
        emitterLayer.emitterCells = [sparkParticle]
        parentView.layer.addSublayer(emitterLayer)
    }

    private func createSparkParticle() -> CAEmitterCell {
        let sparkParticle = CAEmitterCell()
        sparkParticle.birthRate = 3
        sparkParticle.lifetime = 8
        sparkParticle.velocity = 50
        sparkParticle.velocityRange = 30
        sparkParticle.emissionLongitude = .pi
        sparkParticle.emissionRange = .pi / 4
        sparkParticle.scale = 0.1
        sparkParticle.scaleRange = 0.05
        sparkParticle.alphaSpeed = -0.1
        sparkParticle.color = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 0.6).cgColor
        sparkParticle.contents = generateSparkImage()?.cgImage
        return sparkParticle
    }

    private func generateSparkImage() -> UIImage? {
        let dimensions = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(dimensions, false, 0)
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

        let picture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return picture
    }
}

// MARK: - Emblem Section Configurator

/// Configurator for game title and subtitle section
final class EmblemSectionConfigurator {

    // MARK: - Properties

    private let emblemHolder: UIView
    private let playTitleMarker: UILabel
    private let captionMarker: UILabel

    // MARK: - Initialization

    init(emblemHolder: UIView, playTitleMarker: UILabel, captionMarker: UILabel) {
        self.emblemHolder = emblemHolder
        self.playTitleMarker = playTitleMarker
        self.captionMarker = captionMarker
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        emblemHolder.backgroundColor = .clear
        parentView.addSubview(emblemHolder)
        emblemHolder.translatesAutoresizingMaskIntoConstraints = false

        configureTitleLabel()
        configureSubtitleLabel()
        setupConstraints(in: parentView)
    }

    private func configureTitleLabel() {
        playTitleMarker.text = "BEAMWAY"
        playTitleMarker.textColor = .white
        playTitleMarker.font = UIFont.systemFont(ofSize: 48, weight: .black)
        playTitleMarker.textAlignment = .center
        playTitleMarker.layer.shadowColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0).cgColor
        playTitleMarker.layer.shadowOffset = .zero
        playTitleMarker.layer.shadowRadius = 20
        playTitleMarker.layer.shadowOpacity = 0.8
        emblemHolder.addSubview(playTitleMarker)
        playTitleMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSubtitleLabel() {
        captionMarker.text = "Dodge the Arrows"
        captionMarker.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        captionMarker.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        captionMarker.textAlignment = .center
        captionMarker.alpha = 0.8
        emblemHolder.addSubview(captionMarker)
        captionMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            emblemHolder.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            emblemHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            emblemHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            emblemHolder.heightAnchor.constraint(equalToConstant: 100),

            playTitleMarker.topAnchor.constraint(equalTo: emblemHolder.topAnchor),
            playTitleMarker.centerXAnchor.constraint(equalTo: emblemHolder.centerXAnchor),

            captionMarker.topAnchor.constraint(equalTo: playTitleMarker.bottomAnchor, constant: 5),
            captionMarker.centerXAnchor.constraint(equalTo: emblemHolder.centerXAnchor)
        ])
    }
}

// MARK: - Metrics Section Configurator

/// Configurator for statistics tiles section
final class MetricsSectionConfigurator {

    // MARK: - Properties

    private let metricsHolder: UIView
    private let aggregateMatchesTile: MetricsTilePanel
    private let peakPointsTile: MetricsTilePanel
    private let cumulativeDurationTile: MetricsTilePanel

    // MARK: - Initialization

    init(
        metricsHolder: UIView,
        aggregateMatchesTile: MetricsTilePanel,
        peakPointsTile: MetricsTilePanel,
        cumulativeDurationTile: MetricsTilePanel
    ) {
        self.metricsHolder = metricsHolder
        self.aggregateMatchesTile = aggregateMatchesTile
        self.peakPointsTile = peakPointsTile
        self.cumulativeDurationTile = cumulativeDurationTile
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        metricsHolder.backgroundColor = .clear
        parentView.addSubview(metricsHolder)
        metricsHolder.translatesAutoresizingMaskIntoConstraints = false

        let metricsArrangement = UIStackView(arrangedSubviews: [
            aggregateMatchesTile,
            peakPointsTile,
            cumulativeDurationTile
        ])
        metricsArrangement.axis = .horizontal
        metricsArrangement.distribution = .fillEqually
        metricsArrangement.spacing = 12
        metricsHolder.addSubview(metricsArrangement)
        metricsArrangement.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            metricsHolder.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 15),
            metricsHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            metricsHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            metricsHolder.heightAnchor.constraint(equalToConstant: 85),

            metricsArrangement.topAnchor.constraint(equalTo: metricsHolder.topAnchor),
            metricsArrangement.leadingAnchor.constraint(equalTo: metricsHolder.leadingAnchor),
            metricsArrangement.trailingAnchor.constraint(equalTo: metricsHolder.trailingAnchor),
            metricsArrangement.bottomAnchor.constraint(equalTo: metricsHolder.bottomAnchor)
        ])
    }
}

// MARK: - Primary Actions Configurator

/// Configurator for main action buttons
final class PrimaryActionsConfigurator {

    // MARK: - Properties

    private let primaryActionsHolder: UIView
    private let commenceAction: RadiantActionButton
    private let swiftPlayAction: RadiantActionButton

    // MARK: - Initialization

    init(
        primaryActionsHolder: UIView,
        commenceAction: RadiantActionButton,
        swiftPlayAction: RadiantActionButton
    ) {
        self.primaryActionsHolder = primaryActionsHolder
        self.commenceAction = commenceAction
        self.swiftPlayAction = swiftPlayAction
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        primaryActionsHolder.backgroundColor = .clear
        parentView.addSubview(primaryActionsHolder)
        primaryActionsHolder.translatesAutoresizingMaskIntoConstraints = false

        primaryActionsHolder.addSubview(commenceAction)
        primaryActionsHolder.addSubview(swiftPlayAction)
        commenceAction.translatesAutoresizingMaskIntoConstraints = false
        swiftPlayAction.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            primaryActionsHolder.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 20),
            primaryActionsHolder.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 30),
            primaryActionsHolder.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -30),
            primaryActionsHolder.heightAnchor.constraint(equalToConstant: 130),

            commenceAction.topAnchor.constraint(equalTo: primaryActionsHolder.topAnchor),
            commenceAction.leadingAnchor.constraint(equalTo: primaryActionsHolder.leadingAnchor),
            commenceAction.trailingAnchor.constraint(equalTo: primaryActionsHolder.trailingAnchor),
            commenceAction.heightAnchor.constraint(equalToConstant: 60),

            swiftPlayAction.topAnchor.constraint(equalTo: commenceAction.bottomAnchor, constant: 12),
            swiftPlayAction.leadingAnchor.constraint(equalTo: primaryActionsHolder.leadingAnchor),
            swiftPlayAction.trailingAnchor.constraint(equalTo: primaryActionsHolder.trailingAnchor),
            swiftPlayAction.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - Footer Navigation Configurator

/// Configurator for bottom navigation bar
final class FooterNavigationConfigurator {

    // MARK: - Properties

    private let footerNavigationHolder: UIView
    private let instructionsNav: RoundedNavigationButton
    private let historiesNav: RoundedNavigationButton
    private let preferencesNav: RoundedNavigationButton

    // MARK: - Initialization

    init(
        footerNavigationHolder: UIView,
        instructionsNav: RoundedNavigationButton,
        historiesNav: RoundedNavigationButton,
        preferencesNav: RoundedNavigationButton
    ) {
        self.footerNavigationHolder = footerNavigationHolder
        self.instructionsNav = instructionsNav
        self.historiesNav = historiesNav
        self.preferencesNav = preferencesNav
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureContainerAppearance()
        parentView.addSubview(footerNavigationHolder)
        footerNavigationHolder.translatesAutoresizingMaskIntoConstraints = false

        addBlurEffect()
        configureNavigationStack()
        setupConstraints(in: parentView)
    }

    private func configureContainerAppearance() {
        footerNavigationHolder.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        footerNavigationHolder.layer.cornerRadius = 25
        footerNavigationHolder.layer.borderWidth = 1
        footerNavigationHolder.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
    }

    private func addBlurEffect() {
        let blurEffector = UIBlurEffect(style: .dark)
        let blurPanel = UIVisualEffectView(effect: blurEffector)
        blurPanel.layer.cornerRadius = 25
        blurPanel.clipsToBounds = true
        footerNavigationHolder.insertSubview(blurPanel, at: 0)
        blurPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurPanel.topAnchor.constraint(equalTo: footerNavigationHolder.topAnchor),
            blurPanel.leadingAnchor.constraint(equalTo: footerNavigationHolder.leadingAnchor),
            blurPanel.trailingAnchor.constraint(equalTo: footerNavigationHolder.trailingAnchor),
            blurPanel.bottomAnchor.constraint(equalTo: footerNavigationHolder.bottomAnchor)
        ])
    }

    private func configureNavigationStack() {
        let navigationArrangement = UIStackView(arrangedSubviews: [
            instructionsNav,
            historiesNav,
            preferencesNav
        ])
        navigationArrangement.axis = .horizontal
        navigationArrangement.distribution = .equalSpacing
        navigationArrangement.spacing = 30
        footerNavigationHolder.addSubview(navigationArrangement)
        navigationArrangement.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navigationArrangement.centerXAnchor.constraint(equalTo: footerNavigationHolder.centerXAnchor),
            navigationArrangement.centerYAnchor.constraint(equalTo: footerNavigationHolder.centerYAnchor)
        ])
    }

    private func setupConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            footerNavigationHolder.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            footerNavigationHolder.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            footerNavigationHolder.widthAnchor.constraint(equalToConstant: 280),
            footerNavigationHolder.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
