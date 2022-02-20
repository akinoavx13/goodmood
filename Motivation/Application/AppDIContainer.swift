//
//  AppDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Properties
    
    private lazy var databaseService: DatabaseServiceProtocol = {
        DatabaseService()
    }()
    
    // MARK: - Methods
    
    func makeQuoteDIContainer() -> QuoteDIContainer {
        let dependencies = QuoteDIContainer.Dependencies(databaseService: databaseService)
        
        return QuoteDIContainer(dependencies: dependencies)
    }
}
