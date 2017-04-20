//
//  NavigationTransition.swift
//  Flaintartist
//
//  Created by Kerby Jean on 4/10/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import QuartzCore

class NavigationTransition: UINavigationController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionMoveIn
        self.view.layer.add(transition, forKey: nil)
    }
}
