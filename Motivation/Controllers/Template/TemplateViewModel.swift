//
//  TemplateViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa
import UIKit.UIImage

struct TemplateViewModelActions { }

protocol TemplateViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<TemplateViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func selectTemplate(row: Int) -> String?
}

final class TemplateViewModel: TemplateViewModelProtocol {
    
    enum TemplateImage: String, CaseIterable {
        case background1,
             background2
        
        var image: UIImage? {
            switch self {
            case .background1: return R.image.templates.background_1()
            case .background2: return R.image.templates.background_2()
            }
        }
        
        static func template(templateId: String) -> Self? {
            TemplateImage.allCases.first(where: { $0.rawValue == templateId })
        }
    }
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private var selectedTemplateId: String?
    
    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    private let actions: TemplateViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: TemplateViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        
        trackingService.track(event: .showTemplate, eventProperties: nil)
        
        selectedTemplateId = preferenceService.selectedTemplate()
        
        configureComposition(selectedTemplate: selectedTemplateId)
    }
    
    // MARK: - Methods
    
    func selectTemplate(row: Int) -> String? {
        guard TemplateImage.allCases.count > row else { return nil }
        
        let template = TemplateImage.allCases[row]
        
        guard selectedTemplateId != template.rawValue else { return nil }
        
        trackingService.track(event: .selectTemplate, eventProperties: [.templateId: template.rawValue])
        preferenceService.save(selectedTemplate: template.rawValue)
        
        return template.rawValue
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
        
        sections.append(configureTemplatesSection(selectedTemplate: selectedTemplate))
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureTemplatesSection(selectedTemplate: String?) -> Section {
        let cells: [Cell] = TemplateImage.allCases.map { .template(TemplateCellViewModel(templateImage: $0,
                                                                                         selectedTemplate: selectedTemplate)) }
        
        return .section(.templates,
                        title: nil,
                        cells: cells)
    }
}
