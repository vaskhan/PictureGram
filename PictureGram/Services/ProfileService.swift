//
//  ProfileService.swift
//  PictureGram
//
//  Created by Василий Ханин on 13.02.2025.
//

import Foundation

final class ProfileService {
    private let baseURL = "https://api.unsplash.com/me"
    private let authToken = OAuth2TokenStorage()
    
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("🌐 Отправляем запрос профиля...")
        guard let token = authToken.token else {
            print("❌ Ошибка: токен отсутствует")
            completion(.failure(NSError(domain: "ProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Токен отсутствует"])))
            return
        }
        
        guard let request = makeProfileRequest(token: token) else {
            print("❌ Ошибка: запрос профиля не создан")
            completion(.failure(NSError(domain: "ProfileService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Неверный запрос"])))
            return
        }
        
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
                    completion(.failure(NSError(domain: "ProfileService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName ?? "")",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )
                    self.profile = profile
                    print("✅ Профиль загружен: \(profile.name)")
                    
                    completion(.success(profile))
                } catch {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
