//
//  PreferenceService.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import Foundation

protocol PreferenceServiceProtocol: AnyObject {
    
    // MARK: - Methods
    
    func incrementNbAppOpen()
    func getNbAppOpen() -> Int
    func incrementNbAppLaunch()
    func getNbAppLaunch() -> Int
}

final class PreferenceService: PreferenceServiceProtocol {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    
    private let nbAppOpenKey = "nbAppOpenKey"
    private let nbAppLaunchKey = "nbAppLaunchKey"
    
    // MARK: - Lifecycle
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Methods
    
    func incrementNbAppOpen() {
        let nbAppOpen = getNbAppOpen() + 1
        userDefaults.set(nbAppOpen, forKey: nbAppOpenKey)
        
        if App.env == .debug { print("💾 Increment nb app open, now: \(nbAppOpen)") }
    }

    func getNbAppOpen() -> Int { userDefaults.integer(forKey: nbAppOpenKey) }

    func incrementNbAppLaunch() {
        let nbAppLaunch = getNbAppLaunch() + 1
        userDefaults.set(nbAppLaunch, forKey: nbAppLaunchKey)
        
        if App.env == .debug { print("💾 Increment nb app launch, now: \(nbAppLaunch)") }
    }

    func getNbAppLaunch() -> Int { userDefaults.integer(forKey: nbAppLaunchKey) }
}
