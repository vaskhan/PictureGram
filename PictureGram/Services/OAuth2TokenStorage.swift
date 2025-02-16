//
//  OAuth2TokenStorage.swift
//  PictureGram
//
//  Created by Василий Ханин on 31.01.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let key = "Authtoken"
    
    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: key)
            print("[Keychain] Получен токен: \(token ?? "nil")")
            return token
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: key)
                if isSuccess {
                    print("✅ [Keychain] Токен сохранён: \(newValue)")
                } else {
                    print("❌ [Keychain] Ошибка сохранения токена")
                }
            } else {
                let isRemoved = KeychainWrapper.standard.removeObject(forKey: key)
                if isRemoved {
                    print("🗑️ [Keychain] Токен удалён")
                } else {
                    print("❌ [Keychain] Ошибка удаления токена")
                }
            }
        }
    }
}
