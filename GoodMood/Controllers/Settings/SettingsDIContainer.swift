//
//  SettingsDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 18/12/2021.
//

import UIKit

final class SettingsDIContainer {
    
    struct Dependencies {
        let trackingService: TrackingServiceProtocol
        let preferenceService: PreferenceServiceProtocol
        let notificationService: NotificationServiceProtocol
        let quoteService: QuoteServiceProtocol
        let purchaseService: PurchaseServiceProtocol
        let paywallContainer: PaywallDIContainer
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeSettingsFlowCoordinator(navigationController: UINavigationController) -> SettingsFlowCoordinator {
        SettingsFlowCoordinator(navigationController: navigationController,
                                dependencies: self)
    }
        
    // MARK: - Private methods
    
    private func makeSettingsViewModel(actions: SettingsViewModelActions) -> SettingsViewModelProtocol {
        SettingsViewModel(actions: actions,
                          trackingService: dependencies.trackingService,
                          preferenceService: dependencies.preferenceService,
                          notificationService: dependencies.notificationService,
                          quoteService: dependencies.quoteService,
                          purchaseService: dependencies.purchaseService)
    }
    
}

// MARK: - SettingsFlowCoordinatorDependencies -

extension SettingsDIContainer: SettingsFlowCoordinatorDependencies {
    
    // MARK: - Methods
    
    var paywallContainer: PaywallDIContainer {
        dependencies.paywallContainer
    }
    
    // MARK: - Methods
    
    func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController {
        SettingsViewController.create(with: makeSettingsViewModel(actions: actions))
    }
}
