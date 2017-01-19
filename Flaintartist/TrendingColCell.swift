//
//  TrendingColCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseStorage

class TrendingColCell: UICollectionViewCell {
    
    @IBOutlet weak var artImgView: UIImageView!
    
    var post: Art!
    
    func configureCell(_ post: Art, img: UIImage? = nil) {
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
                            self.artImgView.sd_setImage(with: URL(string: "\(post.imgUrl)"), placeholderImage:UIImage(named:"placeholder.png"))
                        }
                    }
                }
            })
        }
    }
}

