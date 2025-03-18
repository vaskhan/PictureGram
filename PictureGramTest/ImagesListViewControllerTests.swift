//
//  ImagesListViewControllerTests.swift
//  PictureGram
//
//  Created by Василий Ханин on 17.03.2025.
//

import XCTest
@testable import PictureGram

final class ImagesListViewControllerTests: XCTestCase {
    
    var sut: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось получить ImagesListViewController из storyboard")
            return
        }
        
        sut = viewController
        presenterSpy = ImagesListPresenterSpy()
        sut.setPresenter(presenterSpy)
        
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        sut.viewDidLoad()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testReloadTableAnimated_InsertsRows() {
        
        let tableViewSpy = TableViewSpy()
        sut.setValue(tableViewSpy, forKey: "tableView")
        
        sut.reloadTableAnimated(oldCount: 0, newCount: 2)
        
        XCTAssertTrue(tableViewSpy.insertRowsCalled)
        XCTAssertEqual(tableViewSpy.insertedIndexPaths, [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)])
    }
    
    func testShowLikeErrorAlert_PresentsAlert() {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        sut.showLikeErrorAlert()
        
        let presentedVC = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(presentedVC)
        XCTAssertEqual(presentedVC?.title, "Ошибка")
        XCTAssertEqual(presentedVC?.message, "Не удалось поставить лайк.")
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var viewDidLoadCalled = false
    var didTapLikeCalled = false
    
    var photosCount: Int {
        return 1
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at index: Int) -> Photo {
        return Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: "Test photo",
            thumbImageURL: "https://test.com/thumb.jpg",
            largeImageURL: "https://test.com/large.jpg",
            fullImageURL: "https://test.com/full.jpg",
            isLiked: false
        )
    }
    
    func didTapLike(at index: Int) {
        didTapLikeCalled = true
    }
    
    func didSelectRow(at index: Int) {
    }
    
    func willDisplayRow(at index: Int) {
    }
}

final class TableViewSpy: UITableView {
    
    var insertRowsCalled = false
    var insertedIndexPaths: [IndexPath] = []
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalled = true
        insertedIndexPaths = indexPaths
    }
    
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }
}
