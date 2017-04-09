//
//  BorderImage.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import ChameleonFramework

class BorderImg: UIImageView {
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
    
    func configure(_ color: UIColor, width: CGFloat)  {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        
        let secondLayer = CALayer()
    }
    
}
