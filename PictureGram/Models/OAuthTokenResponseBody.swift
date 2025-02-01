//
//  OAuthTokenResponseBody.swift
//  PictureGram
//
//  Created by Василий Ханин on 31.01.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
//    let refreshToken: String?
//    let userId: Int?
//    let username: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
//        case refreshToken = "refresh_token"
//        case userId = "user_id"
//        case username
    }
}

