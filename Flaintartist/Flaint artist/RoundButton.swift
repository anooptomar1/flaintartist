//
//  RoundButton.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/9/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
