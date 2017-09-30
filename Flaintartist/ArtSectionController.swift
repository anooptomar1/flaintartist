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

protocol RemoveSectionControllerDelegate: class {
    func removeSectionControllerWantsRemoved(_ sectionController: ArtSectionController)
}

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
            cell.configure(url: url)
            cell.artRoomScene.boxnode.removeFromParentNode()
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
            if let cell = self.collectionContext?.cellForItem(at: 1, sectionController: self) as? ArtCell {
                cell.configure(url: url)
            }
        }
    }
    
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) {}
    
    
//    func alert() {
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
//
//        }
//        let share = UIAlertAction(title: "Share", style: .default) { (action) in
//
//        }
//
//        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
//            //collectionContext.
//        }
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(edit)
//        alert.addAction(share)
//        alert.addAction(delete)
//        alert.addAction(cancel)
//        self.viewController?.present(alert, animated: true, completion: nil)
//    }
    
}

