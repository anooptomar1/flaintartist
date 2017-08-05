//
//  PlayerLayer.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-06-30.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class VideoContainerView: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}

