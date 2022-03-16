//
//  SettingsLinkCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 10/01/2022.
//

import UIKit

final class SettingsLinkCellViewModel {
    
    // MARK: - Properties
    
    let id: String
    let title: String
    let iconName: String
    let iconColor: UIColor
    
    // MARK: - Lifecycle
    
    init(id: String,
         title: String,
         iconName: String,
         iconColor: UIColor) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
    }
}
