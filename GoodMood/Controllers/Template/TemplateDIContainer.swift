//
//  TemplateDIContainer.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import UIKit

final class TemplateDIContainer {
    
    struct Dependencies {
        let trackingService: TrackingServiceProtocol
        let preferenceService: PreferenceServiceProtocol
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    
    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeTemplateFlowCoordinator(navigationController: UINavigationController,
                                     delegate: TemplateViewControllerDelegate?) -> TemplateFlowCoordinator {
        TemplateFlowCoordinator(navigationController: navigationController,
                                delegate: delegate,
                                dependencies: self)
    }
    
    // MARK: - Private methods
    
    private func makeTemplateViewModel(actions: TemplateViewModelActions) -> TemplateViewModelProtocol {
        TemplateViewModel(actions: actions,
                          trackingService: dependencies.trackingService,
                          preferenceService: dependencies.preferenceService)
    }
}

// MARK: - TemplateFlowCoordinatorDependencies -

extension TemplateDIContainer: TemplateFlowCoordinatorDependencies {
    func makeTemplateViewController(actions: TemplateViewModelActions) -> TemplateViewController {
        TemplateViewController.create(with: makeTemplateViewModel(actions: actions))
    }
}
