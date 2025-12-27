//
//  CategoryTilePanel.swift
//  Beamway
//
//  Mode selection tile card component
//  Displays game mode information with interactive tap behavior
//

import UIKit

// MARK: - Category Tile Panel

/// Interactive card component for displaying and selecting game modes
class CategoryTilePanel: UIView {

    // MARK: - Type Definitions

    /// Configuration for tile visual styling
    struct TileConfiguration {
        static let cornerRadius: CGFloat = 25
        static let borderWidth: CGFloat = 1.5
        static let iconContainerSize: CGFloat = 60
        static let iconContainerCornerRadius: CGFloat = 30
        static let iconSize: CGFloat = 28
        static let arrowSize: CGFloat = 40
        static let glowRadius: CGFloat = 20
        static let glowOpacity: Float = 0.4
    }

    /// Configuration for gradient styling
    struct GradientConfiguration {
        static let startAlpha: CGFloat = 0.25
        static let endAlpha: CGFloat = 0.08
        static let borderAlpha: CGFloat = 0.4
        static let iconBackgroundAlpha: CGFloat = 0.2
    }

    // MARK: - Callback

    /// Called when the tile is tapped
    var onTileTouched: (() -> Void)?

    // MARK: - Properties

    private let mode: SessionCategory
    private let dominantHue: UIColor

    // Layers
    private let gradientStratum: CAGradientLayer
    private let luminanceStratum: CALayer

    // UI Components
    private let symbolHolder: UIView
    private let symbolPictureHolder: UIImageView
    private let headingMarker: UILabel
    private let captionMarker: UILabel
    private let briefingMarker: UILabel
    private let pointerHolder: UIImageView

    // MARK: - Initialization

    init(
        mode: SessionCategory,
        title: String,
        subtitle: String,
        description: String,
        icon: String,
        primaryColor: UIColor
    ) {
        self.mode = mode
        self.dominantHue = primaryColor
        self.gradientStratum = CAGradientLayer()
        self.luminanceStratum = CALayer()

        self.symbolHolder = UIView()
        self.symbolPictureHolder = UIImageView()
        self.headingMarker = UILabel()
        self.captionMarker = UILabel()
        self.briefingMarker = UILabel()
        self.pointerHolder = UIImageView()

        super.init(frame: .zero)

        configureTileAppearance(
            title: title,
            subtitle: subtitle,
            description: description,
            icon: icon
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }

    private func updateLayerFrames() {
        gradientStratum.frame = bounds
        luminanceStratum.frame = bounds.insetBy(dx: -5, dy: -5)
        luminanceStratum.cornerRadius = layer.cornerRadius + 5
    }

    // MARK: - Configuration

    private func configureTileAppearance(
        title: String,
        subtitle: String,
        description: String,
        icon: String
    ) {
        configureGlowEffect()
        configureGradientBackground()
        configureBaseAppearance()
        configureSymbolContainer(icon: icon)
        configureLabels(title: title, subtitle: subtitle, description: description)
        configureArrowIndicator()
        setupLayoutConstraints()
        setupTapGesture()
        startArrowAnimation()
    }

    private func configureGlowEffect() {
        luminanceStratum.backgroundColor = UIColor.clear.cgColor
        luminanceStratum.shadowColor = dominantHue.cgColor
        luminanceStratum.shadowOffset = .zero
        luminanceStratum.shadowRadius = TileConfiguration.glowRadius
        luminanceStratum.shadowOpacity = TileConfiguration.glowOpacity
        layer.insertSublayer(luminanceStratum, at: 0)
    }

    private func configureGradientBackground() {
        gradientStratum.colors = [
            dominantHue.withAlphaComponent(GradientConfiguration.startAlpha).cgColor,
            dominantHue.withAlphaComponent(GradientConfiguration.endAlpha).cgColor
        ]
        gradientStratum.startPoint = CGPoint(x: 0, y: 0)
        gradientStratum.endPoint = CGPoint(x: 1, y: 1)
        gradientStratum.cornerRadius = TileConfiguration.cornerRadius
        layer.insertSublayer(gradientStratum, at: 1)
    }

    private func configureBaseAppearance() {
        layer.cornerRadius = TileConfiguration.cornerRadius
        layer.borderWidth = TileConfiguration.borderWidth
        layer.borderColor = dominantHue.withAlphaComponent(GradientConfiguration.borderAlpha).cgColor
    }

    private func configureSymbolContainer(icon: String) {
        symbolHolder.backgroundColor = dominantHue.withAlphaComponent(GradientConfiguration.iconBackgroundAlpha)
        symbolHolder.layer.cornerRadius = TileConfiguration.iconContainerCornerRadius
        addSubview(symbolHolder)
        symbolHolder.translatesAutoresizingMaskIntoConstraints = false

        symbolPictureHolder.image = UIImage(systemName: icon)
        symbolPictureHolder.tintColor = dominantHue
        symbolPictureHolder.contentMode = .scaleAspectFit
        symbolHolder.addSubview(symbolPictureHolder)
        symbolPictureHolder.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLabels(title: String, subtitle: String, description: String) {
        // Heading label
        headingMarker.text = title
        headingMarker.textColor = .white
        headingMarker.font = UIFont.systemFont(ofSize: 26, weight: .black)
        addSubview(headingMarker)
        headingMarker.translatesAutoresizingMaskIntoConstraints = false

        // Caption label
        captionMarker.text = subtitle
        captionMarker.textColor = dominantHue
        captionMarker.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        addSubview(captionMarker)
        captionMarker.translatesAutoresizingMaskIntoConstraints = false

        // Briefing label
        briefingMarker.text = description
        briefingMarker.textColor = UIColor.white.withAlphaComponent(0.6)
        briefingMarker.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        briefingMarker.numberOfLines = 2
        addSubview(briefingMarker)
        briefingMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureArrowIndicator() {
        pointerHolder.image = UIImage(systemName: "arrow.right.circle.fill")
        pointerHolder.tintColor = dominantHue
        pointerHolder.contentMode = .scaleAspectFit
        addSubview(pointerHolder)
        pointerHolder.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            // Symbol container
            symbolHolder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            symbolHolder.centerYAnchor.constraint(equalTo: centerYAnchor),
            symbolHolder.widthAnchor.constraint(equalToConstant: TileConfiguration.iconContainerSize),
            symbolHolder.heightAnchor.constraint(equalToConstant: TileConfiguration.iconContainerSize),

            // Symbol icon
            symbolPictureHolder.centerXAnchor.constraint(equalTo: symbolHolder.centerXAnchor),
            symbolPictureHolder.centerYAnchor.constraint(equalTo: symbolHolder.centerYAnchor),
            symbolPictureHolder.widthAnchor.constraint(equalToConstant: TileConfiguration.iconSize),
            symbolPictureHolder.heightAnchor.constraint(equalToConstant: TileConfiguration.iconSize),

            // Caption (subtitle)
            captionMarker.leadingAnchor.constraint(equalTo: symbolHolder.trailingAnchor, constant: 18),
            captionMarker.topAnchor.constraint(equalTo: topAnchor, constant: 30),

            // Heading (title)
            headingMarker.leadingAnchor.constraint(equalTo: captionMarker.leadingAnchor),
            headingMarker.topAnchor.constraint(equalTo: captionMarker.bottomAnchor, constant: 4),

            // Briefing (description)
            briefingMarker.leadingAnchor.constraint(equalTo: captionMarker.leadingAnchor),
            briefingMarker.topAnchor.constraint(equalTo: headingMarker.bottomAnchor, constant: 10),
            briefingMarker.trailingAnchor.constraint(equalTo: pointerHolder.leadingAnchor, constant: -15),

            // Arrow indicator
            pointerHolder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            pointerHolder.centerYAnchor.constraint(equalTo: centerYAnchor),
            pointerHolder.widthAnchor.constraint(equalToConstant: TileConfiguration.arrowSize),
            pointerHolder.heightAnchor.constraint(equalToConstant: TileConfiguration.arrowSize)
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tileTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    // MARK: - Animations

    private func startArrowAnimation() {
        ArrowPulseAnimationController.startPulseAnimation(on: pointerHolder)
    }

    @objc private func tileTapped() {
        TileSelectionAnimationHandler.executeSelectionAnimation(on: self) { [weak self] in
            self?.onTileTouched?()
        }
    }
}

// MARK: - Category Tile Factory

/// Factory for creating category tile panels
final class CategoryTileFactory {

    // MARK: - Factory Methods

    /// Create a solo mode tile panel
    static func createSoloModeTile() -> CategoryTilePanel {
        return CategoryTilePanel(
            mode: .solo,
            title: "SINGLE",
            subtitle: "Classic Mode",
            description: "Control one tile and survive as long as possible",
            icon: "person.fill",
            primaryColor: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        )
    }

    /// Create a competitive mode tile panel
    static func createCompetitiveModeTile() -> CategoryTilePanel {
        return CategoryTilePanel(
            mode: .competitive,
            title: "CHALLENGE",
            subtitle: "Expert Mode",
            description: "Control multiple tiles with increasing difficulty",
            icon: "bolt.fill",
            primaryColor: UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
        )
    }

    /// Create a custom mode tile panel
    static func createCustomModeTile(
        mode: SessionCategory,
        title: String,
        subtitle: String,
        description: String,
        icon: String,
        primaryColor: UIColor
    ) -> CategoryTilePanel {
        return CategoryTilePanel(
            mode: mode,
            title: title,
            subtitle: subtitle,
            description: description,
            icon: icon,
            primaryColor: primaryColor
        )
    }
}

// MARK: - Mode Selection Header View

/// Header component for mode selection screen
final class ModeSelectionHeaderView: UIView {

    // MARK: - Properties

    private let backButton: UIButton
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel

    /// Called when back button is tapped
    var onBackTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.backButton = UIButton(type: .system)
        self.titleLabel = UILabel()
        self.subtitleLabel = UILabel()

        super.init(frame: frame)

        configureHeaderAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureHeaderAppearance() {
        backgroundColor = .clear

        configureBackButton()
        configureTitleLabel()
        configureSubtitleLabel()
        setupConstraints()
    }

    private func configureBackButton() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        backButton.layer.cornerRadius = 22
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTitleLabel() {
        titleLabel.text = "SELECT MODE"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.6
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSubtitleLabel() {
        subtitleLabel.text = "Choose your challenge"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),

            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        onBackTapped?()
    }
}

// MARK: - Tips Card View

/// Card component displaying tips for mode selection
final class ModeTipsCard: UIView {

    // MARK: - Configuration

    struct TipsConfiguration {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let iconSize: CGFloat = 24
        static let backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.05)
        static let borderColor: UIColor = UIColor.white.withAlphaComponent(0.1)
        static let iconColor: UIColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
    }

    // MARK: - Properties

    private let iconImageView: UIImageView
    private let tipsLabel: UILabel

    // MARK: - Initialization

    init(tipText: String = "TIP: Start with Single Mode to learn the basics!") {
        self.iconImageView = UIImageView()
        self.tipsLabel = UILabel()

        super.init(frame: .zero)

        configureCardAppearance(tipText: tipText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureCardAppearance(tipText: String) {
        backgroundColor = TipsConfiguration.backgroundColor
        layer.cornerRadius = TipsConfiguration.cornerRadius
        layer.borderWidth = TipsConfiguration.borderWidth
        layer.borderColor = TipsConfiguration.borderColor.cgColor

        configureIcon()
        configureLabel(tipText: tipText)
        setupConstraints()
    }

    private func configureIcon() {
        iconImageView.image = UIImage(systemName: "lightbulb.fill")
        iconImageView.tintColor = TipsConfiguration.iconColor
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLabel(tipText: String) {
        tipsLabel.text = tipText
        tipsLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        tipsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        tipsLabel.numberOfLines = 2
        addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: TipsConfiguration.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: TipsConfiguration.iconSize),

            tipsLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            tipsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tipsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Update the tip text
    func updateTipText(_ text: String) {
        tipsLabel.text = text
    }
}
