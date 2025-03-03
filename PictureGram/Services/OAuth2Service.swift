//
//  OAuth2Service.swift
//  PictureGram
//
//  Created by Василий Ханин on 30.01.2025.
//

import Foundation

final class OAuth2Service {
    private let baseURL = "https://unsplash.com/oauth/token"
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared

    private var currentTask: URLSessionTask?
    private var lastCode: String?

    private init() {}

    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: baseURL) else {
            print("Ошибка: не удалось создать URL \(baseURL)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let httpBody = urlComponents.query?.data(using: .utf8) else {
            print("Ошибка: не удалось создать тело запроса из URLComponents")
            return nil
        }
        
        request.httpBody = httpBody
        return request
    }
    
    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if lastCode == code {
            print("Повторный запрос с тем же кодом \(code), отменяем отправку.")
            return
        }

        currentTask?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }

            self.lastCode = nil
            self.currentTask = nil
            
            switch result {
            case .success(let responseBody):
                self.storage.token = responseBody.accessToken
                print("✅ Токен получен: \(responseBody.accessToken)")
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: Ошибка получения токена: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        currentTask = task
        task.resume()
    }
}
