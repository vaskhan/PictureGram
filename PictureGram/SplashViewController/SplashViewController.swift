//
//  SplashViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 02.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let showAuthScreenSegueIdentifier = "ShowAuthScreen"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🚀 SplashViewController появился на экране")
        checkAuth()
    }
    
    private func checkAuth() {
        print("🔑 Проверяем авторизацию...")
        print("📦 Текущий токен: \(storage.token ?? "nil")")
        if storage.token != nil {
            switchTabBarController()
        } else {
            performSegue(withIdentifier: showAuthScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchTabBarController() {
        print("🚀 Загружаем профиль перед переходом на TabBarController...")
        
        ProfileService.shared.fetchProfile { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                print("✅ Профиль загружен в синглтон. Переходим на главный экран.")
                
                guard let window = UIApplication.shared.windows.first else {
                    assertionFailure("Ошибка конфигурации")
                    return
                }
                
                let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                    .instantiateViewController(withIdentifier: "TabBarViewController")
                
                window.rootViewController = tabBarController
            }
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure("Не удалось перейти на экран авторизации")
                return
            }
            authViewController.delegate = self
            print("✅ Делегат установлен для AuthViewController")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            print("✅ Экран авторизации закрыт, загружаем профиль...")
            guard let self = self else { return }
            
            self.fetchProfileData()
            
        }
    }
    
    private func fetchProfileData() {
        print("📡 Запуск fetchProfileData()")
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile { [weak self] (result: Result<Profile, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let profile):
                    guard ProfileService.shared.profile != nil else {
                        self?.showErrorAlert(message: "Данные профиля не загружены")
                        return
                    }
                    
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] _ in
                        print("✅ Запрос аватара завершён, переходим к TabBarController")
                        self?.switchTabBarController()
                    }
                    
                    print("✅ Профиль успешно загружен: \(profile.name)")
                    self?.switchTabBarController()
                    print("Данные профиля: \(ProfileService.shared.profile?.name ?? "nil")")
                    
                case .failure(let error):
                    print("❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                    self?.showErrorAlert(message: error.localizedDescription)
                }
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
