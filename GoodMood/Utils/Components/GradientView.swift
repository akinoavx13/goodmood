//
//  GradientView.swift
//  The Weather
//
//  Created by Maxime Maheo on 06/12/2021.
//

import UIKit

final class GradientView: UIView {

    enum GradientType: Equatable {
        case none
        case aqi
        case custom(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint)
        
        // MARK: - Methods
        
        static func == (lhs: GradientType, rhs: GradientType) -> Bool {
            switch (lhs, rhs) {
            case (let .custom(lhsColors, lhsStartPoint, lhsEndPoint), let .custom(rhsColors, rhsStartPoint, rhsEndPoint)):
                return lhsColors == rhsColors && lhsStartPoint == rhsStartPoint && lhsEndPoint == rhsEndPoint
            default:
                return String(describing: lhs) == String(describing: rhs)
            }
        }
        
        func layer(for size: CGSize) -> CAGradientLayer? {
            switch self {
            case .none: return nil
            case .aqi: return CAGradientLayer.gradient(size,
                                                       colors: [.init(hex: 0x4793e4),
                                                                .init(hex: 0x69da74),
                                                                .init(hex: 0xf5da51),
                                                                .init(hex: 0xed9147),
                                                                .init(hex: 0xc42f48),
                                                                .init(hex: 0x78203c),
                                                                .init(hex: 0x9b1eee)],
                                                       startPoint: CGPoint(x: 0, y: 0.5),
                                                       endPoint: CGPoint(x: 1, y: 0.5))
            case let .custom(colors, startPoint, endPoint): return CAGradientLayer.gradient(size,
                                                                                            colors: colors,
                                                                                            startPoint: startPoint,
                                                                                            endPoint: endPoint)
            }
        }
    }
    
    // MARK: - Properties
    
    var type: GradientType = .none
    
    // swiftlint:disable:next large_tuple
    private var currentGradientLayer: (type: GradientType, size: CGSize, layer: CAGradientLayer)?

    // MARK: - Lifecycle
    
    init(type: GradientType,
         frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.type = type
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureGradient()
    }
    
    // MARK: - Methods

    func needRender() {
        configureGradient(force: true)
    }

    // MARK: - Private Methods

    private func configureGradient(force: Bool = false) {
        let currentSize = currentGradientLayer?.size ?? .zero
        
        guard force ||
              currentSize != frame.size ||
              type != currentGradientLayer?.type
        else { return }
        
        if type != currentGradientLayer?.type || force {
            currentGradientLayer?.layer.removeFromSuperlayer()
            
            guard let gradientLayer = type.layer(for: frame.size) else {
                currentGradientLayer = nil
                return
            }
            
            layer.insertSublayer(gradientLayer, at: 0)
            currentGradientLayer = (type: type, size: frame.size, layer: gradientLayer)
        } else if let currentLayer = currentGradientLayer?.layer {
            currentGradientLayer?.layer.frame = CGRect(origin: .zero, size: frame.size)
            currentGradientLayer = (type: type, size: frame.size, layer: currentLayer)
        }
    }
}
