//
//  SKProductSubscriptionPeriod+Extensions.swift
//  GoodMood
//
//  Created by Maxime Maheo on 18/03/2022.
//

import Purchases

extension SKProductSubscriptionPeriod {
    
    // MARK: - Properties
    
    var periodTitle: String {
        switch unit {
        case .day:
            if numberOfUnits > 1 {
                return "\(numberOfUnits) \(R.string.localizable.days())"
            }
            
            return R.string.localizable.day()
        case .week:
            if numberOfUnits > 1 {
                return "\(numberOfUnits) \(R.string.localizable.weeks())"
            }
            
            return R.string.localizable.week()
        case .month:
            if numberOfUnits > 1 {
                return "\(numberOfUnits) \(R.string.localizable.months())"
            }
            
            return R.string.localizable.month()
        case .year:
            if numberOfUnits > 1 {
                return "\(numberOfUnits) \(R.string.localizable.years())"
            }
            
            return R.string.localizable.year()
        default: return R.string.localizable.unknown()
        }
    }
}
