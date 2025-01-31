//
//  AuthViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.01.2025.
//
import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let webViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegueIdentifier{
            guard let webViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(webViewSegueIdentifier)")
                return
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
//        print("Получен код аутентификации: \(code)")
//        vc.dismiss(animated: true, completion: nil)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Аутентификация отменена пользователем")
        vc.dismiss(animated: true, completion: nil)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }
}

