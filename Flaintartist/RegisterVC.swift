//
//  CreateAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import FirebaseAuth

class RegisterVC: UIViewController, ListAdapterDataSource {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let data: [Any] = [QuickLook(title: "", image: #imageLiteral(resourceName: "amandla"), color: UIColor(red: 245, green: 253, blue: 241, alpha: 1))]
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @IBAction func logIn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignInNav") as! UINavigationController
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: ListAdapterDataSource
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as! [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return RegisterSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}


