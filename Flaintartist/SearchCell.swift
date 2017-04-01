//
//  SearchCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    @IBOutlet var artistImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    
    var user: Users!
    
    func configureCell(forUser: Users) {
        self.user = forUser
        DispatchQueue.main.async {
            if let url = self.user.profilePicUrl {
            self.artistImageView.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named:"Placeholder") , options: .continueInBackground, completed: nil)
            }
            self.nameLbl.text = self.user.name
            
        }
    }
}

