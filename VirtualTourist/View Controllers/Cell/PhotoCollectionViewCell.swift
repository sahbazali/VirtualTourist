//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
