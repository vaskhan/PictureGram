//
//  OAuth2Service.swift
//  PictureGram
//
//  Created by Василий Ханин on 30.01.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let baseURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    
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
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 2, userInfo: [NSLocalizedDescriptionKey: "Ошибка сети: \(error.localizedDescription)"])))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 3, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ HTTP"])))
                }
                return
            }
            
            print("HTTP - код: \(httpResponse.statusCode)")
            
            guard (200..<300) .contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 4, userInfo: [NSLocalizedDescriptionKey: "Ответ пустой"])))
                }
                return
            }
            print("Данные от сервера:", String(data: data, encoding: .utf8) ?? "Не удалось преобразовать данные")
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                self.storage.token = responseBody.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 5, userInfo: [NSLocalizedDescriptionKey: "Ошибка декодирования JSON"])))
                }
            }
        }
        
        task.resume()
    }
}
