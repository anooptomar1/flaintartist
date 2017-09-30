//
//  EditProfileCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class EditProfileCell: UITableViewCell {
    @IBOutlet weak var profileImgView: UIImageView!
    
    func configureCell(user: User) {
        if let url = user.profilePicUrl {
            self.profileImgView.sd_setImage(with: URL(string: url ))
        }
    }
}
