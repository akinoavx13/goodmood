//
//  OnboardingFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import UIKit

protocol OnboardingFlowCoordinatorDelegate: AnyObject {
    func onboardingFlowCoordinatorWillDismiss(_ sender: OnboardingFlowCoordinator)
}

protocol OnboardingFlowCoordinatorDependencies: AnyObject {
    
    // MARK: - Properties
    
    var paywallDIContainer: PaywallDIContainer { get }
    
    // MARK: - Methods
    
    func makeWelcomeViewController(actions: WelcomeViewModelActions) -> WelcomeViewController
    func makeNotificationViewController(actions: NotificationViewModelActions) -> NotificationViewController
}

final class OnboardingFlowCoordinator {

    // MARK: - Properties
        
    weak var delegate: OnboardingFlowCoordinatorDelegate?
    
    private let parentViewController: UINavigationController
    private let dependencies: OnboardingFlowCoordinatorDependencies
    private let navigationController = UINavigationController()

    // MARK: - Lifecycle
    
    init(parentViewController: UINavigationController,
         dependencies: OnboardingFlowCoordinatorDependencies) {
        self.parentViewController = parentViewController
        self.dependencies = dependencies
        
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Methods
    
    func start() {
        let actions = WelcomeViewModelActions(presentNotification: presentNotification)
        
        DispatchQueue.main.async {
            self.navigationController.setViewControllers([self.dependencies.makeWelcomeViewController(actions: actions)],
                                                         animated: false)
            self.navigationController.modalPresentationStyle = .fullScreen
            
            self.parentViewController.present(self.navigationController, animated: true)
        }
    }
}

// MARK: - OnboardingFlowCoordinator -

extension OnboardingFlowCoordinator {
    
    // MARK: - Private methods
    
    private func presentNotification() {
        let actions = NotificationViewModelActions(presentPaywall: presentPaywall(type:origin:))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let viewController = self.dependencies.makeNotificationViewController(actions: actions)
            
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    private func paywallFlowCoordinator() -> PaywallFlowCoordinator {
        let flow = dependencies
            .paywallDIContainer
            .makePaywallFlowCoordinator(navigationController: navigationController,
                                        paywallDelegate: nil)
        flow.delegate = self
        
        return flow
    }
    
    private func presentPaywall(type: PaywallFlowCoordinator.PaywallType,
                                origin: TrackingService.PaywallOrigin) {
        paywallFlowCoordinator()
            .start(type: type,
                   origin: origin)
    }
}

// MARK: - PaywallFlowCoordinatorDelegate -

extension OnboardingFlowCoordinator: PaywallFlowCoordinatorDelegate {
    func paywallFlowCoordinatorWillDismiss(_ sender: PaywallFlowCoordinator) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.navigationController.dismiss(animated: false)
        }
    }
}
