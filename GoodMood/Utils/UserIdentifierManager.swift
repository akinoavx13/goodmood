//
//  UserIdentifierManager.swift
//  Motivation
//
//  Created by Maxime Maheo on 21/02/2022.
//

import Foundation
import KeychainSwift

protocol UserIdentifierManagerProtocol: AnyObject {
    
    var userId: String { get }
    
}

final class UserIdentifierManager: UserIdentifierManagerProtocol {
    
    // MARK: - Properties
    
    static let shared: UserIdentifierManagerProtocol = UserIdentifierManager()
    
    var userId: String {
        guard let userId = getUserId() else {
            return generateAndSaveUserId()
        }
        
        return userId
    }
    
    private let keychain = KeychainSwift()
    private let userIdKey = "USER_ID_KEY"
    
    // MARK: - Lifecycle
    
    private init() { }
    
    // MARK: - Private methods
    
    private func generateAndSaveUserId() -> String {
        let userId = UUID().uuidString
        
        keychain.set(userId, forKey: userIdKey)
        
        return userId
    }
    
    private func getUserId() -> String? {
        keychain.get(userIdKey)
    }
}
