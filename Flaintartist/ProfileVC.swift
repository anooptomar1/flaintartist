//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//
import UIKit
import IGListKit
import FirebaseAuth

class ProfileVC: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    
    lazy var loginVC = LoginViewController()
    private var user = [User]()
    
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
        retrieveUser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func retrieveUser()  {
        loginVC.retrieveUserInfo(Auth.auth().currentUser!.uid) { (success, error, user) in
            if !success {
                print("Failed to retrieve user")
            } else {
                print("USER: \(user.name)")
                self.user = []
                self.user.insert(user, at: 0)
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    // MARK: ListAdapterDataSource
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return user as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
            return ToolsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}



