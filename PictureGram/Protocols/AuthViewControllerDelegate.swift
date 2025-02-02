//
//  AuthViewControllerDelegate.swift
//  PictureGram
//
//  Created by Василий Ханин on 02.02.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
