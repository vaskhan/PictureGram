//
//  ProfileViewControllerTests.swift
//  PictureGram
//
//  Created by Василий Ханин on 17.03.2025.
//


import XCTest
@testable import PictureGram

final class ProfileViewControllerTests: XCTestCase {

    func testViewDidLoad_CallsPresenterViewDidLoad() {
        
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testUpdatesProfileAndUILabels() {
        
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)

        _ = viewController.view

        viewController.updateProfile(name: "name", login: "@login", bio: "bio")

        XCTAssertEqual(viewController.nameLabel.text, "name")
        XCTAssertEqual(viewController.loginLabel.text, "@login")
        XCTAssertEqual(viewController.descriptionLabel.text, "bio")
    }

    func testLogoutButtonTap() {
        
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)

        _ = viewController.view
        
        viewController.exitButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(presenter.logoutButtonTappedCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {

    var viewDidLoadCalled = false
    var logoutButtonTappedCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logoutButtonTapped() {
        logoutButtonTappedCalled = true
    }
}


