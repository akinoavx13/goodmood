//
//  WelcomeViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 22/02/2022.
//

struct WelcomeViewModelActions { }

protocol WelcomeViewModelProtocol: AnyObject {

    // MARK: - Methods
    
    func viewDidAppear()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    
    // MARK: - Properties
    
    private let actions: WelcomeViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: WelcomeViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showWelcome, eventProperties: nil)
    }
}
