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
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPrepareForSegue() {
        let dummyPhoto = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: "Dummy",
            thumbImageURL: "dummyThumb",
            largeImageURL: "dummyLarge",
            fullImageURL: "https://example.com/full.jpg",
            isLiked: false
        )
        sut.testPhotos = [dummyPhoto, dummyPhoto, dummyPhoto]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as! SingleImageViewController
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: sut, destination: viewController)
        
        sut.prepare(for: segue, sender: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(viewController.imageURL, dummyPhoto.fullImageURL)
    }
}
