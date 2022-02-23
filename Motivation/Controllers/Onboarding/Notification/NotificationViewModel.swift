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
    
    private let actions: NotificationViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: NotificationViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        self.notificationService = notificationService
        
        self.nbTimes = .init(value: preferenceService.getNbTimesNotif())
        self.startAt = .init(value: preferenceService.getStartAtTime())
        self.endAt = .init(value: preferenceService.getEndAtTime())
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showNotification, eventProperties: nil)
    }
    
    func nextButtonDidTap() async {
        await notificationService.requestAuthorization()
        
        trackingService.set(userProperty: .nbTimesShowLikeApp, value: NSNumber(value: nbTimes.value))
        trackingService.track(event: .closeOnboarding, eventProperties: nil)

        preferenceService.onboardingSeen()
        
        actions.dismiss()
    }
    
    func update(nbTimes: Double) {
        self.nbTimes.accept(Int(nbTimes))
        
        preferenceService.save(nbTimesNotif: self.nbTimes.value)
    }
    
    func update(startAt: Date) {
        self.startAt.accept(startAt)
        
        preferenceService.save(startAt: startAt)
    }
    
    func update(endAt: Date) {
        self.endAt.accept(endAt)
        
        preferenceService.save(endAt: endAt)
    }
}
