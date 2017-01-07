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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        webView.loadRequest(NSURLRequest(url: NSURL(string: "//https://flaint.wordpress.com/2016/12/17/test/")! as URL) as URLRequest)

    }
}
=======
        
        webView.loadRequest(URLRequest(url: URL(string: "//https://flaint.wordpress.com/2016/12/17/test/")!))
    }
}


>>>>>>> 1301276c7e0b37c6c2a82d2462a3153209f53319
