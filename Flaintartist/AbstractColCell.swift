//
//  AbstractColCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import Foundation
import UIKit
import FirebaseStorage

class AbstractColCell: UICollectionViewCell {
    @IBOutlet weak var artImgView: FXImageView!
    
    var post: Art!
    
    func configureCell(_ post: Art, img: UIImage? = nil) {
        artImgView.shadowOffset = CGSize(width: 0.0, height: 5.0)
        artImgView.shadowBlur = 5.0
        self.post = post
        if img != nil {
            self.artImgView.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imgUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("JESS: Unable to download image from Firebase storage")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.artImgView.image = img
                            AbstractTabCell.imageCache.setObject(img, forKey: post.imgUrl as NSString)
                        }
                    }
                }
            })
        }
    }
}
