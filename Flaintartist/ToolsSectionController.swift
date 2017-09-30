//
//  UserInfoSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit

class ToolsSectionController: ListSectionController, ListAdapterDataSource {
    
    lazy var artViewVC = ArtViewModelController()
    private var user: User?
    private var arts = [Art]()
    private var expanded = false
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self.viewController, workingRangeSize: 2)
        adapter.dataSource = self
        return adapter
    }()
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height: CGFloat = 90
        if index == 0 || index == 2 {
            return CGSize(width: collectionContext!.containerSize.width, height: height / 2)
        } else {
            return CGSize(width: collectionContext!.containerSize.width, height: collectionContext!.containerSize.height - (height + 20))
        }
    }
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        loadArts()
    }
    
    func loadArts() {
        artViewVC.retrieveArts { (success, error, arts) in
            if !success {
                print("Error retrieving arts")
            } else {
                self.arts = arts
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    override func numberOfItems() -> Int {
        return 3
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        if index == 0 {
            guard let cell = collectionContext?.dequeueReusableCell(withNibName: UserInfoCell.reuseIdentifier, bundle: Bundle.main, for: self, at: index) as? UserInfoCell else {
                fatalError()
            }
            cell.imageView.sd_setImage(with: URL(string: (user?.profilePicUrl)!))
            cell.user = user
            return cell
        } else if index == 1 {
            let cell = collectionContext!.dequeueReusableCell(of: EmbeddedCollectionViewCell.self , for: self, at: index)
            if let cell = cell as? EmbeddedCollectionViewCell {
                adapter.collectionView = cell.collectionView
            }
            return cell
        } else {
            guard let cell = collectionContext?.dequeueReusableCell(withNibName: ToolCell.reuseIdentifier, bundle: Bundle.main, for: self, at: index) as? ToolCell else {
                fatalError()
            }
            return cell
        }
    }
    
    override func didSelectItem(at index: Int) {
        if index == 3 {
            print("SELECT")
            guard let cell = collectionContext?.cellForItem(at: 2, sectionController: self) as? ArtInfoCell else {
                fatalError()
            }
            cell.label.textColor = .darkText
            cell.descriptionLabel.textColor = .darkText
        }
    }
    
     
    override func didUpdate(to object: Any) {
        self.user = object as? User
    }

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
         return arts as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
         return ArtSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil 
    }
    
    
}
