//
//  DatabaseService.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import RealmSwift
import Foundation

protocol DatabaseServiceProtocol: AnyObject {
    
    // MARK: - Methods
    
    func getQuotes(language: RMQuote.RMLanguage,
                   category: RMQuote.RMCategory) throws -> [Quote]
}

final class DatabaseService: DatabaseServiceProtocol {
    
    // MARK: - Properties
    
    private let configuration: Realm.Configuration
    
    // MARK: - Lifecycle
    
    init() {
        configuration = Realm.Configuration(fileURL: Constants.realmFileURL,
                                            encryptionKey: Constants.realmEncryptionKey,
                                            readOnly: true,
                                            objectTypes: [RMQuote.self])
        
        if App.env == .debug,
           let path = configuration.fileURL?.absoluteString {
            print("📀 Realm path: \(path)")
        }
    }
    
    // MARK: - Methods
    
    func getQuotes(language: RMQuote.RMLanguage,
                   category: RMQuote.RMCategory) throws -> [Quote] {
        let realm = try Realm(configuration: configuration)
        
        return realm
            .objects(RMQuote.self)
            .where { $0.language == language && $0.category == category }
            .map { Quote(rmQuote: $0) }
            .shuffled()
    }
}
