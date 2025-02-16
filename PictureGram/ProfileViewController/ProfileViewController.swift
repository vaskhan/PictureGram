//
//  ProfileViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 30.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileImageView: UIImageView = {
        let image = UIImage(named: "Avatar")
        let view = UIImageView(image: image)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont(name: "SFPro-Bold", size: 23)
        label.textColor = .white
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .lightGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        updateUI()
        profileImageServiceObserver = NotificationCenter.default    
                    .addObserver(
                        forName: ProfileImageService.didChangeNotification,
                        object: nil,
                        queue: .main
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.updateAvatar()
                    }
                updateAvatar()
    }
    
    private func updateAvatar() {
            guard
                let imageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: imageURL)
            else { return }
            // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        }
    
    private func updateUI() {
        if let profile = ProfileService.shared.profile {
            print("🟢 Отображаем профиль из памяти: \(profile.name)")
            nameLabel.text = profile.name
            loginLabel.text = profile.loginName
            descriptionLabel.text = profile.bio ?? "Нет описания"
        } else {
            print("🔴 Профиль отсутствует в памяти")
        }
    }
    
    private func setupViews() {
        [profileImageView, nameLabel, loginLabel, descriptionLabel, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
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


