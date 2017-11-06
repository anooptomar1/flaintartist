//
//  PageSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
struct GradientConfig {
    
    let topColor: UIColor
    let bottomColor: UIColor
    
    static var defaultGradient: GradientConfig {
        return GradientConfig(topColor: .black, bottomColor: .black)
    }
}

class PageSectionController: ListSectionController {
    
    private var data: QuickLook?
 
    let gradients: [GradientConfig] = [
        GradientConfig(topColor: UIColor(red:0.01, green:0.00, blue:0.18, alpha:1.0), bottomColor: UIColor(red:0.00, green:0.53, blue:0.80, alpha:1.0)),
        GradientConfig(topColor: UIColor(red:0.20, green:0.08, blue:0.00, alpha:1.0), bottomColor: UIColor(red:0.69, green:0.36, blue:0.00, alpha:1.0)),
        GradientConfig(topColor: UIColor(red:0.00, green:0.13, blue:0.05, alpha:1.0), bottomColor: UIColor(red:0.00, green:0.65, blue:0.33, alpha:1.0)),
        GradientConfig(topColor: UIColor(red:0.18, green:0.00, blue:0.20, alpha:1.0), bottomColor: UIColor(red:0.64, green:0.00, blue:0.66, alpha:1.0)),
        GradientConfig(topColor: UIColor(red:0.20, green:0.00, blue:0.00, alpha:1.0), bottomColor: UIColor(red:0.69, green:0.00, blue:0.00, alpha:1.0))
    ]
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: collectionContext!.containerSize.height)
    }
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: PageCell.self, for: self, at: index) as? PageCell else {
            fatalError()
        }
        cell.configure(look: data!)
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.data = object as? QuickLook
    }
}



