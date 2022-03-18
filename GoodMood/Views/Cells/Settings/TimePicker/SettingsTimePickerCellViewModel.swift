//
//  SettingsTimePickerCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import Foundation

final class SettingsTimePickerCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    let date: Date
    let isDisabled: Bool
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String,
         date: Date,
         isDisabled: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.isDisabled = isDisabled
    }
}
