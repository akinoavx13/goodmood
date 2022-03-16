//
//  OnboardingDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import UIKit

final class OnboardingDIContainer {
    
    struct Dependencies {
        let trackingService: TrackingServiceProtocol
        let preferenceService: PreferenceServiceProtocol
        let notificationService: NotificationServiceProtocol
        let quoteService: QuoteServiceProtocol
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeOnboardingFlowCoordinator(parentViewController: UINavigationController) -> OnboardingFlowCoordinator {
        OnboardingFlowCoordinator(parentViewController: parentViewController,
                                  dependencies: self)
    }
    
    // MARK: - Private methods
    
    private func makeWelcomeViewModel(actions: WelcomeViewModelActions) -> WelcomeViewModelProtocol {
        WelcomeViewModel(actions: actions,
                         trackingService: dependencies.trackingService)
    }
    
    private func makeNotificationViewModel(actions: NotificationViewModelActions) -> NotificationViewModelProtocol {
        NotificationViewModel(actions: actions,
                              trackingService: dependencies.trackingService,
                              preferenceService: dependencies.preferenceService,
                              notificationService: dependencies.notificationService,
                              quoteService: dependencies.quoteService)
    }
}

// MARK: - OnboardingFlowCoordinatorDependencies -

extension OnboardingDIContainer: OnboardingFlowCoordinatorDependencies {
    func makeWelcomeViewController(actions: WelcomeViewModelActions) -> WelcomeViewController {
        WelcomeViewController.create(with: makeWelcomeViewModel(actions: actions))
    }
    
    func makeNotificationViewController(actions: NotificationViewModelActions) -> NotificationViewController {
        NotificationViewController.create(with: makeNotificationViewModel(actions: actions))
    }
}
