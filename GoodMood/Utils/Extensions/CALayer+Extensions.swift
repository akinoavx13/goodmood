//
//  CALayer+SmoothCorner.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import UIKit

extension CALayer {
    
    static func gradient(_ size: CGSize,
                         colors: [UIColor],
                         startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
                         endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        return gradient
    }
    
    func smoothCorner(_ value: CGFloat) {
        cornerRadius = value
        cornerCurve = .continuous
    }
}
