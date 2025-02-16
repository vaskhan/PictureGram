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
            let token = UserDefaults.standard.string(forKey: "AuthToken")
            print("🛠 Читаем токен из UserDefaults: \(token ?? "nil")")
            return token
        }
        set {
            print("💾 Сохраняем токен в UserDefaults: \(newValue ?? "nil")")
            UserDefaults.standard.setValue(newValue, forKey: "AuthToken")
        }
    }
}
