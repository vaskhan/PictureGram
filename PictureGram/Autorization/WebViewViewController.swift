//
//  WebViewViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.01.2025.
//
import UIKit
@preconcurrency import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
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
        
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "WebViewViewController"
        
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
        print("🚀 Загружаю request в webView: \(request.url?.absoluteString ?? "nil")")
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let url = navigationAction.request.url
        
        presenter?.didRequestNavigationPolicy(for: url) { [weak self] policy in
            guard self != nil else { return }

            switch policy {
            case .allow:
                decisionHandler(.allow)

            case .cancel:
                decisionHandler(.cancel)
            }
        }
    }
}


