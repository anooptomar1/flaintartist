//
//  NewsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseInstanceID
import FirebaseMessaging


class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, presentVCProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var posts = [Art]()
    var post: Art!
    
    var categories = ["Just For You", "Modern", "Abstract", "Realism"]
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    let headBttn:UIButton = UIButton(type: .system)
    var refreshControl: UIRefreshControl!
    
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRMessaging.messaging().subscribe(toTopic: "/topics/news")
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NewsVC.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.navigationController?.setToolbarHidden(true, animated: false)        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.flatSkyBlue()
        
    }
    
    
    func refresh(_ sender: AnyObject) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! HeaderView
        
        typeLbl.text = categories[section]
        print("TYPELBL:\(typeLbl.text)")
        
        if section == 0 {
            self.seeMoreBtn.isHidden = true
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        type = categories[section].capitalized
        return categories[section]
    }

    @IBAction func seeMoreBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "AllVC", sender: typeLbl.text!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 140.0
        }
        return 270.0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if  let cell0 = tableView.dequeueReusableCell(withIdentifier: "TrendingTabCell", for: indexPath) as? TrendingTabCell {
                cell0.delegate = self
                return cell0
            }
        } else if indexPath.section == 1 {
            if  let cell1 = tableView.dequeueReusableCell(withIdentifier: "ModernTabCell", for: indexPath) as? ModernTabCell {
                cell1.delegate = self
                return cell1
            }
            
        }  else if indexPath.section == 2 {
            if  let cell2 = tableView.dequeueReusableCell(withIdentifier: "AbstractTabCell", for: indexPath) as? AbstractTabCell {
                cell2.delegate = self
                return cell2
            }
        } else if indexPath.section == 3 {
            if  let cell3 = tableView.dequeueReusableCell(withIdentifier: "RealismTabCell", for: indexPath) as? RealismTabCell {
                cell3.delegate = self
                return cell3
            }
        }
        return UITableViewCell()
    }
    
    
    func performSeg(_ identifier: String, sender: Any) {
        performSegue(withIdentifier: identifier, sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AllVC" {
            let vc = segue.destination as! AllVC
            if let type = sender as? String {
                print("TYPE: \(type)")
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
    }
}
