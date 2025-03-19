//
//  WebViewPresenterProtocol.swift
//  PictureGram
//
//  Created by Василий Ханин on 16.03.2025.
//

import Foundation

protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func didRequestNavigationPolicy(for url: URL?, completion: @escaping (NavigationPolicy) -> Void)
}

enum NavigationPolicy {
    case allow
    case cancel
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
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
    
    func didRequestNavigationPolicy(for url: URL?, completion: @escaping (NavigationPolicy) -> Void) {
        guard let url = url else {
            completion(.allow)
            return
        }

        if let code = authHelper.code(from: url) {
            if let viewController = view as? WebViewViewController {
                delegate?.webViewViewController(viewController, didAuthenticateWithCode: code)
            }
            completion(.cancel)
        } else {
            completion(.allow)
        }
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


