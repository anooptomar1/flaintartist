//
//  SimilarCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/18/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SDWebImage
import ChameleonFramework


class SimilarCell: UICollectionViewCell {
    
    
    @IBOutlet weak var artImageView: UIImageView!

    var art: Art!

    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
    

    func configureCell(forArt: Art) {
        self.art = forArt
        artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: UIImage(named: "Placeholder") , options: .continueInBackground)
    }
}
