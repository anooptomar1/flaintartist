//
//  NewsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SwiftyUserDefaults


class NewsVC: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    var modern = [Art]()
    var abstract = [Art]()
    var realism = [Art]()
    var art: Art!
    
    var categories = ["Modern", "Abstract", "Realism"]
    
    let headBttn:UIButton = UIButton(type: .system)
    var refreshControl: UIRefreshControl!
    
    var type: String!
    var searchController = UISearchController(searchResultsController: nil)
    var searchBar = UISearchBar()
    
    let locationManager = CLLocationManager()
    var geoFire: GeoFire!
    var userId = FIRAuth.auth()?.currentUser?.uid
    var startLocation: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLbl.text = "Explore"
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NewsVC.refresh), for: UIControlEvents.valueChanged)
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //        searchBar.showsCancelButton = false
        //        searchBar.placeholder = "Explore artists & arts"
        //        searchBar.searchBarStyle = .default
        //        searchBar.delegate = self
        //        self.navigationItem.titleView = searchBar
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let geoFireRef = DataService.instance.REF_BASE.child("users_location")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        self.locationAuthStatus()
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        var vc = storyboard?.instantiateViewController(withIdentifier: "PageMenuVC")
        if #available(iOS 10.0, *) {
            vc = storyboard?.instantiateViewController(withIdentifier: "PageMenuVC") as! PageMenuVC
        } else {
            vc = storyboard?.instantiateViewController(withIdentifier: "PageMenuVC")
        }
        vc?.navigationItem.setHidesBackButton(true, animated:true)
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func locationAuthStatus() {
        print("LOCATION")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func setLocation(location: CLLocation) {
        queue.async(qos: .background) {
            Defaults[.latitude] = location.coordinate.latitude
            Defaults[.longitude] = location.coordinate.longitude
            self.geoFire.setLocation(location, forKey: self.userId)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        self.setLocation(location: location)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        queue.async(qos: .userInitiated) {
            DataService.instance.REF_ARTS.queryOrdered(byChild: "type").queryEqual(toValue: "Modern").queryLimited(toLast: 4).observe(.value) { [weak self] (snapshot: FIRDataSnapshot) in
                self?.modern = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                            if isPrivate == false {
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let art = Art(key: key, artData: postDict)
                                       self?.modern.append(art)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            
            DataService.instance.REF_ARTS.queryOrdered(byChild: "type").queryEqual(toValue: "Abstract").queryLimited(toLast: 4).observe(.value) { [weak self] (snapshot: FIRDataSnapshot) in
                self?.abstract = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                            if isPrivate == false {
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let art = Art(key: key, artData: postDict)
                                    self?.abstract.append(art)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            
            DataService.instance.REF_ARTS.queryOrdered(byChild: "type").queryEqual(toValue: "Realism").queryLimited(toLast: 4).observe(.value) { [weak self] (snapshot: FIRDataSnapshot) in
                self?.realism = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                            if isPrivate == false {
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let art = Art(key: key, artData: postDict)
                                    self?.realism.append(art)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.modern.removeAll()
//        self.abstract.removeAll()
//        self.realism.removeAll()
        DataService.instance.REF_ARTS.removeAllObservers()
    }
    
    
    func refresh(_ sender: AnyObject) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat
        let height : CGFloat
        width = collectionView.frame.width
        height = 600
        return CGSize(width: width, height: height)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewsHeaderView", for: indexPath) as! HeaderCollectionReusableView
        headerView.headerLbl.text = categories[indexPath.section]
        return headerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return modern.count
        }
        if section == 1 {
            return abstract.count
        } else {
            return realism.count
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCell", for: indexPath) as? NewCell {
            var art: Art!
            if indexPath.section == 0 {
                art = modern[indexPath.row]
            }
            
            if indexPath.section == 1 {
                art = abstract[indexPath.row]
            }
            
            if indexPath.section == 2 {
                art = realism[indexPath.row]
            }
            cell.otherScene.boxnode.removeFromParentNode()
            cell.configureCell(forArt: art, indexPath: indexPath)
            return cell
        } else {
            return NewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var art: Art!
        if indexPath.section == 0 {
            art = modern[indexPath.row]
        }
        if indexPath.section == 1 {
            art = abstract[indexPath.row]
        }
        
        if indexPath.section == 2 {
            art = realism[indexPath.row]
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? NewCell {
            if let artImage = cell.artImgView.image {
                let artInfo = [artImage, art] as [Any]
                self.performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AllVC" {
            let vc = segue.destination as! AllVC
            if let type = sender as? String {
                vc.type = type
            }
        }
        
        if segue.identifier == "ArtRoomVC" {
            if let artRoomVC = segue.destination as? ArtRoomVC {
                artRoomVC.hidesBottomBarWhenPushed = true
                if let artInfo = sender as? [Any] {
                    artRoomVC.artInfo = artInfo
                }
            }
        }
        
        if segue.identifier == "GalleryVC" {
            let galleryVC = segue.destination as! GalleryVC
            galleryVC.hidesBottomBarWhenPushed = true
            if let user = sender as? Users {
                galleryVC.user = user
            }
        }
    }
}
