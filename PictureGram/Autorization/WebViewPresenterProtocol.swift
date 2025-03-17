//
//  WebViewPresenterProtocol.swift
//  PictureGram
//
//  Created by Василий Ханин on 16.03.2025.
//

import UIKit
@preconcurrency import WebKit

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: NSObject, WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    
    private let authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol = AuthHelper()) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        loadAuthView()
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    private func loadAuthView() {
        guard let request = authHelper.authRequest() else {
            print("❌ Не удалось получить request от AuthHelper")
            return
        }

        didUpdateProgressValue(0)
        view?.load(request: request)
    }
}

extension WebViewPresenter: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = authHelper.code(from: navigationAction) {
            if let viewController = view as? WebViewViewController {
                delegate?.webViewViewController(viewController, didAuthenticateWithCode: code)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}



