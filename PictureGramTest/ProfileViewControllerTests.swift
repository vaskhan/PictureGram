//
//  ProfileViewControllerTests.swift
//  PictureGram
//
//  Created by Василий Ханин on 17.03.2025.
//


import XCTest
@testable import PictureGram

final class ProfileViewControllerTests: XCTestCase {
    
    var sut: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testUpdateUI() {
        let dummyProfile = Profile(username: "testuser",
                                   name: "Test User",
                                   loginName: "@testuser",
                                   bio: "Test bio")
        
        ProfileService.shared.profile = dummyProfile
        sut.updateUI()
        
        let nameLabel = sut.value(forKey: "nameLabel") as? UILabel
        let loginLabel = sut.value(forKey: "loginLabel") as? UILabel
        let descriptionLabel = sut.value(forKey: "descriptionLabel") as? UILabel
        
        XCTAssertEqual(nameLabel?.text, dummyProfile.name)
        XCTAssertEqual(loginLabel?.text, dummyProfile.loginName)
        XCTAssertEqual(descriptionLabel?.text, dummyProfile.bio ?? "Нет описания")
    }
    
    func testUpdateAvatar() {
        
        ProfileImageService.shared.avatarURL = nil
        
        sut.updateAvatar()
        
        let profileImageView = sut.value(forKey: "profileImageView") as? UIImageView
        let defaultImage = UIImage(named: "Avatar")
        XCTAssertNotNil(profileImageView?.image)
        XCTAssertEqual(profileImageView?.image?.pngData(), defaultImage?.pngData())
    }
}
