//
//  ShadowImage.swift
//  Flaintartist
//
//  Created by Kerby Jean on 4/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class ShadowImage: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.layer.shadowColor = (UIColor.black as! CGColor)
        self.layer.shadowRadius = 2.0
    }
}
