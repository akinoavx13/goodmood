//
//  TemplateCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 15/03/2022.
//

import UIKit.UIImage

final class TemplateCellViewModel {
    
    // MARK: - Properties
    
    let templateId: String
    let isSelected: Bool
    let templateImage: UIImage?
    
    // MARK: - Lifecycle
    
    init(templateId: String,
         selectedTemplate: String?,
         templateImage: UIImage?) {
        self.templateId = templateId
        self.isSelected = templateId == selectedTemplate
        self.templateImage = templateImage
    }
}
