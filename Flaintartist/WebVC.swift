//
//  webVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class WebVC: UIViewController {


    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var bar: UINavigationBar!

        var url: URL!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            print("URL:\(url!)")
            if let url = URL(string: "\(url!)") {
                let request = URLRequest(url: url)
                webView.loadRequest(request)
            }
        }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

