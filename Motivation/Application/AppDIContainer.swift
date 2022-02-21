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
    
    lazy var quoteDIContainer: QuoteDIContainer = {
        let dependencies = QuoteDIContainer.Dependencies(databaseService: databaseService,
                                                         trackingService: trackingService,
                                                         settingsDIContainer: settingsDIContainer)
        
        return QuoteDIContainer(dependencies: dependencies)
    }()
    
    private lazy var settingsDIContainer: SettingsDIContainer = {
        let dependencies = SettingsDIContainer.Dependencies(trackingService: trackingService)
        
        return SettingsDIContainer(dependencies: dependencies)
    }()
}
