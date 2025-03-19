//
//  ProfileViewController.swift
//  PictureGram
//
//  Created by Василий Ханин on 30.12.2024.
//

import UIKit
import Kingfisher

// MARK: - ProfileViewProtocol
protocol ProfileViewProtocol: AnyObject {
    func updateProfile(name: String, login: String, bio: String)
    func updateAvatar(url: URL?)
    func showLogoutAlert()
    func navigateToSplashScreen()
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    // MARK: - UI Elements
    let profileImageView: UIImageView = {
        let image = UIImage(named: "Avatar")
        let view = UIImageView(image: image)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont(name: "SFPro-Bold", size: 23)
        label.textColor = .white
        return label
    }()
    
    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .ypLightGray
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .white
        return label
    }()
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "exitButtonImage")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.accessibilityIdentifier = "Logout"
        return button
    }()
    
    // MARK: - Properties
    private var presenter: ProfilePresenterProtocol?
    
    // MARK: - Init
    init(presenter: ProfilePresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - ProfileViewProtocol Methods
    func updateProfile(name: String, login: String, bio: String) {
        nameLabel.text = name
        loginLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(url: URL?) {
        guard let url = url else {
            profileImageView.image = UIImage(named: "Avatar")
            return
        }
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Avatar"),
            options: [.transition(.fade(0.3))]
        )
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.confirmLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    func setPresenter(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    func navigateToSplashScreen() {
        UIApplication.shared.windows.first?.rootViewController = SplashViewController()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .ypBlack
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        
        [profileImageView, nameLabel, loginLabel, descriptionLabel, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        configureExitButton()
        setupConstraints()
    }
    
    private func configureExitButton() {
        exitButton.addAction(UIAction { [weak self] _ in
            self?.presenter?.logoutButtonTapped()
        }, for: .touchUpInside)
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
