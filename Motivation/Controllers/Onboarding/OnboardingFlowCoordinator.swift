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
    func makeWelcomeViewController(actions: WelcomeViewModelActions) -> WelcomeViewController
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
    }

    // MARK: - Methods
    
    func start() {
        let actions = WelcomeViewModelActions()
        
        DispatchQueue.main.async {
            self.navigationController.setViewControllers([self.dependencies.makeWelcomeViewController(actions: actions)],
                                                         animated: false)
            self.navigationController.modalPresentationStyle = .fullScreen
            
            self.parentViewController.present(self.navigationController, animated: true)
        }
    }
}
