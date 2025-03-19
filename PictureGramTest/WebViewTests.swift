//
//  PictureGramTest.swift
//  PictureGramTest
//
//  Created by Василий Ханин on 16.03.2025.
//

import Testing
@testable import PictureGram
import XCTest
import Foundation
import WebKit

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        
        let presenter = WebViewPresenter()
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        
        let presenter = WebViewPresenter()
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        let authHelper = AuthHelper()

        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        components.queryItems = [URLQueryItem(name: "code", value: "test code")]

        guard let url = components.url else {
            XCTFail("URL не создан")
            return
        }
        
        let code = authHelper.code(from: url)

        XCTAssertEqual(code, "test code")
    }

    
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        return nil
    }
    func didRequestNavigationPolicy(for url: URL?, completion: @escaping (NavigationPolicy) -> Void) {}

}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: PictureGram.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}

