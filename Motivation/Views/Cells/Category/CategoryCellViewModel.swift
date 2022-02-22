//
//  CategoryCellViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

final class CategoryCellViewModel {
    
    // MARK: - Properties
    
    let name: String
    let isSelected: Bool
    
    // MARK: - Lifecycle
    
    init(name: String,
         isSelected: Bool) {
        self.name = name
        self.isSelected = isSelected
    }
}
