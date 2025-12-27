//
//  UIViewExtensions.swift
//  Beamway
//
//  UIView convenience extensions
//

import UIKit

// MARK: - Layout Extensions

extension UIView {

    /// Pin edges to superview with optional insets
    func pinEdgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Pin edges to superview safe area with optional insets
    func pinEdgesToSuperviewSafeArea(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Center in superview
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// Set fixed size constraints
    func setFixedSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }

    /// Set fixed width constraint
    func setFixedWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    /// Set fixed height constraint
    func setFixedHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    /// Add multiple subviews at once
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    /// Add multiple subviews from array
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }

    /// Remove all subviews
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Styling Extensions

extension UIView {

    /// Apply rounded corners to specific corners
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }

    /// Apply circular mask
    func applyCircularMask() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }

    /// Apply card styling
    func applyCardStyling(cornerRadius: CGFloat = 20, borderWidth: CGFloat = 1, borderColor: UIColor = UIColor.white.withAlphaComponent(0.15)) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }

    /// Apply shadow styling
    func applyShadowStyling(color: UIColor = .black, radius: CGFloat = 10, opacity: Float = 0.3, offset: CGSize = CGSize(width: 0, height: 4)) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
    }

    /// Apply glow effect
    func applyGlowEffect(color: UIColor, radius: CGFloat = 15, opacity: Float = 0.8) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }

    /// Remove glow effect
    func removeGlowEffect() {
        layer.shadowOpacity = 0
    }

    /// Apply gradient background
    func applyGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius

        // Remove existing gradient layers
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        layer.insertSublayer(gradientLayer, at: 0)
    }

    /// Apply blur effect
    func applyBlurEffect(style: UIBlurEffect.Style = .dark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView, at: 0)
    }
}

// MARK: - Animation Extensions

extension UIView {

    /// Fade in animation
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
            self.alpha = 1
        } completion: { _ in
            completion?()
        }
    }

    /// Fade out animation
    func fadeOut(duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
            self.alpha = 0
        } completion: { _ in
            completion?()
        }
    }

    /// Spring scale animation
    func springScale(to scale: CGFloat, duration: TimeInterval = 0.3, damping: CGFloat = 0.6, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0.5) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            completion?()
        }
    }

    /// Shake animation
    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [
            -intensity, intensity, -intensity, intensity,
            -intensity * 0.5, intensity * 0.5, -intensity * 0.5, intensity * 0.5, 0
        ]
        layer.add(animation, forKey: "shake")
    }

    /// Pulse animation
    func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                self.transform = .identity
            }
        }
    }
}

// MARK: - Snapshot Extensions

extension UIView {

    /// Create snapshot image of view
    func createSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }

        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Create snapshot view
    func createSnapshotView() -> UIView? {
        return snapshotView(afterScreenUpdates: true)
    }
}

// MARK: - Frame Extensions

extension UIView {

    /// View's X position
    var viewX: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    /// View's Y position
    var viewY: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    /// View's width
    var viewWidth: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }

    /// View's height
    var viewHeight: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }

    /// View's center X
    var centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    /// View's center Y
    var centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }
}

// MARK: - UIColor Extensions

extension UIColor {

    /// Create color from hex string
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    /// Create color with adjusted brightness
    func adjustBrightness(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: max(min(b + factor, 1.0), 0.0), alpha: a)
        }

        return self
    }

    /// Create lighter version of color
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: percentage)
    }

    /// Create darker version of color
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return adjustBrightness(by: -percentage)
    }
}

// MARK: - CGRect Extensions

extension CGRect {

    /// Center point of rectangle
    var centerPoint: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

// MARK: - CGPoint Extensions

extension CGPoint {

    /// Distance to another point
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }

    /// Add two points
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtract two points
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {

    /// Format as minutes and seconds string
    var formattedMinutesSeconds: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Format as full time string (hours:minutes:seconds)
    var formattedFullTime: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
