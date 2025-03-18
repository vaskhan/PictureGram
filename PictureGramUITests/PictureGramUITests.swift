//
//  PictureGramUITests.swift
//  PictureGramUITests
//
//  Created by Василий Ханин on 18.03.2025.
//

import XCTest

class PictureGramUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("UITestsMode")
        app.launch()
    }
    
    func pasteText(for app: XCUIApplication) {
        let pasteMenuItems = [
            app.menuItems["Paste"],
            app.menuItems["Вставить"]
        ]
        
        guard let pasteMenuItem = pasteMenuItems.first(where: { $0.exists }) else {
            XCTFail("Не найден пункт Paste / Вставить")
            return
        }
        
        XCTAssertTrue(pasteMenuItem.waitForExistence(timeout: 2))
        pasteMenuItem.tap()
    }

    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 3))
        authButton.tap()
        
        print(app.debugDescription)

        let webView = app.webViews["WebViewViewController"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "webview не загрузился")

        UIPasteboard.general.string = "ya.v.khanin@gmail.com"
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 3))
        loginTextField.tap()
        loginTextField.doubleTap()
        
        pasteText(for: app)
        webView.swipeUp()
        
        UIPasteboard.general.string = "K6t8y8jyFJJ"
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))
        passwordTextField.tap()
        passwordTextField.doubleTap()
        
        pasteText(for: app)
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 3))
        loginButton.tap()
        
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        tablesQuery.element.swipeUp()
        XCTAssertTrue(app.tables.element.waitForExistence(timeout: 3))
        
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.exists)
        
        likeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        
        likeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        
        firstCell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        
        image.pinch(withScale: 3, velocity: 1)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        
        image.pinch(withScale: 0.5, velocity: -1)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        
        let backButton = app.buttons["backButton"]
        backButton.tap()
        
        sleep(3)
    }
    
    func testProfile() throws {
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.exists)
        profileTab.tap()
        
        let nameLabel = app.staticTexts["Vasiliy Khanin"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 3))
        
        let loginLabel = app.staticTexts["@vas_khan"]
        XCTAssertTrue(loginLabel.exists)
        
        let descriptionLabel = app.staticTexts["Нет описания"]
        XCTAssertTrue(descriptionLabel.exists)
        
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 3))
        
        let yesButton = logoutAlert.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
