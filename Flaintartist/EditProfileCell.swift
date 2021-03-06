//
//  EditProfileCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/27/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class EditProfileCell: UITableViewCell {
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    func configureCell() {
        
        DataService.instance.currentUserInfo { (user) in
            if let url = user?.profilePicUrl {
                self.profileImgView.sd_setImage(with: URL(string: url ), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
               self.nameLbl.text = user?.name
            }
        }
    }
}

