//
//  PrivacyVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
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
