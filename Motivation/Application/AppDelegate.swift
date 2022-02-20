//
//  AppDelegate.swift
//  Motivation
//
//  Created by Maxime Maheo on 19/02/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    
    private let appDIContainer = AppDIContainer()
    private var appFlowCoordinator: AppFlowCoordinator?
    
    // MARK: - Methods
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        
        window?.rootViewController = navigationController
        
        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
                                                appDIContainer: appDIContainer)
        appFlowCoordinator?.start()
        
        window?.makeKeyAndVisible()
                
        return true
    }
}
