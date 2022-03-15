//
//  TemplateCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 15/03/2022.
//

final class TemplateCellViewModel {
    
    // MARK: - Properties
    
    let templateImage: TemplateViewModel.TemplateImage
    let isSelected: Bool
    
    // MARK: - Lifecycle
    
    init(templateImage: TemplateViewModel.TemplateImage,
         selectedTemplate: String?) {
        self.templateImage = templateImage
        self.isSelected = templateImage.rawValue == selectedTemplate
    }
}
