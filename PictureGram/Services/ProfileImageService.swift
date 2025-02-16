//
//  ProfileImageService.swift
//  PictureGram
//
//  Created by Василий Ханин on 15.02.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let baseURL = "https://api.unsplash.com/users"
    private let authToken = OAuth2TokenStorage().token
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let token = authToken else {
            print("❌ Ошибка: токен отсутствует")
            completion(.failure(NSError(domain: "ProfileImageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Токен отсутствует"])))
            return
        }
        
        let urlString = "\(baseURL)/\(username)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Сетевая ошибка: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    200..<300 ~= httpResponse.statusCode
                else {
                    print("❌ Ошибка сервера, код: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completion(.failure(NSError(domain: "ProfileImageService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let imageURL = userResult.profileImage.small
                    self.avatarURL = imageURL
                    
                    completion(.success(imageURL))
                    print("✅ URL изображения профиля получен: \(imageURL)")
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": imageURL]
                    )
                        
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
}
