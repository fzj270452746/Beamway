//
//  DartMissilePanel.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

enum DartOrientation {
    case upper
    case lower
    case leftward
    case rightward
}

class DartMissilePanel: UIView {

    let orientation: DartOrientation
    var dartUniqueId: String

    init(orientation: DartOrientation, uniqueId: String = UUID().uuidString) {
        self.orientation = orientation
        self.dartUniqueId = uniqueId

        super.init(frame: .zero)

        configureDartPanel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureDartPanel() {
        backgroundColor = .clear

        // Create arrow shape using CAShapeLayer
        let dartRoute = generateDartRoute()
        let dartShape = CAShapeLayer()
        dartShape.path = dartRoute.cgPath
        // Use a more vibrant red color for better visibility
        dartShape.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        dartShape.strokeColor = UIColor.white.cgColor
        dartShape.lineWidth = 2.5

        layer.addSublayer(dartShape)

        // Add enhanced glow effect for better visibility against background
        layer.shadowColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.9
        layer.shadowOffset = .zero
    }

    private func generateDartRoute() -> UIBezierPath {
        let route = UIBezierPath()
        let breadth = bounds.width > 0 ? bounds.width : 30
        let altitude = bounds.height > 0 ? bounds.height : 30

        switch orientation {
        case .upper:
            // Arrow from top moving down - arrow should point downward (tip at bottom)
            route.move(to: CGPoint(x: breadth / 2, y: altitude))
            route.addLine(to: CGPoint(x: 0, y: altitude * 0.7))
            route.addLine(to: CGPoint(x: breadth / 4, y: altitude * 0.7))
            route.addLine(to: CGPoint(x: breadth / 4, y: 0))
            route.addLine(to: CGPoint(x: breadth * 3 / 4, y: 0))
            route.addLine(to: CGPoint(x: breadth * 3 / 4, y: altitude * 0.7))
            route.addLine(to: CGPoint(x: breadth, y: altitude * 0.7))
            route.close()
        case .lower:
            // Arrow from bottom moving up - arrow should point upward (tip at top)
            route.move(to: CGPoint(x: breadth / 2, y: 0))
            route.addLine(to: CGPoint(x: 0, y: altitude * 0.3))
            route.addLine(to: CGPoint(x: breadth / 4, y: altitude * 0.3))
            route.addLine(to: CGPoint(x: breadth / 4, y: altitude))
            route.addLine(to: CGPoint(x: breadth * 3 / 4, y: altitude))
            route.addLine(to: CGPoint(x: breadth * 3 / 4, y: altitude * 0.3))
            route.addLine(to: CGPoint(x: breadth, y: altitude * 0.3))
            route.close()
        case .leftward:
            // Arrow from left moving right - arrow should point rightward (tip at right)
            route.move(to: CGPoint(x: breadth, y: altitude / 2))
            route.addLine(to: CGPoint(x: breadth * 0.3, y: 0))
            route.addLine(to: CGPoint(x: breadth * 0.3, y: altitude / 4))
            route.addLine(to: CGPoint(x: 0, y: altitude / 4))
            route.addLine(to: CGPoint(x: 0, y: altitude * 3 / 4))
            route.addLine(to: CGPoint(x: breadth * 0.3, y: altitude * 3 / 4))
            route.addLine(to: CGPoint(x: breadth * 0.3, y: altitude))
            route.close()
        case .rightward:
            // Arrow from right moving left - arrow should point leftward (tip at left)
            route.move(to: CGPoint(x: 0, y: altitude / 2))
            route.addLine(to: CGPoint(x: breadth * 0.7, y: 0))
            route.addLine(to: CGPoint(x: breadth * 0.7, y: altitude / 4))
            route.addLine(to: CGPoint(x: breadth, y: altitude / 4))
            route.addLine(to: CGPoint(x: breadth, y: altitude * 3 / 4))
            route.addLine(to: CGPoint(x: breadth * 0.7, y: altitude * 3 / 4))
            route.addLine(to: CGPoint(x: breadth * 0.7, y: altitude))
            route.close()
        }

        return route
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update arrow path when bounds change
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let dartRoute = generateDartRoute()
        let dartShape = CAShapeLayer()
        dartShape.path = dartRoute.cgPath
        dartShape.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        dartShape.strokeColor = UIColor.white.cgColor
        dartShape.lineWidth = 2.5
        layer.addSublayer(dartShape)
    }

    func executeLaunchMotion(from origin: CGPoint, to terminus: CGPoint, interval: TimeInterval, finishHandler: @escaping () -> Void) {
        center = origin
        alpha = 0

        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: interval, delay: 0, options: .curveLinear, animations: {
                self.center = terminus
            }) { _ in
                finishHandler()
            }
        }
    }
}

