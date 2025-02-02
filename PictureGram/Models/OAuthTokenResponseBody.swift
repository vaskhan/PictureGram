//
//  OAuthTokenResponseBody.swift
//  PictureGram
//
//  Created by Василий Ханин on 31.01.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String


    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"

    }
}

