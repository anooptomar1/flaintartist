//
//  PageMenuVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class PageMenuVC: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, CAPSPageMenuDelegate {
    
    var pageMenu : CAPSPageMenu?
    var searchController = UISearchController()
    var doneBtn: UIBarButtonItem!
    var controller1: SearchVC!
    var controller2: SearchArtsVC!
    var name = NSNotification.Name("Micro")
    
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var controllerArray : [UIViewController] = []
        let controller2 = storyboard?.instantiateViewController(withIdentifier: "test") as! SearchArtsVC
        controller2.title = "Art"
        self.controller2 = controller2
        controllerArray.append(controller2)
        
        let controller1 = storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        controller1.title = "Artist"
        self.controller1 = controller1
        controllerArray.append(controller1)
        
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(UIColor.flatBlack()),
            .selectedMenuItemLabelColor(UIColor.flatBlack()),
            .bottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .menuHeight(30.0),
            .menuMargin(60.0),
            .menuItemWidth(120.0),
            .selectionIndicatorHeight(1.0),
            .bottomMenuHairlineColor(UIColor.flatWhite()),
            .centerMenuItems(true),
            .enableHorizontalBounce(false)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        pageMenu!.didMove(toParentViewController: self)
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = controller2
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.showsCancelButton = false
        self.searchController.searchBar.placeholder = "Explore"
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        //self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = false
        doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PageMenuVC.doneBtnTapped))
        self.navigationItem.rightBarButtonItem = doneBtn
    }
    
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        if index == 0 {
            self.searchController.searchResultsUpdater = self.controller2
            self.searchController.searchBar.text = ""
            self.searchController.searchBar.placeholder = "Explore by modern, abstract..."
        } else {
            self.searchController.searchResultsUpdater = self.controller1
            self.searchController.searchBar.text = ""
            self.searchController.searchBar.placeholder = "Explore Artist"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.instance.REF_ARTS.removeAllObservers()
        NotificationCenter.default.removeObserver(self)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = nil
        self.searchController.searchBar.showsCancelButton = true
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = doneBtn
        self.searchController.searchBar.showsCancelButton = false
    }
    
    // MARK: - View Methods
    
    func doneBtnTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}

