//
//  CategoryFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

protocol CategoryFlowCoordinatorDependencies: AnyObject {
    
    // MARK: - Properties
    
    var paywallContainer: PaywallDIContainer { get }

    // MARK: - Methods
    
    func makeCategoryViewController(actions: CategoryViewModelActions) -> CategoryViewController
}

final class CategoryFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    private weak var delegate: CategoryViewControllerDelegate?
    
    private var viewController: UINavigationController!
    private let dependencies: CategoryFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         delegate: CategoryViewControllerDelegate?,
         dependencies: CategoryFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.delegate = delegate
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = CategoryViewModelActions(presentPaywall: presentPaywall(type:origin:))
        
        DispatchQueue.main.async {
            let settingsViewController = self.dependencies.makeCategoryViewController(actions: actions)
            settingsViewController.delegate = self.delegate
            
            self.viewController = UINavigationController(rootViewController: settingsViewController)
            self.viewController.navigationBar.prefersLargeTitles = true
            
            self.navigationController?.present(self.viewController, animated: true)
        }
    }
    
    private func paywallFlowCoordinator() -> PaywallFlowCoordinator {
        dependencies
            .paywallContainer
            .makePaywallFlowCoordinator(navigationController: navigationController,
                                        paywallDelegate: nil)
    }
    
    private func presentPaywall(type: PaywallFlowCoordinator.PaywallType,
                                origin: TrackingService.PaywallOrigin) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            self.paywallFlowCoordinator()
                .start(type: type,
                       origin: origin)
        }
    }
}
