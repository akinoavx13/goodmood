//
//  TemplateCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 15/03/2022.
//

final class TemplateCellViewModel {
    
    // MARK: - Properties
    
    let templateId: String
    let isSelected: Bool
    
    // MARK: - Lifecycle
    
    init(templateId: String,
         selectedTemplate: String?) {
        self.templateId = templateId
        self.isSelected = templateId == selectedTemplate
    }
}
