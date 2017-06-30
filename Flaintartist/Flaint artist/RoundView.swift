//
//  RoundView.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/9/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

extension UIView {

    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 100, height: 100)).cgPath
        self.layer.mask = maskLayer
    }
    
}
