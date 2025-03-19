//
//  AuthViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.01.2025.
//
import UIKit
import ProgressHUD

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    weak var delegate: AuthViewControllerDelegate?
    
    private let webViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("🔄 Выполняется `prepare(for segue:)` в AuthViewController с идентификатором: \(segue.identifier ?? "nil")")
        
        guard segue.identifier == webViewSegueIdentifier,
              let webViewViewController = segue.destination as? WebViewViewController else {
            print("❌ Ошибка: переход на WebViewViewController не произошел")
            super.prepare(for: segue, sender: sender)
            return
        }
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = presenter
        presenter.view = webViewViewController
        presenter.delegate = self
        webViewViewController.delegate = self
        
        print("✅ Делегат WebViewViewController установлен")
    }
    
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let token):
                    print("Токен получен: \(token)")
                    vc.dismiss(animated: true) { [weak self] in
                        guard let self = self else {
                            print("❌ AuthViewController уже уничтожен перед вызовом delegate")
                            return
                        }
                        
                        print("🔍 Delegate в AuthViewController: \(self.delegate == nil ? "nil" : "установлен")")
                        self.dismiss(animated: true) {
                            self.delegate?.didAuthenticate(self)
                        }
                    }
                    
                case .failure(let error):
                    print("Ошибка авторизации: \(error.localizedDescription)")
                    self.showAuthErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Аутентификация отменена пользователем")
        vc.dismiss(animated: true, completion: nil)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: "Не удалось войти. Попробуйте ещё раз.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

