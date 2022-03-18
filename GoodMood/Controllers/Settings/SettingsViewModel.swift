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
    let presentPaywall: (PaywallFlowCoordinator.PaywallType, TrackingService.PaywallOrigin) -> Void
}

protocol SettingsViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<SettingsViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func viewDidLoad() async
    func viewDidAppear()
    func viewDidDisappear()
    func sendFeedback()
    func writeReview()
    func share(sourceView: UIView?)
    func helpTranslateApp()
    func toggleHasNotificationEnabled()
    func update(startAt: Date)
    func update(endAt: Date)
    func update(nbNotifPerDay: Double)
    func updateDebug(isPremium: Bool) async
    func restore() async -> Bool
    func showPremiumPlans()
    func refreshSubscriptionAndComposition() async
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    enum RowId: String {
        case sendFeedback,
             writeReview,
             share,
             helpTranslateTheApp,
             hasNotificationEnabled,
             startAt,
             endAt,
             nbNotifPerDay,
             debugPremium,
             subscriptionStatus,
             showPremiumPlans,
             restore
    }
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())
    
    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: SettingsViewModelActions
    private let device: UIDevice
    private var hasActiveSubscription: Bool = false

    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let quoteService: QuoteServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: SettingsViewModelActions,
         device: UIDevice = UIDevice.current,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol,
         notificationService: NotificationServiceProtocol,
         quoteService: QuoteServiceProtocol,
         purchaseService: PurchaseServiceProtocol) {
        self.actions = actions
        self.device = device
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        self.notificationService = notificationService
        self.quoteService = quoteService
        self.purchaseService = purchaseService
    }
    
    // MARK: - Methods
    
    func viewDidLoad() async {
        await refreshSubscriptionAndComposition()
    }
    
    func viewDidAppear() {
        trackingService.track(event: .showSettings, eventProperties: nil)
    }
    
    func viewDidDisappear() {
        Task {
            if !preferenceService.isNotificationEnabled() {
                await notificationService.removeAllPendingNotifications(type: .quote)
            } else {
                await quoteService.triggerNotificationsIfNeeded()
            }
        }
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
    
    func toggleHasNotificationEnabled() {
        preferenceService.save(isNotificationEnabled: !preferenceService.isNotificationEnabled())
        
        trackingService.set(userProperty: .hasNotificationEnabled, value: NSNumber(value: preferenceService.isNotificationEnabled()))

        configureComposition()
    }
    
    func update(startAt: Date) {
        trackingService.track(event: .updateStartAt, eventProperties: nil)

        preferenceService.save(startAt: startAt)
    }
    
    func update(endAt: Date) {
        trackingService.track(event: .updateEndAt, eventProperties: nil)

        preferenceService.save(endAt: endAt)
    }
    
    func update(nbNotifPerDay: Double) {
        trackingService.set(userProperty: .nbNotifPerDay, value: NSNumber(value: nbNotifPerDay))
        trackingService.track(event: .updateNbNotifPerDay, eventProperties: nil)
        
        preferenceService.save(nbTimesNotif: Int(nbNotifPerDay))
        
        configureComposition()
    }
    
    func updateDebug(isPremium: Bool) async {
        preferenceService.debugSet(isPremium: isPremium)
        
        await refreshSubscriptionAndComposition()
    }
    
    func restore() async -> Bool {
        let hasSucceed = await purchaseService.restore()
        
        trackingService.track(event: .restore, eventProperties: [.hasSucceed: hasSucceed,
                                                                 .origin: TrackingService.PaywallOrigin.settings.rawValue])
        
        return hasSucceed
    }
    
    func showPremiumPlans() {
        actions.presentPaywall(.start, .settings)
    }
    
    func refreshSubscriptionAndComposition() async {
        hasActiveSubscription = await purchaseService.hasActiveSubscription()
        
        configureComposition(hasActiveSubscription: hasActiveSubscription)
    }
}

// MARK: - Composition

extension SettingsViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case support,
             notifications,
             debug,
             subscription
    }
    
    enum Cell {
        case toggle(_ for: SettingsToggleCellViewModel),
             timePicker(_ for: SettingsTimePickerCellViewModel),
             link(_ for: SettingsLinkCellViewModel),
             value(_ for: SettingsValueCellViewModel),
             button(_ for: SettingsButtonCellViewModel),
             stepper(_ for: SettingsStepperCellViewModel)
    }
    
    private func configureComposition(hasActiveSubscription: Bool = false) {
        var sections = [Section]()
        
        if let debugSection = configureDebugSection(hasActiveSubscription: hasActiveSubscription) {
            sections.append(debugSection)
        }
        
        sections.append(configureSubscriptionSection())
        sections.append(configureNotificationSection())
        sections.append(configureSupportSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureDebugSection(hasActiveSubscription: Bool) -> Section? {
        guard App.env == .debug || App.env == .testFlight else { return nil }
        
        let cells: [Cell] = [.toggle(SettingsToggleCellViewModel(id: RowId.debugPremium.rawValue,
                                                                 title: "Premium",
                                                                 subtitle: "Only available on Debug or Testflight",
                                                                 isOn: hasActiveSubscription,
                                                                 isDisabled: false))]
        
        return .section(.debug,
                        title: "Debug",
                        cells: cells)
    }
    
    private func configureSubscriptionSection() -> Section {
        .section(.subscription,
                 title: R.string.localizable.subscription(),
                 cells: [.value(SettingsValueCellViewModel(id: RowId.subscriptionStatus.rawValue,
                                                           title: R.string.localizable.current_plan(),
                                                           value: hasActiveSubscription ? R.string.localizable.premium() : R.string.localizable.free())),
                         .button(SettingsButtonCellViewModel(id: RowId.showPremiumPlans.rawValue,
                                                             title: R.string.localizable.show_premium_plans())),
                         .button(SettingsButtonCellViewModel(id: RowId.restore.rawValue,
                                                             title: R.string.localizable.restore()))])
    }
    
    private func configureNotificationSection() -> Section {
        let isNotificationEnabled = preferenceService.isNotificationEnabled()
        var cells: [Cell] = [.toggle(SettingsToggleCellViewModel(id: RowId.hasNotificationEnabled.rawValue,
                                                                 title: R.string.localizable.motivations(),
                                                                 subtitle: R.string.localizable.daily_reminders(),
                                                                 isOn: isNotificationEnabled,
                                                                 isDisabled: false))]
        
        if isNotificationEnabled {
            cells.append(.stepper(SettingsStepperCellViewModel(id: RowId.nbNotifPerDay.rawValue,
                                                               title: R.string.localizable.number_of_reminders(),
                                                               subtitle: R.string.localizable.x_times(Int(preferenceService.getNbTimesNotif())),
                                                               value: Double(preferenceService.getNbTimesNotif()),
                                                               min: 1,
                                                               max: 24,
                                                               step: 1,
                                                               isDisabled: false)))
            cells.append(.timePicker(SettingsTimePickerCellViewModel(id: RowId.startAt.rawValue,
                                                                     title: R.string.localizable.start_at(),
                                                                     date: preferenceService.getStartAtTime(),
                                                                     isDisabled: false)))
            cells.append(.timePicker(SettingsTimePickerCellViewModel(id: RowId.endAt.rawValue,
                                                                     title: R.string.localizable.end_at(),
                                                                     date: preferenceService.getEndAtTime(),
                                                                     isDisabled: false)))
        }
        
        return .section(.notifications,
                        title: R.string.localizable.notifications(),
                        cells: cells)
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
