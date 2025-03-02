//
//  ImagesListService.swift
//  PictureGram
//
//  Created by Василий Ханин on 02.03.2025.
//

import UIKit

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let regular: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

import Foundation
import UIKit

final class ImagesListService {

    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private let photosPerPage = 10
    private let authToken =  OAuth2TokenStorage().token
    private let urlSession = URLSession.shared
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private var lastLoadedPage = 0
    private var isLoading = false
    private(set) var photos: [Photo] = []

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        let nextPage = lastLoadedPage + 1

        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(photosPerPage)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(String(describing: authToken))", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard
                let self = self,
                let data = data,
                error == nil,
                let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data)
            else {
                self?.isLoading = false
                return
            }

            let newPhotos: [Photo] = photoResults.map { photoResult in
                let size = CGSize(width: photoResult.width, height: photoResult.height)
                let createdAtDate = self.dateFormatter.date(from: photoResult.createdAt)
                
                return Photo(
                    id: photoResult.id,
                    size: size,
                    createdAt: createdAtDate,
                    welcomeDescription: photoResult.description,
                    thumbImageURL: photoResult.urls.thumb,
                    largeImageURL: photoResult.urls.regular,
                    isLiked: photoResult.likedByUser
                )
            }

            DispatchQueue.main.async {
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                self.isLoading = false
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
        }
        task.resume()
    }
}

