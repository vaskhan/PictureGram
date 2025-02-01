//
//  OAuth2TokenStorage.swift
//  PictureGram
//
//  Created by Василий Ханин on 31.01.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthToken")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "AuthToken")
        }
    }
}
