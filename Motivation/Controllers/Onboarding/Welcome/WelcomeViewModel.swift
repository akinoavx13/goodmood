//
//  WelcomeViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

struct WelcomeViewModelActions {
    let presentNotification: () -> Void
}

protocol WelcomeViewModelProtocol: AnyObject {

    // MARK: - Methods
    
    func viewDidAppear()
    func nextButtonDidTap()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    
    // MARK: - Properties
    
    private let actions: WelcomeViewModelActions
    private let trackingService: TrackingServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: WelcomeViewModelActions,
         trackingService: TrackingServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showWelcome, eventProperties: nil)
    }
    
    func nextButtonDidTap() {
        actions.presentNotification()
    }
}
