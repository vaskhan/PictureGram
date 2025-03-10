//
//  ImagesListCell.swift
//  PictureGram
//
//  Created by Василий Ханин on 22.12.2024.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    private var currentImageURL: String?
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
    }
    
    func configure(with photo: Photo) {
        currentImageURL = photo.thumbImageURL
        let placeholder = UIImage(named: "stubFeed")
        imageCell.kf.indicatorType = .activity
        imageCell.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: placeholder)
        setIsLiked(photo.isLiked)
        dataLabel.text = photo.createdAt?.dateTimeString ?? "Неизвестная дата"
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active.png") : UIImage(named: "No Active.png")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
