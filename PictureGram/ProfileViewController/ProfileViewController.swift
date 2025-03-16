//
//  ProfileViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 30.12.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    @objc private let profileImageView: UIImageView = {
        let image = UIImage(named: "Avatar")
        let view = UIImageView(image: image)
        return view
    }()
    
    @objc private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont(name: "SFPro-Bold", size: 23)
        label.textColor = .white
        return label
    }()
    
    @objc private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .ypLightGray
        return label
    }()
    
    @objc private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .white
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "exitButtonImage")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private var profile: Profile?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        updateUI()
        showLogoutAllert()
        
        profileServiceObserver = NotificationCenter.default.addObserver (
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateUI()
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            print("📬 [ProfileViewController]: Получено уведомление от ProfileImageService")
            if let url = notification.userInfo?["URL"] as? String {
                print("📬 [ProfileViewController]: URL из userInfo: \(url)")
            }
            self.updateAvatar()
        }
        
        updateAvatar()
    }
    
    deinit {
        if let profileServiceObserver = profileServiceObserver {
            NotificationCenter.default.removeObserver(profileServiceObserver)
        }
        if let profileImageServiceObserver = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }
    
    private func showLogoutAllert() {
        let exitAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "Пока, пока!",
                message: "Уверены что хотите выйти?",
                preferredStyle: .alert
            )
            
            let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
                ProfileLogoutService.shared.logout()
                
                UIApplication.shared.windows.first?.rootViewController = SplashViewController()
            }
            
            let noAction = UIAlertAction(title: "Нет", style: .default)
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true)
        }
        
        exitButton.addAction(exitAction, for: .touchUpInside)
    }
    
    func updateAvatar() {
        guard let avatarURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURL) else {
            print("❌ [updateAvatar]: avatarURL отсутствует или некорректен")
            profileImageView.image = UIImage(named: "Avatar")
            return
        }
        
        print("✅ [updateAvatar]: Загружаем аватар по URL: \(url)")
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Avatar"),
            options: [.transition(.fade(0.3))]
        ) { result in
            switch result {
            case .success:
                print("✅ [updateAvatar]: Аватар успешно установлен")
            case .failure(let error):
                print("❌ [updateAvatar]: Ошибка загрузки аватара: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUI() {
        if let profile = ProfileService.shared.profile {
            print("✅ Отображаем профиль из памяти: \(profile.name)")
            nameLabel.text = profile.name
            loginLabel.text = profile.loginName
            descriptionLabel.text = profile.bio ?? "Нет описания"
        } else {
            print("❌ Профиль отсутствует в памяти")
            view.subviews.forEach { $0.removeFromSuperview() }
            setupViews()
            setupConstraints()
        }
    }
    
    private func setupViews() {
        [profileImageView, nameLabel, loginLabel, descriptionLabel, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}


