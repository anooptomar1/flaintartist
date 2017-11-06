//
//  ArtSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import IGListKit

class ArtSectionController: ListSectionController, ListWorkingRangeDelegate {
    
    lazy var alert = Alerts()
    var art: Art?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        workingRangeDelegate = self
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if index == 0 {
            let height = collectionContext?.containerSize.height ?? 0
            return CGSize(width: (collectionContext?.containerSize.width)!, height: height - 60)
        } else {
             return CGSize(width: (collectionContext?.containerSize.width)!, height: 60)
        }
    }
    
    override func numberOfItems() -> Int {
        return 2
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        if index == 0 {
            guard let cell = collectionContext?.dequeueReusableCell(of: ArtCell.self, for: self, at: index) as? ArtCell, let url = URL(string: (art?.imgUrl)!) else {
                fatalError()
            }
            
            cell.artID = art?.artID
            cell.configure(url: url)
            return cell
        } else  {
            guard let cell = collectionContext?.dequeueReusableCell(of: ArtInfoCell.self, for: self, at: index) as? ArtInfoCell else {
                fatalError()
            }
            cell.title = art?.title
            cell.desc = art?.description
            return cell
        }
    }
    
    override func didUpdate(to object: Any) {
        art = object as? Art
    }
    
    override func didSelectItem(at index: Int) {
        let vc = self.viewController as! ProfileVC
        alert.artAlert(target: vc, art: art!)
    }
    
    // MARK: ListWorkingRangeDelegate
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
            guard let urlString = art?.imgUrl, let url = URL(string: urlString) else { return }
            DispatchQueue.main.async {
            if let cell = self.collectionContext?.cellForItem(at: 0, sectionController: self) as? ArtCell {
                cell.configure(url: url)
            }
        }
    }
    
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) {}
    
}

