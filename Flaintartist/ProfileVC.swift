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

class ProfileVC: UIViewController, ListAdapterDataSource {
    
    lazy var loginVC = LoginViewController()
    private var user = [User]()
    var art: Art?

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "You have no art yet. Click on the add (+) button to add one."
        label.backgroundColor = .clear
        return label
    }()
    
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
                self.user = []
                self.user.append(user)
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
        return emptyLabel
    }
    
    
//
//    var user: Users?
//    var arts = [Art]()
//    var artImg = UIImage()
//    var tapGesture = UITapGestureRecognizer()
//    var searchController = UISearchController()
//
//    var v: UIImageView?
//    var pageControl: FlexiblePageControl!
//
//    var cell: ProfileArtCell?
//    var cameraBtnIsTapped: Bool = true
//
//    var galleryIndexPath: IndexPath?
//
//    enum MyBool {
//        case True
//        case False
//    }
//
//    var b = MyBool.False
//
//    fileprivate let artViewModelController = ArtViewModelController()
//
//
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        //self.isHeroEnabled = true
////        loadGallery()
////        setDelegate()
////        setupViews()
////        addGestures()
////    }
//
//
//    func loadGallery() {
//        artViewModelController.retrieveVideos { [weak self] (success, error, arts, user) in
//            guard let strongSelf = self else { return }
//            if !success {
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print(error)
//                    } else {
//
//                    }
//                }
//            } else {
//                self?.arts = arts
//                DispatchQueue.main.async {
//                    strongSelf.collectionView.reloadData()
//                }
//                guard let url = user?.profilePicUrl else { return }
//                    strongSelf.v?.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .continueInBackground, completed: { (image, error, cache, url) in
//                })
//            }
//        }
//    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationItem.hidesBackButton = true
//        self.navigationController?.setToolbarHidden(true, animated: false)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
//
//
//    // MARK: UIAction
//
//    @IBAction func cameraBtnTapped(sender: UIButton) {
//        for cell in collectionView.visibleCells   {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.rotateButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//            }, completion: { (true) in
//                let indexPath = self.collectionView.indexPath(for: cell as! ProfileArtCell)
//                let cell = self.collectionView.cellForItem(at: indexPath!) as! ProfileArtCell
//                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "TestVC") as! TestVC
//                //vc.artImage = cell.artImageView.image
//                //self.navigationController?.pushViewController(vc, animated: false)
//                self.navigationController?.isNavigationBarHidden = true
//            })
//        }
//   }
//
//
//    @IBAction func addBtnTapped(_ sender: Any) {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
//            self.navigationController?.present(vc, animated: false, completion: nil)
//    }
//
//
//
//    @IBAction func settingsBtnTapped(_ sender: Any) {
//
//        let settingsNav = storyboard?.instantiateViewController(withIdentifier: "SettingsNav") as! UINavigationController
//        let settingsVC = settingsNav.topViewController as! SettingsVC
//            settingsVC.user = user
//        //settingsNav.heroModalAnimationType = HeroDefaultAnimationType.selectBy(presenting:.zoom, dismissing:.slide(direction: .up))
//        //navigationController?.hero_replaceViewController(with: settingsNav)
//    }
//
//    @objc func swipe(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.right:
//                 let visibleItems = self.collectionView.indexPathsForVisibleItems as NSArray
//                 let currentItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
//                 let previousItem = IndexPath(row: currentItem.row - 1, section: 0)
//                 if indexPathIsValid(indexPath: previousItem) {
//                    self.collectionView.scrollToItem(at: previousItem , at: .right, animated: true)
//                    self.swipeLabel.text = "Now tap to view more."
//                 }
//                 swipeLabel.isHidden = true
//            case UISwipeGestureRecognizerDirection.left:
//                let visibleItems = self.collectionView.indexPathsForVisibleItems as NSArray
//                let currentItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
//                let nextItem = IndexPath(row: currentItem.row + 1, section: 0)
//
//                if indexPathIsValid(indexPath: nextItem) {
//                    self.collectionView.scrollToItem(at: nextItem, at: .right, animated: true)
//                }
//            default:
//                break
//            }
//        }
//    }
//
//    func indexPathIsValid(indexPath: IndexPath) -> Bool {
//        let section = indexPath.section
//        let row = indexPath.row
//        let lastSectionIndex = numberOfSections(in: collectionView) - 1
//        //Make sure the specified section exists
//        if section > lastSectionIndex {
//            return false
//        }
//        let rowCount = self.collectionView(
//            collectionView, numberOfItemsInSection: indexPath.section) - 1
//
//        return row <= rowCount
//    }
//
//
//    //MARK: SearchResultDelegate
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//           pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            self.pageControl.isHidden = false
//            return artViewModelController.viewModelsCount
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//       var art = arts[indexPath.row]
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
//            self.galleryIndexPath = indexPath
//            cell.profileVC = self
//            art = arts[indexPath.row]
//            cell.artRoomScene.boxnode.removeFromParentNode()
//            cell.configureCell(art)
//            return cell
//        } else {
//            return ProfileArtCell()
//        }
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        let art: Art?
//        art = arts[indexPath.row]
//        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
//            let artImage = cell.artImageView.image
//            let artRoomScene = cell.artRoomScene
//            self.showRequestAlert(artImage: artImage, art: art, artRoomScene: artRoomScene)
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SettingsVC" {
//            let settingsVC = segue.destination as! SettingsVC
//            if let user = sender as? Users {
//                settingsVC.user = user
//            }
//        }
//    }
}



