//
//  AppDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Services
    
    lazy var trackingService: TrackingServiceProtocol = {
        TrackingService()
    }()
    lazy var preferenceService: PreferenceServiceProtocol = {
        PreferenceService()
    }()
    lazy var quoteService: QuoteServiceProtocol = {
        QuoteService(databaseService: databaseService,
                     notificationService: notificationService,
                     preferenceService: preferenceService)
    }()
    
    private lazy var databaseService: DatabaseServiceProtocol = {
        DatabaseService()
    }()
    private lazy var notificationService: NotificationServiceProtocol = {
        NotificationService(trackingService: trackingService,
                            preferenceService: preferenceService)
    }()
    
    // MARK: - Containers
    
    lazy var quoteDIContainer: QuoteDIContainer = {
        let dependencies = QuoteDIContainer.Dependencies(databaseService: databaseService,
                                                         trackingService: trackingService,
                                                         preferenceService: preferenceService,
                                                         settingsDIContainer: settingsDIContainer,
                                                         categoryDIContainer: categoryDIContainer,
                                                         templateDIContainer: templateDIContainer)
        
        return QuoteDIContainer(dependencies: dependencies)
    }()
    lazy var onboardingDIContainer: OnboardingDIContainer = {
        let dependencies = OnboardingDIContainer.Dependencies(trackingService: trackingService,
                                                              preferenceService: preferenceService,
                                                              notificationService: notificationService,
                                                              quoteService: quoteService)
        
        return OnboardingDIContainer(dependencies: dependencies)
    }()
    
    private lazy var settingsDIContainer: SettingsDIContainer = {
        let dependencies = SettingsDIContainer.Dependencies(trackingService: trackingService,
                                                            preferenceService: preferenceService,
                                                            notificationService: notificationService,
                                                            quoteService: quoteService)
        
        return SettingsDIContainer(dependencies: dependencies)
    }()
    private lazy var categoryDIContainer: CategoryDIContainer = {
        let dependencies = CategoryDIContainer.Dependencies(trackingService: trackingService,
                                                            preferenceService: preferenceService,
                                                            quoteService: quoteService)
        
        return CategoryDIContainer(dependencies: dependencies)
    }()
    private lazy var templateDIContainer: TemplateDIContainer = {
        let dependencies = TemplateDIContainer.Dependencies()
        
        return TemplateDIContainer(dependencies: dependencies)
    }()
}
