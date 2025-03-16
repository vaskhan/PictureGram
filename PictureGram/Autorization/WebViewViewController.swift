//
//  WebViewViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.01.2025.
//
import UIKit
@preconcurrency import WebKit

//enum WebViewConstants {
//    static let unsplashAuthorizeURLString =
//        "https://unsplash.com/oauth/authorize"
//}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?

    private var estimatedProgressObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0

        webView.navigationDelegate = presenter as? WKNavigationDelegate

        presenter?.viewDidLoad()

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let estimatedProgress = self?.webView.estimatedProgress
                else { return }
                self?.presenter?.didUpdateProgressValue(estimatedProgress)
            })
    }

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
