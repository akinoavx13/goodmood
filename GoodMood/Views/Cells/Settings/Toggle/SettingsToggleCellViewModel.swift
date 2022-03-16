//
//  SettingsToggleCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

final class SettingsToggleCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    let subtitle: String
    let isOn: Bool
    let isDisabled: Bool
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String,
         subtitle: String,
         isOn: Bool,
         isDisabled: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
        self.isDisabled = isDisabled
    }
}
