//
//  SettingsStepperCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import Foundation

final class SettingsStepperCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    let subtitle: String
    let value: Double
    let min: Double
    let max: Double
    let step: Double
    let isDisabled: Bool
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String,
         subtitle: String,
         value: Double,
         min: Double,
         max: Double,
         step: Double,
         isDisabled: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.min = min
        self.max = max
        self.step = step
        self.isDisabled = isDisabled
    }
}
