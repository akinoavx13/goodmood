//
//  NotificationViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

import RxSwift
import RxCocoa
import Foundation

struct NotificationViewModelActions {
    let dismiss: () -> Void
}

protocol NotificationViewModelProtocol: AnyObject {

    // MARK: - Properties
    
    var nbTimes: BehaviorRelay<Int> { get }
    var startAt: BehaviorRelay<Date> { get }
    var endAt: BehaviorRelay<Date> { get }
    var isNextButtonEnabled: BehaviorRelay<Bool> { get }
    
    // MARK: - Methods
    
    func viewDidAppear()
    func nextButtonDidTap() async
    func update(nbTimes: Double)
    func update(startAt: Date)
    func update(endAt: Date)
}

final class NotificationViewModel: NotificationViewModelProtocol {
    
    // MARK: - Properties
    
    let nbTimes: BehaviorRelay<Int>
    let startAt: BehaviorRelay<Date>
    let endAt: BehaviorRelay<Date>
    let isNextButtonEnabled: BehaviorRelay<Bool> = .init(value: true)
    
    private let actions: NotificationViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let quoteService: QuoteServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: NotificationViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol,
         notificationService: NotificationServiceProtocol,
         quoteService: QuoteServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        self.notificationService = notificationService
        self.quoteService = quoteService
        
        self.nbTimes = .init(value: preferenceService.getNbTimesNotif())
        self.startAt = .init(value: preferenceService.getStartAtTime())
        self.endAt = .init(value: preferenceService.getEndAtTime())
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showNotification, eventProperties: nil)
    }
    
    func nextButtonDidTap() async {
        let isGranted = await notificationService.requestAuthorization()
        
        trackingService.set(userProperty: .nbTimesShowLikeApp, value: NSNumber(value: nbTimes.value))
        trackingService.track(event: .closeOnboarding, eventProperties: nil)
        
        await quoteService.triggerNotificationsIfNeeded()
        
        preferenceService.save(isNotificationEnabled: isGranted)
        preferenceService.onboardingSeen()
        
        actions.dismiss()
    }
    
    func update(nbTimes: Double) {
        self.nbTimes.accept(Int(nbTimes))
        
        preferenceService.save(nbTimesNotif: self.nbTimes.value)
    }
    
    func update(startAt: Date) {
        self.startAt.accept(startAt)
        isNextButtonEnabled.accept(self.startAt.value.timeIntervalSince1970 < self.endAt.value.timeIntervalSince1970)
        
        if isNextButtonEnabled.value {
            preferenceService.save(startAt: startAt)
        }
    }
    
    func update(endAt: Date) {
        self.endAt.accept(endAt)
        isNextButtonEnabled.accept(self.startAt.value.timeIntervalSince1970 < self.endAt.value.timeIntervalSince1970)
        
        if isNextButtonEnabled.value {
            preferenceService.save(endAt: endAt)
        }
    }
}
