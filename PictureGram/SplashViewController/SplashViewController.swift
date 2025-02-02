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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
    }
    
    private func checkAuth() {
        if storage.token != nil {
            switchTabBarController()
        } else {
            performSegue(withIdentifier: showAuthScreenSegueIdentifier, sender: nil)
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

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure("Не удалось перейти на экран авторизации")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchTabBarController()
        }
    }
}
