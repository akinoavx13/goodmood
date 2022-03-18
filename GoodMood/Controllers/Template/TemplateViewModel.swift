//
//  TemplateViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa
import UIKit.UIImage

struct TemplateViewModelActions {
    let presentPaywall: (PaywallFlowCoordinator.PaywallType, TrackingService.PaywallOrigin) -> Void
}

protocol TemplateViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<TemplateViewModel.Composition> { get }

    // MARK: - Methods
    
    func viewDidLoad() async
    func selectTemplate(row: Int) -> String?
}

final class TemplateViewModel: TemplateViewModelProtocol {
    
    enum TemplateImage: String, CaseIterable {
        case background1,
             background2,
             background3,
             background4,
             background5,
             background6,
             background7,
             background8,
             background9,
             background10,
             background11,
             background12,
             background13,
             background14,
             background15,
             background16,
             background17,
             background18
    }
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())
    
    private var selectedTemplateId: String?
    private let hasActiveSubscription: BehaviorRelay<Bool> = .init(value: false)
    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    private let disposeBag = DisposeBag()
    
    private let actions: TemplateViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: TemplateViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol,
         purchaseService: PurchaseServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        self.purchaseService = purchaseService
                
        selectedTemplateId = preferenceService.selectedTemplate()
                
        configure()
    }
    
    // MARK: - Setup Methods
    
    private func configure() {
        configureComposition(selectedTemplate: selectedTemplateId)

        purchaseService
            .promotedIAPDidPurchase
            .withUnretained(self)
            .subscribe(onNext: { this, _ in
                Task { await this.updateSubscriptionStatus() }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    
    func viewDidLoad() async {
        trackingService.track(event: .showTemplate, eventProperties: nil)

        await updateSubscriptionStatus()
    }
    
    func selectTemplate(row: Int) -> String? {
        if !hasActiveSubscription.value {
            actions.presentPaywall(.start, .template)
            return nil
        }
        
        guard TemplateImage.allCases.count > row else { return nil }
        
        let template = TemplateImage.allCases[row]
        
        guard selectedTemplateId != template.rawValue else { return nil }
        
        trackingService.track(event: .selectTemplate, eventProperties: [.templateId: template.rawValue])
        preferenceService.save(selectedTemplate: template.rawValue)
        
        return template.rawValue
    }
    
    // MARK: - Private methods
    
    private func resizedImage(templateId: String,
                              for size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width * UIScreen.main.scale, size.height * UIScreen.main.scale)
        ]
        
        guard let url = Bundle.main.url(forResource: templateId, withExtension: "jpg"),
              let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else { return nil }
        
        return UIImage(cgImage: image)
    }
    
    func updateSubscriptionStatus() async {
        let hasActiveSubscription = await purchaseService.hasActiveSubscription()
        self.hasActiveSubscription.accept(hasActiveSubscription)
    }
}

// MARK: - Composition -

extension TemplateViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case templates
    }
    
    enum Cell {
        case template(_ for: TemplateCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition(selectedTemplate: String?) {
        var sections = [Section]()
        
        DispatchQueue.global(qos: .userInteractive).async {
            sections.append(self.configureTemplatesSection(selectedTemplate: selectedTemplate))
            self.compositionSubject.onNext(Composition(sections: sections))
        }
    }
    
    private func configureTemplatesSection(selectedTemplate: String?) -> Section {
        let cells: [Cell] = TemplateImage.allCases.map { .template(TemplateCellViewModel(templateId: $0.rawValue,
                                                                                         selectedTemplate: selectedTemplate,
                                                                                         templateImage: resizedImage(templateId: $0.rawValue,
                                                                                                                     for: TemplateCell.size))) }
        
        return .section(.templates,
                        title: nil,
                        cells: cells)
    }
}
