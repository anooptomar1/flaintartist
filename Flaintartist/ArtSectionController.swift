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

class ArtSectionController: ListSectionController, ListWorkingRangeDelegate, ListAdapterUpdater {

    private var art: Art?
    private var downloadedImage: UIImage?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        workingRangeDelegate = self

    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: (collectionContext?.containerSize.width)!, height: height)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: ArtCell.self, for: self, at: index) as? ArtCell, let url = URL(string: (art?.imgUrl)!) else {
            fatalError()
        }
        cell.configure(url: url)
        cell.artRoomScene.boxnode.removeFromParentNode()
        return cell
    }
    
    override func didUpdate(to object: Any) {
        art = object as? Art
    }
    
    override func didSelectItem(at index: Int) {

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
}

