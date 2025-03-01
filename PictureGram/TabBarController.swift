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
        )
        
        let profileViewController = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
