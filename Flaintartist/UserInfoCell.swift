//
//  UserInfoCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable

class UserInfoCell: UICollectionViewCell, NibReusable {

    @IBOutlet weak var imageView: UIImageView!
    var user: User?
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsVC)))
    }
    
     @objc func settingsVC() {
        let vc =  SettingsVC()
        vc.user = user
        self.viewController?.present(vc, animated: true, completion: nil)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.addSublayer(separator)
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }

}
