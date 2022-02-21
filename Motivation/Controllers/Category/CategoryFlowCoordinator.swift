//
//  CategoryFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

protocol CategoryFlowCoordinatorDependencies: AnyObject {
    func makeCategoryViewController(actions: CategoryViewModelActions) -> CategoryViewController
}

final class CategoryFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    private var viewController: UINavigationController!
    private let dependencies: CategoryFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: CategoryFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = CategoryViewModelActions()
        
        DispatchQueue.main.async {
            let settingsViewController = self.dependencies.makeCategoryViewController(actions: actions)
            self.viewController = UINavigationController(rootViewController: settingsViewController)
            self.viewController.navigationBar.prefersLargeTitles = true
            
            self.navigationController?.present(self.viewController, animated: true)
        }
    }
}
