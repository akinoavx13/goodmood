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
    func hasSeenOnboarding() -> Bool
    func onboardingSeen()
    func getStartAtTime() -> Date
    func save(startAt: Date)
    func getEndAtTime() -> Date
    func save(endAt: Date)
    func getNbTimesNotif() -> Int
    func save(nbTimesNotif: Int)
    func isNotificationEnabled() -> Bool
    func save(isNotificationEnabled: Bool)
}

final class PreferenceService: PreferenceServiceProtocol {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    
    private let nbAppOpenKey = "nbAppOpenKey"
    private let nbAppLaunchKey = "nbAppLaunchKey"
    private let selectedCategoryKey = "selectedCategoryKey"
    private let hasRateAppKey = "hasRateAppKey"
    private let hasSeenOnboardingKey = "hasSeenOnboardingKey"
    private let startAtTimeKey = "startAtTimeKey"
    private let endAtTimeKey = "endAtTimeKey"
    private let nbTimesNotifKey = "nbTimesNotifKey"
    private let isNotificationEnabledKey = "isNotificationEnabledKey"

    // MARK: - Lifecycle
    
    init(userDefaults: UserDefaults = UserDefaults.standard,
         calendar: Calendar = Calendar.current) {
        self.userDefaults = userDefaults
        self.calendar = calendar
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
    
    func hasSeenOnboarding() -> Bool { userDefaults.bool(forKey: hasSeenOnboardingKey) }
    
    func onboardingSeen() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        
        if App.env == .debug { print("💾 Has seen onboarding") }
    }
    
    func getStartAtTime() -> Date {
        let timeIntervalSince1970 = userDefaults.double(forKey: startAtTimeKey)
        
        guard timeIntervalSince1970 > 0 else { return getDate(hour: 8) }
        
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
    
    func save(startAt: Date) {
        if App.env == .debug {
            print("💾 Update start at time to \(startAt)")
        }
        
        userDefaults.set(startAt.timeIntervalSince1970, forKey: startAtTimeKey)
    }
    
    func getEndAtTime() -> Date {
        let timeIntervalSince1970 = userDefaults.double(forKey: endAtTimeKey)
        
        guard timeIntervalSince1970 > 0 else { return getDate(hour: 20) }
        
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
    
    func save(endAt: Date) {
        if App.env == .debug {
            print("💾 Update end at time to \(endAt)")
        }
        
        userDefaults.set(endAt.timeIntervalSince1970, forKey: endAtTimeKey)
    }
    
    func getNbTimesNotif() -> Int {
        let nbTimesNotif = userDefaults.integer(forKey: nbTimesNotifKey)
        
        if nbTimesNotif == 0 { return 12 }
        
        return nbTimesNotif
    }
    
    func save(nbTimesNotif: Int) {
        if App.env == .debug {
            print("💾 Update nb times notif to \(nbTimesNotif)")
        }
        
        userDefaults.set(nbTimesNotif, forKey: nbTimesNotifKey)
    }
    
    func isNotificationEnabled() -> Bool { userDefaults.bool(forKey: isNotificationEnabledKey) }
    
    func save(isNotificationEnabled: Bool) {
        if App.env == .debug {
            print("💾 Update is notification enabled to \(isNotificationEnabled)")
        }
        
        userDefaults.set(isNotificationEnabled, forKey: isNotificationEnabledKey)
    }
    
    // MARK: - Private methods
    
    private func getDate(hour: Int) -> Date {
        let date = Date()
        let dateComponents = date.get(.day, .month, .year, calendar: calendar)
        
        guard let day = dateComponents.day,
              let month = dateComponents.month,
              let year = dateComponents.year
        else { return date }
        
        let triggerComponents = DateComponents(year: year, month: month, day: day, hour: hour)
        
        return calendar.date(from: triggerComponents) ?? date
    }
}
