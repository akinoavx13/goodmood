//
//  AppFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class AppFlowCoordinator {

    // MARK: - Properties
    
    private let navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    // MARK: - Methods
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
        appDIContainer.trackingService.track(event: .appLaunch, eventProperties: nil)
        appDIContainer.preferenceService.incrementNbAppLaunch()
        
        appDIContainer
            .quoteDIContainer
            .makeQuoteFlowCoordinator(navigationController: navigationController)
            .start()
        
        startOnboardingIfNeeded()
        
        if appDIContainer.preferenceService.hasSeenOnboarding() {
            Task {
                await appDIContainer.quoteService.triggerNotificationsIfNeeded(nbDays: 14)
            }
        }
    }
    
    func applicationDidBecomeActive() {
        appDIContainer.trackingService.track(event: .openApp, eventProperties: nil)
        appDIContainer.preferenceService.incrementNbAppOpen()
    }
    
    // MARK: - Methods
    
    private func startOnboardingIfNeeded() {
        guard !appDIContainer.preferenceService.hasSeenOnboarding() else { return }

        appDIContainer
            .onboardingDIContainer
            .makeOnboardingFlowCoordinator(parentViewController: navigationController)
            .start()
    }
}
