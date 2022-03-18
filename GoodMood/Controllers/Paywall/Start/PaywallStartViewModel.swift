//
//  PaywallStartViewModel.swift
//  GoodMood
//
//  Created by Maxime Maheo on 20/12/2021.
//

import RxSwift
import RxCocoa
import Purchases

struct PaywallStartViewModelActions {
    let dismiss: () -> Void
    let presentSafariViewController: (String) -> Void
}

protocol PaywallStartViewModelProtocol: AnyObject {

    // MARK: - Properties
    
    var isLoading: BehaviorRelay<Bool> { get }
    var price: BehaviorRelay<String> { get }
    var origin: TrackingService.PaywallOrigin { get }
    
    // MARK: - Methods
    
    func viewDidLoad() async
    func dismiss()
    func restore() async -> Bool
    func purchase() async -> Bool
    func termsOfUse()
    func privacyPolicy()
}

final class PaywallStartViewModel: PaywallStartViewModelProtocol {
    
    // MARK: - Properties

    private(set) var isLoading: BehaviorRelay<Bool> = .init(value: true)
    private(set) var price: BehaviorRelay<String> = .init(value: R.string.localizable.renewed_subscription_x(R.string.localizable.renewed_subscription_default_price()))
    private(set) var origin: TrackingService.PaywallOrigin
    
    private var availablePackages: [Purchases.Package] = []
    private var selectedPackage: Purchases.Package? {
        didSet { updatePrice(with: selectedPackage) }
    }

    private let actions: PaywallStartViewModelActions
    private let type: PaywallFlowCoordinator.PaywallType
    
    private let trackingService: TrackingServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    private let formatterService: FormatterServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: PaywallStartViewModelActions,
         origin: TrackingService.PaywallOrigin,
         type: PaywallFlowCoordinator.PaywallType,
         trackingService: TrackingServiceProtocol,
         purchaseService: PurchaseServiceProtocol,
         formatterService: FormatterServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        self.actions = actions
        self.origin = origin
        self.type = type
        self.trackingService = trackingService
        self.purchaseService = purchaseService
        self.formatterService = formatterService
        self.notificationService = notificationService
    }
    
    // MARK: - Methods
    
    func viewDidLoad() async {
        trackingService.track(event: .showPaywall, eventProperties: [.origin: origin.rawValue,
                                                                     .paywallType: type.rawValue])
        
        switch type {
        case .start:
            availablePackages = await purchaseService.availablePackages(offeringType: .start)
        }

        await updateSelectedPackage(with: availablePackages)
    }
    
    func dismiss() {
        trackingService.track(event: .closePaywall, eventProperties: [.origin: origin.rawValue,
                                                                      .paywallType: type.rawValue])

        actions.dismiss()
    }
    
    func restore() async -> Bool {
        let hasRestoreSucceed = await purchaseService.restore()
        
        trackingService.track(event: .restore, eventProperties: [.hasSucceed: hasRestoreSucceed,
                                                                 .origin: origin.rawValue,
                                                                 .paywallType: type.rawValue])
        
        return hasRestoreSucceed
    }
    
    func purchase() async -> Bool {
        guard let selectedPackage = selectedPackage else { return false }
        
        let hasPurchaseSucceed = await purchaseService.purchase(package: selectedPackage)
        
        trackingService.track(event: .purchase, eventProperties: [.hasSucceed: hasPurchaseSucceed,
                                                                  .origin: origin.rawValue,
                                                                  .paywallType: type.rawValue])
        
        return hasPurchaseSucceed
    }
    
    func termsOfUse() {
        trackingService.track(event: .termsOfUse, eventProperties: [.origin: origin.rawValue,
                                                                    .paywallType: type.rawValue])

        actions.presentSafariViewController("https://gist.githubusercontent.com/mmaheo/f50ed78eadffb45caa64c645a351ecb5/raw/e4e0168aabc93bd2f2694685c699975432ab0ba5/motivation-terms-and-conditions")
    }
    
    func privacyPolicy() {
        trackingService.track(event: .privacyPolicy, eventProperties: [.origin: origin.rawValue,
                                                                       .paywallType: type.rawValue])

        actions.presentSafariViewController("https://gist.githubusercontent.com/mmaheo/b23be80e32b5cf181125d1fb50f3d46f/raw/6bbeb6f6407520a9af796f69744691878390914c/motivation-privacy-policy")
    }
    
    // MARK: - Private methods
    
    private func updateSelectedPackage(with packages: [Purchases.Package]) async {
        guard let selectedPackage = availablePackages.first else { return }

        self.selectedPackage = selectedPackage

        isLoading.accept(false)
    }
    
    private func updatePrice(with package: Purchases.Package?) {
        guard let package = package,
              let subscriptionPeriod = package.product.subscriptionPeriod,
              let localizedPriceString = formatterService.format(value: package.product.price.doubleValue,
                                                                 style: .currency,
                                                                 locale: package.product.priceLocale)
        else { return dismiss() }
        
        // TODO: Handle intro price
        
        price.accept(R.string.localizable.renewed_subscription_x(R.string.localizable.amout_x_charged_every_x(localizedPriceString, subscriptionPeriod.periodTitle)))
    }
}
