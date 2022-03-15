//
//  TemplateFlowCoordinator.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

protocol TemplateFlowCoordinatorDependencies: AnyObject {
    func makeTemplateViewController(actions: TemplateViewModelActions) -> TemplateViewController
}

final class TemplateFlowCoordinator {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    
    private var viewController: UINavigationController!
    private let dependencies: TemplateFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: TemplateFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = TemplateViewModelActions()
        
        DispatchQueue.main.async {
            let settingsViewController = self.dependencies.makeTemplateViewController(actions: actions)
            
            self.viewController = UINavigationController(rootViewController: settingsViewController)
            self.viewController.navigationBar.prefersLargeTitles = true
            
            self.navigationController?.present(self.viewController, animated: true)
        }
    }
}
