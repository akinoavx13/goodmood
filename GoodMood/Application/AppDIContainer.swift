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
    private lazy var purchaseService: PurchaseServiceProtocol = {
        PurchaseService(trackingService: trackingService,
                        preferenceService: preferenceService)
    }()
    private lazy var formatterService: FormatterServiceProtocol = {
        FormatterService()
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
                                                            quoteService: quoteService,
                                                            purchaseService: purchaseService,
                                                            paywallContainer: paywallDIContainer)
        
        return SettingsDIContainer(dependencies: dependencies)
    }()
    private lazy var categoryDIContainer: CategoryDIContainer = {
        let dependencies = CategoryDIContainer.Dependencies(trackingService: trackingService,
                                                            preferenceService: preferenceService,
                                                            quoteService: quoteService)
        
        return CategoryDIContainer(dependencies: dependencies)
    }()
    private lazy var templateDIContainer: TemplateDIContainer = {
        let dependencies = TemplateDIContainer.Dependencies(trackingService: trackingService,
                                                            preferenceService: preferenceService,
                                                            paywallContainer: paywallDIContainer,
                                                            purchaseService: purchaseService)
        
        return TemplateDIContainer(dependencies: dependencies)
    }()
    private(set) lazy var paywallDIContainer: PaywallDIContainer = {
        let dependencies = PaywallDIContainer.Dependencies(trackingService: trackingService,
                                                           purchaseService: purchaseService,
                                                           formatterService: formatterService,
                                                           notificationService: notificationService)
        
        return PaywallDIContainer(dependencies: dependencies)
    }()
}
