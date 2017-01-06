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
    var urlToLoad: URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(URLRequest(url: urlToLoad))
    }
}

//https://flaint.wordpress.com/2016/12/17/test/"
