//
//  ProfileImageService.swift
//  PictureGram
//
//  Created by Василий Ханин on 15.02.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageServiceDidChange")
    private let baseURL = "https://api.unsplash.com/users"
    private let authToken = OAuth2TokenStorage().token
    
    var avatarURL: String?
    
    private init() {}
    
    func clearAvatar() {
        avatarURL = nil
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
        print("Аватарка удалена")
    }
    
    func fetchProfileImageURL(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let token = authToken,
              let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let imageURL = userResult.profileImage.small
                self.avatarURL = imageURL
                self.avatarURL = imageURL
                print("🟢 [ProfileImageService]: avatarURL установлен: \(self.avatarURL ?? "nil")")
                
                print("✅ URL аватара получен: \(imageURL)")
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": imageURL]
                )
                print("📣 [ProfileImageService]: Уведомление отправлено с URL: \(imageURL)")
                completion(.success(imageURL))
            case .failure(let error):
                print("[ProfileImageService]: Ошибка получения аватара: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        let urlString = "\(baseURL)/\(username)"
        guard let url = URL(string: urlString) else {
            print("❌ [makeProfileImageRequest]: Неверный URL: \(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
}
