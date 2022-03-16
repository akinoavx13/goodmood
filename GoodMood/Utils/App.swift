//
//  App.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

struct App {
    
    enum Configuration: String {
        case debug = "Debug"
        case testFlight = "TestFlight"
        case appStore = "AppStore"
    }
    
    // MARK: - Properties

    static var env: Configuration {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
    
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    private static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
}
