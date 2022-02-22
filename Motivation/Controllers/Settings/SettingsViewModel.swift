//
//  SettingsViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 18/12/2021.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit.UIDevice
import UIKit.UIView

struct SettingsViewModelActions {
    let openUrl: (String) -> Void
    let presentActivityViewController: (String, UIView?, @escaping (String?, Bool) -> Void) -> Void
    let requestReview: () -> Void
}

protocol SettingsViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<SettingsViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func viewDidLoad()
    func viewDidAppear()
    func sendFeedback()
    func writeReview()
    func share(sourceView: UIView?)
    func helpTranslateApp()
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    enum RowId: String {
        case sendFeedback,
             writeReview,
             share,
             helpTranslateTheApp
    }
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())
    
    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: SettingsViewModelActions
    private let device: UIDevice
    
    private let trackingService: TrackingServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: SettingsViewModelActions,
         device: UIDevice = UIDevice.current,
         trackingService: TrackingServiceProtocol) {
        self.actions = actions
        self.device = device
        self.trackingService = trackingService
    }
    
    // MARK: - Methods
    
    func viewDidLoad() {
        configureComposition()
    }
    
    func viewDidAppear() {
        trackingService.track(event: .showSettings, eventProperties: nil)
    }
    
    func sendFeedback() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let appBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        
        trackingService.track(event: .sendFeedback, eventProperties: nil)
        
        let osVersion = "OS: \(device.systemVersion)"
        let version = "App: \(appVersion)(\(appBuildNumber))"
        let deviceType = "Device: \(device.userInterfaceIdiom == .pad ? "iPad" : "iPhone")"
        let body = "\n\n\(osVersion)\n\(version)\n\(deviceType)"
        
        guard let stringUrl = "mailto:\(Constants.email)?subject=Feedback&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        actions.openUrl(stringUrl)
    }
    
    func writeReview() {
        trackingService.track(event: .writeReview, eventProperties: nil)
        
        actions.openUrl("https://itunes.apple.com/app/id\(Constants.appId)?action=write-review")
    }
    
    func share(sourceView: UIView?) {
        actions.presentActivityViewController(R.string.localizable.share_app_content("https://apps.apple.com/app/id\(Constants.appId)"),
                                              sourceView, { [weak self] activityName, hasSucceed in
            guard let self = self else { return }
            
            self.trackingService.track(event: .shareApp,
                                       eventProperties: [.name: activityName ?? "unknown",
                                                         .hasSucceed: hasSucceed])
            
            if hasSucceed {
                self.actions.requestReview()
            }
        })
    }
    
    func helpTranslateApp() {
        trackingService.track(event: .helpTranslateApp, eventProperties: nil)
        
        let body = "Hello,\n\nI would like to help out with the <YOUR LANGUAGE> translation of Motivation.\nPlease send me instructions on how to get started."
        
        guard let stringUrl = "mailto:\(Constants.email)?subject=App translation&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        actions.openUrl(stringUrl)
    }
}

// MARK: - Composition

extension SettingsViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case support
    }
    
    enum Cell {
        case toggle(_ for: SettingsToggleCellViewModel),
             timePicker(_ for: SettingsTimePickerCellViewModel),
             link(_ for: SettingsLinkCellViewModel),
             value(_ for: SettingsValueCellViewModel),
             button(_ for: SettingsButtonCellViewModel)
    }
    
    private func configureComposition() {
        var sections = [Section]()
        
        sections.append(configureSupportSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureSupportSection() -> Section {
        .section(.support,
                 title: R.string.localizable.support(),
                 cells: [.link(SettingsLinkCellViewModel(id: RowId.helpTranslateTheApp.rawValue,
                                                         title: R.string.localizable.help_translate_the_app(),
                                                         iconName: "abc",
                                                         iconColor: Colors.accent)),
                         .link(SettingsLinkCellViewModel(id: RowId.sendFeedback.rawValue,
                                                         title: R.string.localizable.send_feedback(),
                                                         iconName: "at",
                                                         iconColor: Colors.blue)),
                         .link(SettingsLinkCellViewModel(id: RowId.writeReview.rawValue,
                                                         title: R.string.localizable.write_a_review(),
                                                         iconName: "heart",
                                                         iconColor: .red)),
                         .link(SettingsLinkCellViewModel(id: RowId.share.rawValue,
                                                         title: R.string.localizable.share_x(R.string.infoPlist.cfBundleDisplayName()),
                                                         iconName: "square.and.arrow.up",
                                                         iconColor: .label))])
    }
}
