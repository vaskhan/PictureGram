//
//  ImagesListPresenterTests.swift
//  PictureGram
//
//  Created by Василий Ханин on 18.03.2025.
//


import XCTest
@testable import PictureGram

final class ImagesListPresenterTests: XCTestCase {

    var presenter: ImagesListPresenter!
    var view: ImagesListViewSpy!
    var imagesListService: ImagesListServiceStub!

    override func setUp() {
        super.setUp()
        view = ImagesListViewSpy()
        imagesListService = ImagesListServiceStub()
        presenter = ImagesListPresenter(view: view, service: imagesListService)
    }

    override func tearDown() {
        presenter = nil
        view = nil
        imagesListService = nil
        super.tearDown()
    }

    func testViewDidLoad_FetchesNextPage() {
        presenter.viewDidLoad()
        XCTAssertTrue(imagesListService.fetchNextPageCalled)
    }

    func testDidTapLike_SuccessUpdatesPhotosAndReloads() {
        presenter.viewDidLoad()
        presenter.didTapLike(at: 0)

        XCTAssertTrue(imagesListService.changeLikeCalled)
        XCTAssertTrue(view.reloadTableAnimatedCalled)
    }

    func testDidTapLike_FailureShowsAlert() {
        imagesListService.shouldFailOnChangeLike = true

        presenter.viewDidLoad()
        presenter.didTapLike(at: 0)

        XCTAssertTrue(view.showLikeErrorAlertCalled)
    }
}

final class ImagesListViewSpy: ImagesListViewProtocol {
    
    var reloadTableAnimatedCalled = false
    var showLikeErrorAlertCalled = false

    func reloadTableAnimated(oldCount: Int, newCount: Int) {
        reloadTableAnimatedCalled = true
    }

    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
    
    func reloadRow(at index: Int) {
    }
}

final class ImagesListServiceStub: ImagesListServiceProtocol {

    var fetchNextPageCalled = false
    var changeLikeCalled = false
    var shouldFailOnChangeLike = false

    var photos: [Photo] = [
        Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: "Test photo 1",
            thumbImageURL: "https://test.com/thumb1.jpg",
            largeImageURL: "https://test.com/large1.jpg",
            fullImageURL: "https://test.com/full1.jpg",
            isLiked: false
        ),
        Photo(
            id: "2",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: "Test photo 2",
            thumbImageURL: "https://test.com/thumb2.jpg",
            largeImageURL: "https://test.com/large2.jpg",
            fullImageURL: "https://test.com/full2.jpg",
            isLiked: true
        )
    ]

    func fetchPhotosNextPage() {
        fetchNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true

        if shouldFailOnChangeLike {
            completion(.failure(NSError(domain: "Test", code: 0)))
        } else {
            completion(.success(()))
        }
    }
}
