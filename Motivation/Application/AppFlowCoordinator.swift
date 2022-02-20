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
        let quoteDIContainer = appDIContainer.makeQuoteDIContainer()
        let flow = quoteDIContainer.makeQuoteFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
