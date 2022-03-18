//
//  AppDelegate.swift
//  Motivation
//
//  Created by Maxime Maheo on 19/02/2022.
//

import UIKit
import Bugsnag
import Purchases

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    
    private let appDIContainer = AppDIContainer()
    private var appFlowCoordinator: AppFlowCoordinator?
    
    // MARK: - Methods
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if App.env == .appStore {
            Bugsnag.start()
            Bugsnag.setUser(UserIdentifierManager.shared.userId,
                            withEmail: nil,
                            andName: nil)
        }
        
        Purchases.configure(withAPIKey: Constants.revenueCatApiKey,
                            appUserID: UserIdentifierManager.shared.userId)
        
        if App.env == .debug {
            Purchases.logLevel = .error
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        
        window?.rootViewController = navigationController
        
        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
                                                appDIContainer: appDIContainer)
        appFlowCoordinator?.start()
        
        window?.makeKeyAndVisible()
                
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appFlowCoordinator?.applicationDidBecomeActive()
    }
}
