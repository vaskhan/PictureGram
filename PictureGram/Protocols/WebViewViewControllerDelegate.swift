//
//  WebViewViewControllerDelegate.swift
//  PictureGram
//
//  Created by Василий Ханин on 23.01.2025.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
