//
//  ProfilePresenterTests.swift
//  PictureGram
//
//  Created by Василий Ханин on 18.03.2025.
//


import XCTest
@testable import PictureGram

final class ProfilePresenterTests: XCTestCase {
    
    func testUpdateProfileAndAvatar() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter(view: view)
        
        ProfileService.shared.profile = Profile(
            username: "username",
            name: "name",
            loginName: "@login",
            bio: "bio"
        )
        
        ProfileImageService.shared.avatarURL = "https://test.com/avatar.jpg"
        presenter.viewDidLoad()
        
        XCTAssertTrue(view.updateProfileCalled)
        XCTAssertTrue(view.updateAvatarCalled)
    }
    
    func testLogoutButtonTapped() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter(view: view)
        
        presenter.logoutButtonTapped()
        
        XCTAssertTrue(view.showLogoutAlertCalled)
    }
    
    func testConfirmLogout_NavigatesToSplashScreen() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter(view: view)
        
        presenter.confirmLogout()
        
        XCTAssertTrue(view.navigateToSplashScreenCalled)
    }
}

final class ProfileViewSpy: ProfileViewProtocol {
    
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    
    var receivedName: String?
    var receivedLogin: String?
    var receivedBio: String?
    var receivedAvatarURL: URL?
    
    var navigateToSplashScreenCalled = false
    func navigateToSplashScreen() {
        navigateToSplashScreenCalled = true
    }
    
    func updateProfile(name: String, login: String, bio: String) {
        updateProfileCalled = true
        receivedName = name
        receivedLogin = login
        receivedBio = bio
    }
    
    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
