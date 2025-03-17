//
//  SplashViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 02.02.2025.
//

import UIKit
import Kingfisher

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let showAuthScreenSegueIdentifier = "ShowAuthScreen"
    private let profileService = ProfileService.shared
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isAuthCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfigUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("🚀 SplashViewController появился на экране")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkAuth()
            }
    }
    
    private func setupConfigUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func checkAuth() {
        print("🔑 Проверяем авторизацию...")
        print("📦 Текущий токен: \(storage.token ?? "nil")")
        
        if isAuthCompleted {
                print("✅ Авторизация уже завершена, не проверяем токен заново!")
                return
            }
        
        if storage.token != nil {
            fetchProfileData()
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                return
            }
            
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }

    
    private func switchTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка конфигурации")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        isAuthCompleted = true
        vc.dismiss(animated: true) { [weak self] in
            print("✅ Экран авторизации закрыт, загружаем профиль...")
            guard let self = self else { return }
            
            self.fetchProfileData()
        }
    }
    
    private func fetchProfileData() {
        print("📡 Запуск fetchProfileData()")
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                print("✅ Профиль успешно загружен: \(profile.name)")
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    if case .success(let imageURL) = result {
                        KingfisherManager.shared.retrieveImage(with: URL(string: imageURL)!) { _ in
                            print("✅ [Splash]: Аватар предзагружен")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.switchTabBarController()
                    }
                }
                
            case .failure(let error):
                print("❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchProfileData()
        }
        alert.addAction(retryAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
