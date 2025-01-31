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
    
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: baseURL) else { return nil }
        
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
        
        request.httpBody = urlComponents.query?.data(using: .utf8)
        return request
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
}

