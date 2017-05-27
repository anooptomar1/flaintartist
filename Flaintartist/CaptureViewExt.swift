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

public extension UIWindow {
    func capture() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
