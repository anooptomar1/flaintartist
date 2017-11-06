//
//  RegisterSectionController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
//import RxSwift
import IGListKit

class RegisterSectionController: ListSectionController, ListAdapterDataSource {
    
    let data: [Any] = [QuickLook(title: "Wireless. Effortless. Magical.", image: #imageLiteral(resourceName: "amandla"), color: UIColor(red: 233.0/255.0, green: 247.0/255.0, blue: 248.0/255.0, alpha: 1.0)), QuickLook(title: "The music you love. On the go.", image: #imageLiteral(resourceName: "amandlablack"), color: UIColor(displayP3Red: 245.0/255.0, green: 253.0/255.0, blue: 241.0/255.0, alpha: 1.0)), QuickLook(title: "Make the most of your music.", image: #imageLiteral(resourceName: "amandla"), color: UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 222.0/255.0, alpha: 1))]
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self.viewController, workingRangeSize: 2)
        adapter.dataSource = self
        return adapter
    }()

    override func sizeForItem(at index: Int) -> CGSize {
        let height: CGFloat = 180
        if index == 0 {
            return CGSize(width: collectionContext!.containerSize.width, height:collectionContext!.containerSize.height - (height + 40))
        } else if index == 1 {
            return CGSize(width: collectionContext!.containerSize.width, height: 40)
        } else {
            return CGSize(width: collectionContext!.containerSize.width, height: height / 3)
        }
    }
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 5
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {

        if index == 0 {
            let cell = collectionContext!.dequeueReusableCell(of: EmbeddedCollectionViewCell.self, for: self, at: index) as! EmbeddedCollectionViewCell
            adapter.collectionView = cell.collectionView
            return cell
        } else if index == 1 {
            let cell = collectionContext!.dequeueReusableCell(of: PageControlCell.self, for: self, at: index) as! PageControlCell
            adapter.delegate = cell
            return cell
        } else if index == 2 {
            let cell = collectionContext!.dequeueReusableCell(of: InputCell.self, for: self, at: index) as! InputCell
            return cell
        } else if index == 3 {
            let cell = collectionContext!.dequeueReusableCell(of: NextCell.self, for: self, at: index) as! NextCell
            return cell
        } else {
            let cell = collectionContext!.dequeueReusableCell(of: SignInCell.self, for: self, at: index) as! SignInCell
            return cell
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as! [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PageSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

