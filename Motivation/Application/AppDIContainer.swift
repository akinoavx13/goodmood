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
    private lazy var notificationService: NotificationServiceProtocol = {
        NotificationService(trackingService: trackingService)
    }()
    
    // MARK: - Methods
    
    lazy var quoteDIContainer: QuoteDIContainer = {
        let dependencies = QuoteDIContainer.Dependencies(databaseService: databaseService,
                                                         trackingService: trackingService,
                                                         preferenceService: preferenceService,
                                                         settingsDIContainer: settingsDIContainer,
                                                         categoryDIContainer: categoryDIContainer)
        
        return QuoteDIContainer(dependencies: dependencies)
    }()
    lazy var onboardingDIContainer: OnboardingDIContainer = {
        let dependencies = OnboardingDIContainer.Dependencies(trackingService: trackingService,
                                                              preferenceService: preferenceService,
                                                              notificationService: notificationService)
        
        return OnboardingDIContainer(dependencies: dependencies)
    }()
    private lazy var settingsDIContainer: SettingsDIContainer = {
        let dependencies = SettingsDIContainer.Dependencies(trackingService: trackingService)
        
        return SettingsDIContainer(dependencies: dependencies)
    }()
    private lazy var categoryDIContainer: CategoryDIContainer = {
        let dependencies = CategoryDIContainer.Dependencies(trackingService: trackingService,
                                                            preferenceService: preferenceService)
        
        return CategoryDIContainer(dependencies: dependencies)
    }()
}
