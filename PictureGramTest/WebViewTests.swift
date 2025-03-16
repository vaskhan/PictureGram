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
        let presenter = WebViewPresenter()
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
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter()
        presenter.view = viewController

        presenter.viewDidLoad()

        guard let request = viewController.cureentRequest,
              let urlString = request.url?.absoluteString else {
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
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        components.queryItems = [URLQueryItem(name: "code", value: "test code")]
        
        guard let url = components.url else {
                XCTFail("Not created URL")
                return
            }
        
        let request = URLRequest(url: url)
        let presenter = WebViewPresenter()
        
        
        let code = presenter.code(from: request)
        
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
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: PictureGram.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    var cureentRequest: URLRequest?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        cureentRequest = request
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}

