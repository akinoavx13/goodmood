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
    lazy var trackingService: TrackingServiceProtocol = {
        TrackingService()
    }()
    lazy var preferenceService: PreferenceServiceProtocol = {
        PreferenceService()
    }()
    
    // MARK: - Methods
    
    func makeQuoteDIContainer() -> QuoteDIContainer {
        let dependencies = QuoteDIContainer.Dependencies(databaseService: databaseService,
                                                         trackingService: trackingService)
        
        return QuoteDIContainer(dependencies: dependencies)
    }
}
