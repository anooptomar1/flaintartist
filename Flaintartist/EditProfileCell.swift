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
            self.profileImgView.setImageWith(URL(string: (user?.profilePicUrl)! ), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
            self.nameLbl.text = user?.name
        }
    }
}

