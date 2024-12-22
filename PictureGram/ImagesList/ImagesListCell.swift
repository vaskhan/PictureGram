//
//  ImagesListCell.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.12.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    // - MARK: Public properties
    static let reuseIdentifier = "ImagesListCell"
    
    // - MARK: IB Outlets
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
}
