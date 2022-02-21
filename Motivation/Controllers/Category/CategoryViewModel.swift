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
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: CategoryViewModelActions
    private let trackingService: TrackingServiceProtocol

    // MARK: - Lifecycle
    
    init(actions: CategoryViewModelActions,
         trackingService: TrackingServiceProtocol) {
        self.actions = actions
        self.trackingService = trackingService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showCategories, eventProperties: nil)
    }
}

// MARK: - Composition -

extension CategoryViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType { }
    
    enum Cell { }
    
    // MARK: - Private methods
    
    private func configureComposition() {
        let sections = [Section]()
        
        compositionSubject.onNext(Composition(sections: sections))
    }
}
