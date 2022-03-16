//
//  DD.swift
//  Motivation
//
//  Created by Maxime Maheo on 20/02/2022.
//

#if DEBUG
func dd(_ parameters: Any...) {
    print("DD:", parameters.map { "\($0)" }.joined(separator: " • "))
}
#endif
