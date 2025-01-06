//
//  ImagesListCell.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.12.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
        
    // - MARK: IB Outlets
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // - MARK: Public properties
    static let reuseIdentifier = "ImagesListCell"
}
