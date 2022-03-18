//
//  SettingsButtonCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit

final class SettingsButtonCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String) {
        self.id = id
        self.title = title
    }
}
