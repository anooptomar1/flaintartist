//
//  PrivacyVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/6/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class PrivacyVC: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://flaint.wordpress.com/2016/12/17/test/") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
}




