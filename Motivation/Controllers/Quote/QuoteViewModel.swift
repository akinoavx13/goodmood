//
//  QuoteViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa

struct QuoteViewModelActions {
    let presentSettings: () -> Void
}

protocol QuoteViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<QuoteViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func viewDidAppear()
    func refreshQuotes()
    func showNextQuote()
    func presentSettings()
}

final class QuoteViewModel: QuoteViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: QuoteViewModelActions
    private let databaseService: DatabaseServiceProtocol
    private let trackingService: TrackingServiceProtocol

    // MARK: - Lifecycle
    
    init(actions: QuoteViewModelActions,
         databaseService: DatabaseServiceProtocol,
         trackingService: TrackingServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
        self.trackingService = trackingService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func viewDidAppear() {
        trackingService.track(event: .showQuoteScreen, eventProperties: nil)
    }
    
    func refreshQuotes() {
        guard let quotes = try? databaseService.getQuotes(language: .french,
                                                          category: .general)
        else { return }
        
        configureComposition(quotes: quotes)
    }
    
    func showNextQuote() {
        trackingService.track(event: .showNextQuote, eventProperties: nil)
    }
    
    func presentSettings() {
        actions.presentSettings()
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
