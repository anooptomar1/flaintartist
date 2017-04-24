//
//  NewArtistCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/27/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseStorage

class NewArtistCell: UICollectionViewCell {
    @IBOutlet var artistImageView: UIImageView!
    @IBOutlet var artistNameLbl: UILabel!
    
    var user: Users!
    
    func configureCell(forUser: Users) {
        self.user = forUser
        if let url = self.user.profilePicUrl {
            self.artistImageView.sd_setImage(with: URL(string: "\(url)") , placeholderImage: UIImage(named: "Placeholder") , options: .refreshCached)
        }
        artistNameLbl.text = user.name
    }
}

