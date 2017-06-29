//
//  RegisterVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/9/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit

class RegisterVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        startTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logView.layer.masksToBounds = true
        //logView.roundCorner(corners: [.topLeft, .topRight], radius: logView.frame.width/2)
    }

    
    @IBAction func logInFbBtnTapped(_ sender: Any) {
        AuthService.instance.facebookSignIn(viewController: self) { (errMsg, data) in
            guard errMsg == nil else {
               // self.indicator.stopAnimating()
                return
            }
        }
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! CarouselCell
        cell.configureCell()
        return cell
    }
    
    func scrollToNextCell(){

        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height);
        
        //get current content Offset of the Collection view
        let contentOffset = collectionView.contentOffset;
        
        //scroll to next cell
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y:contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        
        
    }
    
    func startTimer() {
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(RegisterVC.scrollToNextCell), userInfo: nil, repeats: true);
    }
}
