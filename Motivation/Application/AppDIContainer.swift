//
//  AppDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Methods
    
    func makeQuoteDIContainer() -> QuoteDIContainer {
        let dependencies = QuoteDIContainer.Dependencies()
        
        return QuoteDIContainer(dependencies: dependencies)
    }
}
