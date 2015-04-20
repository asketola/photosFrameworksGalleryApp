//
//  PhotoThumbnail.swift
//  Photo Gallery App Tutorial with Frameworks
//
//  Created by Annemarie Ketola on 4/14/15.
//  Copyright (c) 2015 UpEarly. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    
    func setThumbnailImage(thumbnailImage: UIImage) {
        self.imgView.image = thumbnailImage
    }
    
}
