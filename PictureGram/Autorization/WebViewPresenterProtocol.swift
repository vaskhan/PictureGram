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
    func code(from navigationAction: WKNavigationAction) -> String?
}

final class WebViewPresenter: NSObject, WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    weak var delegate: WebViewViewControllerDelegate?

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

    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }

    private func loadAuthView() {
        guard
            var urlComponents = URLComponents(
                string: WebViewConstants.unsplashAuthorizeURLString)
        else {
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)

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
        if let code = code(from: navigationAction) {
            if let viewController = view as? WebViewViewController {
                delegate?.webViewViewController(
                    viewController, didAuthenticateWithCode: code)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
