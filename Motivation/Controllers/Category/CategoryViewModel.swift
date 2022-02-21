//
//  CategoryViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa

struct CategoryViewModelActions { }

protocol CategoryViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<CategoryViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func viewDidAppear()
    func refreshCategories()
    func selectCategory(row: Int)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: CategoryViewModelActions
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: CategoryViewModelActions,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        self.preferenceService = preferenceService
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showCategories, eventProperties: nil)
    }
    
    func refreshCategories() {
        configureComposition()
    }
    
    func selectCategory(row: Int) {
        guard RMQuote.RMCategory.allCases.count > row else { return }
        
        let category = RMQuote.RMCategory.allCases[row]
        
        trackingService.track(event: .selectCategory, eventProperties: [.name: category.rawValue])
        preferenceService.save(selectedCategory: category)
    }
}

// MARK: - Composition -

extension CategoryViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case categories
    }
    
    enum Cell {
        case category(_ for: CategoryCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition() {
        var sections = [Section]()
        
        sections.append(configureCategoriesSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureCategoriesSection() -> Section {
        let cells: [Cell] = RMQuote.RMCategory.allCases.map { .category(CategoryCellViewModel(name: "\($0.translatedName) \($0.icon)")) }
        
        return .section(.categories,
                        title: nil,
                        cells: cells)
    }
}
