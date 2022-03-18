//
//  CALayer+SmoothCorner.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import UIKit

extension CALayer {
    func smoothCorner(_ value: CGFloat) {
        cornerRadius = value
        cornerCurve = .continuous
    }
}
