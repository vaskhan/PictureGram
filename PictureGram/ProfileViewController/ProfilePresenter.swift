//
//  ProfilePresenter.swift
//  PictureGram
//
//  Created by Василий Ханин on 18.03.2025.
//

import Foundation

protocol ProfilePresenterProtocol {
    func viewDidLoad()
    func logoutButtonTapped()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    
    private var profileServiceObserver: NSObjectProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?

    init(view: ProfileViewProtocol) {
        self.view = view
    }

    deinit {
        removeObservers()
    }

    func viewDidLoad() {
        setupObservers()
        updateProfile()
        updateAvatar()
    }

    private func setupObservers() {
        profileServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProfile()
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }

    private func removeObservers() {
        if let profileServiceObserver = profileServiceObserver {
            NotificationCenter.default.removeObserver(profileServiceObserver)
        }
        if let profileImageServiceObserver = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }

    private func updateProfile() {
        guard let profile = ProfileService.shared.profile else {
            print("❌ Профиль отсутствует")
            return
        }

        view?.updateProfile(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio ?? "Нет описания"
        )
    }

    private func updateAvatar() {
        guard let avatarString = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarString) else {
            print("❌ Аватар отсутствует")
            view?.updateAvatar(url: nil)
            return
        }

        view?.updateAvatar(url: url)
    }

    func logoutButtonTapped() {
        view?.showLogoutAlert()
    }

    func confirmLogout() {
        ProfileLogoutService.shared.logout()
        view?.navigateToSplashScreen()
    }
}
