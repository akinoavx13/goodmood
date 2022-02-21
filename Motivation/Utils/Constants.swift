//
//  Constants.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

import Foundation

struct Constants {
    
    // Realm
    static let realmEncryptionKey = Data([72, 75, 52, 42, 105, 55, 99, 106, 101, 111, 87, 119, 51, 77, 106, 70, 121, 99, 109, 42, 104, 115, 82, 97, 95, 114, 52, 115, 119, 52, 81, 76, 118, 116, 69, 57, 69, 109, 85, 78, 121, 119, 57, 84, 50, 102, 51, 105, 81, 95, 54, 55, 77, 114, 33, 110, 57, 50, 109, 120, 64, 64, 86, 72])
    static let realmFileURL = Bundle.main.url(forResource: "quotes", withExtension: "realm")
    
    // Amplitude
    static let amplitudeApiKey = "d84cd4074dfe5b96a9b170d6d4ba3d69"
}
