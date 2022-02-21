//
//  AnimationButton.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import UIKit

final class AnimateButton: UIButton {
    
    // MARK: - Properties
    
    static let defaultDamping: CGFloat = 0.6
    static let defaultVelocity: CGFloat = 0.6
    static let defaultDuration: Double = 0.4
    static let defaultScale: CGFloat = 0.95
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: damping,
                           initialSpringVelocity: velocity,
                           options: [.curveEaseOut, .allowUserInteraction],
                           animations: { [weak self] in
                guard let self = self else { return }
                
                var identity = CGAffineTransform.identity
                identity = identity.translatedBy(x: self.transform.tx,
                                                 y: self.transform.ty)
                
                if self.isHighlighted {
                    identity = identity.scaledBy(x: self.scale,
                                                 y: self.scale)
                }
                
                self.transform = identity
            })
        }
    }
    
    @IBInspectable var damping: CGFloat = AnimateButton.defaultDamping
    @IBInspectable var velocity: CGFloat = AnimateButton.defaultVelocity
    @IBInspectable var duration: Double = AnimateButton.defaultDuration
    @IBInspectable var scale: CGFloat = AnimateButton.defaultScale
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Lifecycle
    
    required init(damping: CGFloat = AnimateButton.defaultDamping,
                  velocity: CGFloat = AnimateButton.defaultVelocity,
                  duration: Double = AnimateButton.defaultDuration,
                  scale: CGFloat = AnimateButton.defaultScale) {
        self.damping = damping
        self.velocity = velocity
        self.duration = duration
        self.scale = scale
        
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
