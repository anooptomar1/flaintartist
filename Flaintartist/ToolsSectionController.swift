//
//  UserInfoSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit

class ToolsSectionController: ListSectionController, ListAdapterDataSource, UIScrollViewDelegate {

    lazy var artViewVC = ArtViewModelController()
    private var user: User?
    var arts = [Art]()
    private var expanded = false
    private var pageControl = FlexiblePageControl()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "You have no art yet. Click on the add (+) button to add one."
        label.backgroundColor = .clear
        return label
    }()
 
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self.viewController, workingRangeSize: 0)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        return adapter
    }()
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(markerActivated), name: markerIsActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markerDesactivated), name: markerIsDesactivated, object: nil)
    }
    
    
    @objc func markerActivated() {
        adapter.collectionView?.isScrollEnabled = false
    }
    
    @objc func markerDesactivated() {
        adapter.collectionView?.isScrollEnabled = true
    }
    
    func loadArts() {
        artViewVC.retrieveArts { (success, error, arts) in
            if !success {
                print("Error retrieving arts")
            } else {
                self.arts = arts
                DispatchQueue.main.async {
                   self.pageControl.numberOfPages = self.arts.count
                   self.pageControl.updateViewSize()
                }
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    override func numberOfItems() -> Int {
        return 3
    }

    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        if index == 0 {
            guard let cell = collectionContext?.dequeueReusableCell(of: UserInfoCell.self , for: self, at: index) as? UserInfoCell else {
                fatalError()
            }
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
            cell.arts = self.arts
            self.pageControl = cell.pageControl
            return cell
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
        if arts.count < 0 {
            return emptyLabel
        }
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
