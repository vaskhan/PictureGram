//
//  TabBarController.swift
//  PictureGram
//
//  Created by Василий Ханин on 01.03.2025.
//


import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.setPresenter(imagesListPresenter)
        
        let profileViewController = ProfileViewController(presenter: nil)
        let presenter = ProfilePresenter(view: profileViewController)
        profileViewController.setPresenter(presenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        viewControllers = [imagesListViewController, profileViewController]
    }
}
