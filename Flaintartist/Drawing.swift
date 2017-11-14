//
//  Drawing.swift
//  Flaintartist
//
//  Created by Kerby Jean on 11/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

open class Drawing: NSObject {
    @objc open var stroke: UIImage?
    @objc open var background: UIImage?
    
    @objc public init(stroke: UIImage? = nil, background: UIImage? = nil) {
        self.stroke = stroke
        self.background = background
    }
}
