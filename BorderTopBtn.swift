//
//  BorderTopBtn.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import UIKit

class BorderTopBtn: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let upperBorder = CALayer()
        upperBorder.backgroundColor = UIColor.flatWhite().cgColor
        upperBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1.0)
        self.layer.addSublayer(upperBorder)
    }
}

