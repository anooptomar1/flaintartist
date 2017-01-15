//
//  SearchNav.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class SearchNav: UINavigationController, presentVCProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func performSeg(_ identifier: String, sender: Any) {
        performSeg(identifier, sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryVC" {
            let vc = segue.destination as! GalleryVC
           if let user = sender as? Users {
                vc.user = user
            }
        }
    }
}
