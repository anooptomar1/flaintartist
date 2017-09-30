//
//  EditSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-29.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit

class EditSectionController: ListSectionController {
    
    lazy var artViewVC = ArtViewModelController()
    private var art: Art?
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 50)
    }
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 2
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellClass: AnyClass = index == 0 ? TitleCell.self : DescriptionCell.self
        let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index)
        if let cell = cell as? TitleCell {
            cell.configure(title: (art?.title)!)
        } else if let cell = cell as? DescriptionCell {
            cell.configure(description: (art?.description)!)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        art = object as? Art
    }
    
    override func didSelectItem(at index: Int) {

    }
}

