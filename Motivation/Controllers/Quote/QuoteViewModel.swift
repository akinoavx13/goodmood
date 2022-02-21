//
//  QuoteViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa
import Foundation

struct QuoteViewModelActions {
    let presentSettings: () -> Void
    let presentCategory: () -> Void
}

protocol QuoteViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<QuoteViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func viewDidAppear()
    func refreshQuotesIfNeeded()
    func refreshSelectedCategory()
    func showNextQuote()
    func presentSettings()
    func presentCategory()
}

final class QuoteViewModel: QuoteViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: QuoteViewModelActions
    private let databaseService: DatabaseServiceProtocol
    private let trackingService: TrackingServiceProtocol
    private let preferenceService: PreferenceServiceProtocol
    private var selectedCategory: RMQuote.RMCategory
    private var newSelectedCategory: RMQuote.RMCategory?
    
    // MARK: - Lifecycle
    
    init(actions: QuoteViewModelActions,
         databaseService: DatabaseServiceProtocol,
         trackingService: TrackingServiceProtocol,
         preferenceService: PreferenceServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
        self.trackingService = trackingService
        self.preferenceService = preferenceService
        self.selectedCategory = preferenceService.getSelectedCategory() ?? .general
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showQuoteScreen, eventProperties: nil)
    }
    
    func refreshQuotesIfNeeded() {        
        guard shouldRefreshQuotes() else { return }
        
        selectedCategory = preferenceService.getSelectedCategory() ?? .general
        
        guard let quotes = try? databaseService.getQuotes(language: RMQuote.RMLanguage.user,
                                                          category: selectedCategory)
        else { return }
        
        configureComposition(quotes: quotes)
    }
    
    func refreshSelectedCategory() {
        newSelectedCategory = preferenceService.getSelectedCategory()
        
        refreshQuotesIfNeeded()
    }
    
    func showNextQuote() {
        trackingService.track(event: .showNextQuote, eventProperties: [.category: selectedCategory.rawValue])
    }
    
    func presentSettings() {
        actions.presentSettings()
    }
    
    func presentCategory() {
        actions.presentCategory()
    }
    
    // MARK: - Methods
    
    private func shouldRefreshQuotes() -> Bool {
        selectedCategory != newSelectedCategory
    }
}

// MARK: - Composition -

extension QuoteViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case quotes
    }
    
    enum Cell {
        case quote(_ for: QuoteCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition(quotes: [Quote] = []) {
        var sections = [Section]()
        
        if let quotesSection = configureQuotesSection(quotes: quotes) {
            sections.append(quotesSection)
        }
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureQuotesSection(quotes: [Quote]) -> Section? {
        guard !quotes.isEmpty else { return nil }
        
        let cells: [Cell] = quotes.map { .quote(QuoteCellViewModel(content: $0.content)) }
        
        return .section(.quotes,
                        title: nil,
                        cells: cells)
    }
}
