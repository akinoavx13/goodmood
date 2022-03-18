//
//  TrackingService.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import Amplitude

protocol TrackingServiceProtocol: AnyObject {
    func track(event: TrackingService.Event, eventProperties: [String: String])
    func track(event: TrackingService.Event, eventProperties: [TrackingService.EventProperty: Any]?)
    func setOnce(userProperty: TrackingService.UserProperty, value: NSObject)
    func set(userProperty: TrackingService.UserProperty, value: NSObject)
    func increment(userProperty: TrackingService.UserProperty, value: Int)
}

final class TrackingService: TrackingServiceProtocol {
    
    enum Event: String, RawRepresentable {
        case openApp,
             appLaunch,
             rateApp,
             declineRateApp,
             showRatePopup,
             purchasePromotedIAP,
             restore,
             showPaywall,
             purchase,
             closePaywall,
             termsOfUse,
             privacyPolicy
        
        case showWelcome,
             showNotification,
             closeOnboarding
        
        case showQuoteScreen,
             showNextQuote
        
        case showCategories,
             selectCategory
        
        case showTemplate,
             selectTemplate
        
        case showSettings,
             writeReview,
             shareApp,
             sendFeedback,
             helpTranslateApp,
             updateStartAt,
             updateEndAt,
             updateNbNotifPerDay
    }
    
    enum EventProperty: String, RawRepresentable {
        case name,
             hasSucceed,
             category,
             templateId,
             origin,
             paywallType
    }

    enum PaywallOrigin: String, RawRepresentable {
        case settings, appLaunch
    }

    enum UserProperty: String, RawRepresentable {
        case nbTimesShowLikeApp,
             nbNotifPerDay,
             hasNotificationEnabled,
             nbQuotesShown,
             hasActiveSubscription
    }
    
    // MARK: - Properties
    
    private let amplitude: Amplitude?

    // MARK: - Lifecycle
    
    init() {
        if App.env == .appStore {
            amplitude = Amplitude.instance()
            
            amplitude?.trackingSessionEvents = true
            amplitude?.initializeApiKey(Constants.amplitudeApiKey,
                                        userId: UserIdentifierManager.shared.userId)
        } else {
            amplitude = nil
        }
    }
    
    // MARK: - Methods
    
    func track(event: Event, eventProperties: [String: String]) {
        if App.env == .appStore {
            amplitude?.logEvent(event.rawValue, withEventProperties: eventProperties)
        } else {
            print("✍️ Track \(event) with \(eventProperties)")
        }
    }
    
    func track(event: Event, eventProperties: [EventProperty: Any]?) {
        let eventPropertiesProcessed = eventProperties?.map({ (key: EventProperty, value: Any) in (key.rawValue, value) })
        
        if App.env == .appStore {
            guard let eventPropertiesProcessed = eventPropertiesProcessed else {
                amplitude?.logEvent(event.rawValue)
                return
            }
            
            let parameters = Dictionary(uniqueKeysWithValues: eventPropertiesProcessed)
            amplitude?.logEvent(event.rawValue, withEventProperties: parameters)
        } else {
            print("✍️ Track \(event) with \(eventPropertiesProcessed ?? [])")
        }
    }
    
    func setOnce(userProperty: UserProperty, value: NSObject) {
        if App.env == .appStore {
            amplitude?.identify(AMPIdentify().setOnce(userProperty.rawValue, value: value))
        } else {
            print("✍️ Set once \(userProperty) to \(value)")
        }
    }
    
    func set(userProperty: UserProperty, value: NSObject) {
        if App.env == .appStore {
            amplitude?.identify(AMPIdentify().set(userProperty.rawValue, value: value))
        } else {
            print("✍️ Set user property \(userProperty) to \(value)")
        }
    }
    
    func increment(userProperty: UserProperty, value: Int) {
        if App.env == .appStore {
            amplitude?.identify(AMPIdentify().add(userProperty.rawValue, value: NSNumber(value: value)))
        } else {
            print("✍️ Increment \(userProperty) by \(value)")
        }
    }
}
