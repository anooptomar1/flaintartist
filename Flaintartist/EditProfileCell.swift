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
    
    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.addSublayer(separator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
    }
    
    func configureCell(user: User) {
        if let url = user.profilePicUrl {
            self.profileImgView.sd_setImage(with: URL(string: url ))
        }
    }
}
