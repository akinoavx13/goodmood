//
//  SettingsValueCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit

final class SettingsValueCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    let value: String
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String,
         value: String) {
        self.id = id
        self.title = title
        self.value = value
    }
}
