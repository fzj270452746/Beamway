//
//  ArrowProjectileView.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit

enum ArrowDirection {
    case top
    case bottom
    case left
    case right
}

class ArrowProjectileView: UIView {
    
    let direction: ArrowDirection
    var arrowIdentifier: String
    
    init(direction: ArrowDirection, identifier: String = UUID().uuidString) {
        self.direction = direction
        self.arrowIdentifier = identifier
        
        super.init(frame: .zero)
        
        setupArrowView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupArrowView() {
        backgroundColor = .clear
        
        // Create arrow shape using CAShapeLayer
        let arrowPath = createArrowPath()
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.cgPath
        // Use a more vibrant red color for better visibility
        arrowLayer.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 2.5
        
        layer.addSublayer(arrowLayer)
        
        // Add enhanced glow effect for better visibility against background
        layer.shadowColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.9
        layer.shadowOffset = .zero
    }
    
    private func createArrowPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width > 0 ? bounds.width : 30
        let height = bounds.height > 0 ? bounds.height : 30
        
        switch direction {
        case .top:
            // Arrow from top moving down - arrow should point downward (tip at bottom)
            path.move(to: CGPoint(x: width / 2, y: height))
            path.addLine(to: CGPoint(x: 0, y: height * 0.7))
            path.addLine(to: CGPoint(x: width / 4, y: height * 0.7))
            path.addLine(to: CGPoint(x: width / 4, y: 0))
            path.addLine(to: CGPoint(x: width * 3 / 4, y: 0))
            path.addLine(to: CGPoint(x: width * 3 / 4, y: height * 0.7))
            path.addLine(to: CGPoint(x: width, y: height * 0.7))
            path.close()
        case .bottom:
            // Arrow from bottom moving up - arrow should point upward (tip at top)
            path.move(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height * 0.3))
            path.addLine(to: CGPoint(x: width / 4, y: height * 0.3))
            path.addLine(to: CGPoint(x: width / 4, y: height))
            path.addLine(to: CGPoint(x: width * 3 / 4, y: height))
            path.addLine(to: CGPoint(x: width * 3 / 4, y: height * 0.3))
            path.addLine(to: CGPoint(x: width, y: height * 0.3))
            path.close()
        case .left:
            // Arrow from left moving right - arrow should point rightward (tip at right)
            path.move(to: CGPoint(x: width, y: height / 2))
            path.addLine(to: CGPoint(x: width * 0.3, y: 0))
            path.addLine(to: CGPoint(x: width * 0.3, y: height / 4))
            path.addLine(to: CGPoint(x: 0, y: height / 4))
            path.addLine(to: CGPoint(x: 0, y: height * 3 / 4))
            path.addLine(to: CGPoint(x: width * 0.3, y: height * 3 / 4))
            path.addLine(to: CGPoint(x: width * 0.3, y: height))
            path.close()
        case .right:
            // Arrow from right moving left - arrow should point leftward (tip at left)
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width * 0.7, y: 0))
            path.addLine(to: CGPoint(x: width * 0.7, y: height / 4))
            path.addLine(to: CGPoint(x: width, y: height / 4))
            path.addLine(to: CGPoint(x: width, y: height * 3 / 4))
            path.addLine(to: CGPoint(x: width * 0.7, y: height * 3 / 4))
            path.addLine(to: CGPoint(x: width * 0.7, y: height))
            path.close()
        }
        
        return path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update arrow path when bounds change
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let arrowPath = createArrowPath()
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = 2.5
        layer.addSublayer(arrowLayer)
    }
    
    func animateArrowLaunch(from startPoint: CGPoint, to endPoint: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        center = startPoint
        alpha = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
                self.center = endPoint
            }) { _ in
                completion()
            }
        }
    }
}

