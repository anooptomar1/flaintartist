//
//  EditVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-28.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit

class EditVC: UIViewController, ListAdapterDataSource {
    
    lazy var loginVC = LoginViewController()
    var art = [Art]()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        adapter.collectionView = collectionView
        adapter.dataSource = self
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.back))
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        navigationItem.leftBarButtonItem  = cancel
        navigationItem.rightBarButtonItem  = save
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func save() {
        let art = self.art[0] as? Art
    }
    

    // MARK: ListAdapterDataSource
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return art as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return EditSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
