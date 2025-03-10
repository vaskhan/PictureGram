//
//  ProfileLogoutService.swift
//  PictureGram
//
//  Created by Василий Ханин on 09.03.2025.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()
        KeychainWrapper.standard.removeObject(forKey: "Authtoken")
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatar()
        ImagesListService.shared.clearPhotos()
    }

    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes, for: [record],
                    completionHandler: {})
            }
        }
    }
}
