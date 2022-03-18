//
//  PaywallDIContainer.swift
//  GoodMood
//
//  Created by Maxime Maheo on 20/12/2021.
//

import UIKit

final class PaywallDIContainer {
    
    struct Dependencies {
        let trackingService: TrackingServiceProtocol
        let purchaseService: PurchaseServiceProtocol
        let formatterService: FormatterServiceProtocol
        let notificationService: NotificationServiceProtocol
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makePaywallFlowCoordinator(navigationController: UINavigationController?,
                                    paywallDelegate: PaywallViewControllerDelegate?) -> PaywallFlowCoordinator {
        PaywallFlowCoordinator(navigationController: navigationController,
                               dependencies: self,
                               paywallDelegate: paywallDelegate)
    }
    
    // MARK: - Private methods
    
    private func makeStartPaywallViewModel(actions: PaywallStartViewModelActions,
                                           origin: TrackingService.PaywallOrigin,
                                           type: PaywallFlowCoordinator.PaywallType) -> PaywallStartViewModelProtocol {
        PaywallStartViewModel(actions: actions,
                              origin: origin,
                              type: type,
                              trackingService: dependencies.trackingService,
                              purchaseService: dependencies.purchaseService,
                              formatterService: dependencies.formatterService,
                              notificationService: dependencies.notificationService)
    }
}

// MARK: - PaywallFlowCoordinatorDependencies -

extension PaywallDIContainer: PaywallFlowCoordinatorDependencies {
    func makeStartPaywallViewController(actions: PaywallStartViewModelActions,
                                        origin: TrackingService.PaywallOrigin,
                                        type: PaywallFlowCoordinator.PaywallType) -> PaywallStartViewController {
        PaywallStartViewController.create(with: makeStartPaywallViewModel(actions: actions,
                                                                          origin: origin,
                                                                          type: type))
    }
}
