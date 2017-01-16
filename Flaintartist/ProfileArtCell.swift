//
//  ProfileArtCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/11/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseStorage

class ProfileArtCell: UICollectionViewCell {
    
    @IBOutlet var artImageView: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var sizeLbl: UILabel!
    @IBOutlet var descLbl: UILabel!
    
    
    
    var post: Art!
    
    func configureCell(_ post: Art, img: UIImage? = nil) {
        self.post = post
        if img != nil {
            self.artImageView.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imgUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("JESS: Unable to download image from Firebase storage")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.artImageView.image = img
                            self.artImageView.sd_setImage(with: URL(string: "\(post.imgUrl)"), placeholderImage:UIImage(named:"placeholder.png"))
                        }
                    }
                }
            })
        }
    }
}
