//
//  QuoteViewModel.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RxSwift
import RxCocoa

struct QuoteViewModelActions { }

protocol QuoteViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    var composition: Driver<QuoteViewModel.QuoteComposition> { get }
    
    // MARK: - Methods
    
    func refreshQuotes()
}

final class QuoteViewModel: QuoteViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<QuoteComposition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<QuoteComposition>.create(bufferSize: 1)
    
    private let actions: QuoteViewModelActions
    private let databaseService: DatabaseServiceProtocol

    // MARK: - Lifecycle
    
    init(actions: QuoteViewModelActions,
         databaseService: DatabaseServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func refreshQuotes() {
        guard let quotes = try? databaseService.getQuotes(language: .french,
                                                          category: .general,
                                                          limit: 25)
        else { return }
        
        configureComposition(quotes: quotes)
    }
}

// MARK: - Composition -

extension QuoteViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct QuoteComposition {
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
        
        compositionSubject.onNext(QuoteComposition(sections: sections))
    }
    
    private func configureQuotesSection(quotes: [Quote]) -> Section? {
        guard !quotes.isEmpty else { return nil }
        
        let cells: [Cell] = quotes.map { .quote(QuoteCellViewModel(content: $0.content)) }
        
        return .section(.quotes,
                        title: nil,
                        cells: cells)
    }
    
}
