//
//  CaptureViewExt.swift
//  Flaintartist
//
//  Created by Kerby Jean on 4/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
        func captureView() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
