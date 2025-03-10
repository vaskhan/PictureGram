//
//  ProfileService.swift
//  PictureGram
//
//  Created by Василий Ханин on 13.02.2025.
//

import Foundation

final class ProfileService {
    
    // MARK: - Public Properties
    static let shared = ProfileService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileServiceDidChange")
    private(set) var profile: Profile?
    
    // MARK: - Private Properties
    private let baseURL = "https://api.unsplash.com/me"
    private let authToken = OAuth2TokenStorage()
    
    // MARK: - Initializers
    private init() {}
    
    func clearProfile() {
        profile = nil
        NotificationCenter.default.post(name: ProfileService.didChangeNotification, object: self)
        print("Профиль удален")
    }
    
    // MARK: - Public Methods
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let token = authToken.token,
              let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName ?? "")",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self.profile = profile
                print("✅ Профиль загружен: \(profile.name)")
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: Ошибка получения профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - ProfileResult
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

// MARK: - Profile
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
