//
//  PurchaseService.swift
//  GoodMood
//
//  Created by Maxime Maheo on 18/03/2022.
//

import Purchases
import PKHUD
import RxRelay

protocol PurchaseServiceProtocol: AnyObject {
    
    // MARK: - Properties
    
    var promotedIAPDidPurchase: PublishRelay<String> { get }
    
    // MARK: - Methods
    
    func hasActiveSubscription() async -> Bool
    func availablePackages(offeringType: PurchaseService.OfferingType) async -> [Purchases.Package]
    func purchase(package: Purchases.Package) async -> Bool
    func restore() async -> Bool
    func checkTrialOrIntroductoryPriceEligibility(productIdentifier: String) async -> Bool
}

final class PurchaseService: NSObject, PurchaseServiceProtocol {
    
    enum OfferingType: String, CaseIterable {
        case start
    }
    
    // MARK: - Properties
        
    private(set) var promotedIAPDidPurchase: PublishRelay<String> = .init()
    
    private let purchases: Purchases
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(purchases: Purchases = Purchases.shared,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.purchases = purchases
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        
        super.init()
        
        self.purchases.delegate = self
        
        Task {
            await OfferingType.allCases.asyncForEach {
                await _ = availablePackages(offeringType: $0)
            }
        }
    }
    
    // MARK: - Methods
    
    func hasActiveSubscription() async -> Bool {
        if App.env == .debug || App.env == .testFlight {
            return preferenceService.debugGetIsPremium()
        }
        
        guard let hasActiveSubscription = try? await !purchases.purchaserInfo().entitlements.active.isEmpty else {
            trackingService.set(userProperty: .hasActiveSubscription, value: NSNumber(value: false))
            return false
        }
        
        trackingService.set(userProperty: .hasActiveSubscription, value: NSNumber(value: hasActiveSubscription))
        
        return hasActiveSubscription
    }
    
    func availablePackages(offeringType: OfferingType) async -> [Purchases.Package] {
        guard let availablePackages = try? await purchases.offerings().all[offeringType.rawValue]?.availablePackages else {
            return []
        }
        
        return availablePackages
    }
    
    func purchase(package: Purchases.Package) async -> Bool {
        guard let response = try? await purchases.purchasePackage(package),
              !response.1.entitlements.active.isEmpty,
              !response.2 // User cancelled
        else { return false }

        return true
    }
    
    func restore() async -> Bool {
        guard let response = try? await purchases.restoreTransactions(),
                !response.entitlements.active.isEmpty
        else { return false }
        
        return true
    }
    
    func checkTrialOrIntroductoryPriceEligibility(productIdentifier: String) async -> Bool {
        guard let purchaserInfo = try? await Purchases.shared.purchaserInfo() else { return false }

        return !purchaserInfo.allPurchasedProductIdentifiers.contains(productIdentifier)
    }
    
}

// MARK: - PurchasesDelegate -

extension PurchaseService: PurchasesDelegate {
    func purchases(_ purchases: Purchases,
                   shouldPurchasePromoProduct product: SKProduct,
                   defermentBlock makeDeferredPurchase: @escaping RCDeferredPromotionalPurchaseBlock) {
        HUD.show(.progress)
        
        makeDeferredPurchase { [weak self] (_, info, _, _) in
            guard let self = self else { return HUD.flash(.error, delay: Constants.animationDuration) }
            
            if info != nil {
                self.trackingService.track(event: .purchasePromotedIAP, eventProperties: [.hasSucceed: true,
                                                                                          .name: product.productIdentifier])
                self.promotedIAPDidPurchase.accept(product.productIdentifier)
                HUD.flash(.success, delay: Constants.animationDuration)
            } else {
                self.trackingService.track(event: .purchasePromotedIAP, eventProperties: [.hasSucceed: false])
                HUD.flash(.error, delay: Constants.animationDuration)
            }
        }
    }
}
