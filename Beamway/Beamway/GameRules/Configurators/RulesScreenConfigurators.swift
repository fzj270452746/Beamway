//
//  RulesScreenConfigurators.swift
//  Beamway
//
//  UI configuration components for game rules screen
//  Handles backdrop, header, and scroll area setup
//

import UIKit

// MARK: - Backdrop Configurator

/// Configures the background and gradient overlay for rules screen
final class RulesBackdropConfigurator {

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
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.85).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
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

// MARK: - Header Configurator

/// Configures the header section with title and back button
final class RulesHeaderConfigurator {

    // MARK: - Configuration Constants

    struct HeaderConfiguration {
        static let panelHeight: CGFloat = 60
        static let buttonSize: CGFloat = 44
        static let buttonCornerRadius: CGFloat = 22
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 10
    }

    // MARK: - Properties

    private let topSectionPanel: UIView
    private let returnAction: UIButton
    private let headingMarker: UILabel

    // MARK: - Initialization

    init(
        topSectionPanel: UIView,
        returnAction: UIButton,
        headingMarker: UILabel
    ) {
        self.topSectionPanel = topSectionPanel
        self.returnAction = returnAction
        self.headingMarker = headingMarker
    }

    // MARK: - Configuration

    func configure(in parentView: UIView) {
        configureTopSectionPanel(in: parentView)
        configureBackButton()
        configureHeadingLabel()
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
        returnAction.layer.cornerRadius = HeaderConfiguration.buttonCornerRadius
        returnAction.layer.borderWidth = 1
        returnAction.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        topSectionPanel.addSubview(returnAction)
        returnAction.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureHeadingLabel() {
        headingMarker.text = "GAME RULES"
        headingMarker.textColor = .white
        headingMarker.font = UIFont.systemFont(ofSize: 28, weight: .black)
        headingMarker.textAlignment = .center
        headingMarker.layer.shadowColor = UIColor(red: 0.0, green: 0.85, blue: 0.7, alpha: 1.0).cgColor
        headingMarker.layer.shadowOffset = .zero
        headingMarker.layer.shadowRadius = 15
        headingMarker.layer.shadowOpacity = 0.6
        topSectionPanel.addSubview(headingMarker)
        headingMarker.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView) {
        NSLayoutConstraint.activate([
            topSectionPanel.topAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.topAnchor,
                constant: HeaderConfiguration.topPadding
            ),
            topSectionPanel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            topSectionPanel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            topSectionPanel.heightAnchor.constraint(equalToConstant: HeaderConfiguration.panelHeight),

            returnAction.leadingAnchor.constraint(
                equalTo: topSectionPanel.leadingAnchor,
                constant: HeaderConfiguration.horizontalPadding
            ),
            returnAction.centerYAnchor.constraint(equalTo: topSectionPanel.centerYAnchor),
            returnAction.widthAnchor.constraint(equalToConstant: HeaderConfiguration.buttonSize),
            returnAction.heightAnchor.constraint(equalToConstant: HeaderConfiguration.buttonSize),

            headingMarker.centerXAnchor.constraint(equalTo: topSectionPanel.centerXAnchor),
            headingMarker.centerYAnchor.constraint(equalTo: topSectionPanel.centerYAnchor)
        ])
    }
}

// MARK: - Scroll Area Configurator

/// Configures the scrollable content area
final class RulesScrollAreaConfigurator {

    // MARK: - Configuration Constants

    struct ScrollConfiguration {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
        static let contentSpacing: CGFloat = 20
    }

    // MARK: - Properties

    private let scrollableArea: UIScrollView
    private let contentArrangement: UIStackView

    // MARK: - Initialization

    init(scrollableArea: UIScrollView, contentArrangement: UIStackView) {
        self.scrollableArea = scrollableArea
        self.contentArrangement = contentArrangement
    }

    // MARK: - Configuration

    func configure(in parentView: UIView, belowView: UIView) {
        configureScrollView(in: parentView)
        configureContentStack()
        setupConstraints(in: parentView, belowView: belowView)
    }

    private func configureScrollView(in parentView: UIView) {
        scrollableArea.backgroundColor = .clear
        scrollableArea.showsVerticalScrollIndicator = false
        parentView.addSubview(scrollableArea)
        scrollableArea.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureContentStack() {
        contentArrangement.axis = .vertical
        contentArrangement.spacing = ScrollConfiguration.contentSpacing
        contentArrangement.alignment = .fill
        scrollableArea.addSubview(contentArrangement)
        contentArrangement.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints(in parentView: UIView, belowView: UIView) {
        NSLayoutConstraint.activate([
            scrollableArea.topAnchor.constraint(
                equalTo: belowView.bottomAnchor,
                constant: ScrollConfiguration.topPadding
            ),
            scrollableArea.leadingAnchor.constraint(
                equalTo: parentView.leadingAnchor,
                constant: ScrollConfiguration.horizontalPadding
            ),
            scrollableArea.trailingAnchor.constraint(
                equalTo: parentView.trailingAnchor,
                constant: -ScrollConfiguration.horizontalPadding
            ),
            scrollableArea.bottomAnchor.constraint(
                equalTo: parentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -ScrollConfiguration.bottomPadding
            ),

            contentArrangement.topAnchor.constraint(equalTo: scrollableArea.topAnchor),
            contentArrangement.leadingAnchor.constraint(equalTo: scrollableArea.leadingAnchor),
            contentArrangement.trailingAnchor.constraint(equalTo: scrollableArea.trailingAnchor),
            contentArrangement.bottomAnchor.constraint(equalTo: scrollableArea.bottomAnchor),
            contentArrangement.widthAnchor.constraint(equalTo: scrollableArea.widthAnchor)
        ])
    }
}
