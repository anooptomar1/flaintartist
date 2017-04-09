//
//  RoundImage.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/19/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class RoundImage: UIImageView {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderColor = UIColor.flatGray().cgColor
        self.layer.borderWidth = 0.5
        self.clipsToBounds = true
    }
}
