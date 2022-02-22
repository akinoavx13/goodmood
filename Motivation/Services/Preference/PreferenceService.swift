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
    func save(selectedCategory: RMQuote.RMCategory)
    func getSelectedCategory() -> RMQuote.RMCategory
    func appWasRated()
    func hasRateApp() -> Bool
}

final class PreferenceService: PreferenceServiceProtocol {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    
    private let nbAppOpenKey = "nbAppOpenKey"
    private let nbAppLaunchKey = "nbAppLaunchKey"
    private let selectedCategoryKey = "selectedCategoryKey"
    private let hasRateAppKey = "hasRateAppKey"

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
    
    func save(selectedCategory: RMQuote.RMCategory) {
        userDefaults.set(selectedCategory.rawValue, forKey: selectedCategoryKey)
        
        if App.env == .debug { print("💾 Save selected category, now: \(selectedCategory.rawValue)") }
    }
    
    func getSelectedCategory() -> RMQuote.RMCategory {
        guard let selectedCategory = userDefaults.string(forKey: selectedCategoryKey) else { return .general }
        
        return RMQuote.RMCategory(rawValue: selectedCategory) ?? .general
    }
    
    func appWasRated() {
        userDefaults.set(true, forKey: hasRateAppKey)
        
        if App.env == .debug { print("💾 App was rated") }
    }
    
    func hasRateApp() -> Bool { userDefaults.bool(forKey: hasRateAppKey) }
}
