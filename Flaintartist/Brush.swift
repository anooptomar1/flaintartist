//
//  Brush.swift
//  Flaintartist
//
//  Created by Kerby Jean on 11/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

open class Brush: NSObject {
    @objc open var color: UIColor = UIColor.black {
        willSet(colorValue) {
            self.color = colorValue
            isEraser = color.isEqual(UIColor.clear)
            blendMode = isEraser ? .clear : .normal
        }
    }
    @objc open var width: CGFloat = 5.0
    @objc open var alpha: CGFloat = 1.0
    
    @objc internal var blendMode: CGBlendMode = .normal
    @objc internal var isEraser: Bool = false
}
