//
//  ImagesListPresenter.swift
//  PictureGram
//
//  Created by Василий Ханин on 18.03.2025.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
    func didSelectRow(at index: Int)
    func willDisplayRow(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    
    private weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewProtocol, service: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imagesListService = service
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        observeServiceUpdates()
        imagesListService.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func didSelectRow(at index: Int) {
    }
    
    func willDisplayRow(at index: Int) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UITestsMode") {
            return
        }
        #endif
        
        if index == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at index: Int) {
        let photo = photos[index]
        
        view?.showLoading()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success:
                    self.photos[index].isLiked.toggle()
                    self.view?.updateLikeButton(at: index, isLiked: self.photos[index].isLiked)
                    
                case .failure:
                    self.view?.showLikeErrorAlert()
                }
            }
        }
    }
    
    
    private func observeServiceUpdates() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let servicePhotos = self.imagesListService.photos
            
            let oldCount = self.photos.count
            let newCount = servicePhotos.count
            
            guard newCount > oldCount else { return }
            
            let newPhotos = servicePhotos.suffix(from: oldCount)
            self.photos.append(contentsOf: newPhotos)
            
            self.view?.reloadTableAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
}
