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
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    var isLiked: Bool
}

final class ImagesListService {

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let photosPerPage = 10
    private let authToken = OAuth2TokenStorage().token
    private let urlSession = URLSession.shared
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private var lastLoadedPage = 0
    private var isLoading = false
    private(set) var photos: [Photo] = []

    func clearPhotos() {
        photos.removeAll()
        lastLoadedPage = 0
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
        print("Фото и данные страниц удалены")
    }
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        guard let authToken else {
            print("❌ Нет токена авторизации!")
            return
        }

        isLoading = true
        let nextPage = lastLoadedPage + 1

        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(photosPerPage)")
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        print("Загружаем страницу \(nextPage)")

        let task = urlSession.dataTask(with: request) { [weak self] data, _, error in
            guard
                let self = self,
                let data = data,
                error == nil,
                let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data)
            else {
                print("❌ Ошибка загрузки или декодирования данных")
                self?.isLoading = false
                return
            }

            print("✅ Загружено фото: \(photoResults.count)")

            let newPhotos = photoResults.map {
                Photo(
                    id: $0.id,
                    size: CGSize(width: $0.width, height: $0.height),
                    createdAt: self.dateFormatter.date(from: $0.createdAt),
                    welcomeDescription: $0.description,
                    thumbImageURL: $0.urls.thumb,
                    largeImageURL: $0.urls.regular,
                    fullImageURL: $0.urls.full,
                    isLiked: $0.likedByUser
                )
            }

            DispatchQueue.main.async {
                let existingIDs = Set(self.photos.map { $0.id })
                let filteredNewPhotos = newPhotos.filter { !existingIDs.contains($0.id) }
                
                self.photos.append(contentsOf: filteredNewPhotos)
                self.lastLoadedPage = nextPage
                self.isLoading = false
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let authToken else {
            print("❌ Нет токена авторизации!")
            completion(.failure(NSError(domain: "NoToken", code: 401, userInfo: nil)))
            return
        }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidUrl", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(String(describing: authToken))", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
        
            if let error = error {
                print("Ошибка получения лайка \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                var photo = self.photos[index]
                photo.isLiked.toggle()
                self.photos[index] = photo
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
}
