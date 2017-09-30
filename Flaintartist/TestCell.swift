//
//  TestCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-25.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable

final class InteractiveCell: UICollectionViewCell, Reusable {
    
    var likeButton: UIButton!
    var discussButton: UIButton!
    var shareButton: UIButton!
    var separator: CALayer!
    var title: String?
    var storyId: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        discussButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(discuss)))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupSubviews() {
        
        let buttonTitleColor = UIColor(red: 28/255.0, green: 30/255.0, blue: 28/255.0, alpha: 1.0)
        let titleFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        discussButton = UIButton.init()
        discussButton.setTitle("test", for: .normal)
        discussButton.setTitleColor(buttonTitleColor, for: .normal)
        discussButton.titleLabel?.font = titleFont
        discussButton.sizeToFit()
        contentView.addSubview(discussButton)
        
        //        discussButton = UIButton.init()
        //        discussButton.setTitle("Discuss", for: .normal)
        //        discussButton.setTitleColor(buttonTitleColor, for: .normal)
        //        discussButton.titleLabel?.font = titleFont
        //
        //        discussButton.sizeToFit()
        //        contentView.addSubview(discussButton)
        
        //        shareButton = UIButton.init()
        //        shareButton.setTitle("Share", for: .normal)
        //        shareButton.setTitleColor(buttonTitleColor, for: .normal)
        //        shareButton.titleLabel?.font = titleFont
        //        shareButton.sizeToFit()
        //        contentView.addSubview(shareButton)
        
        
        self.separator = CALayer.init()
        self.separator.backgroundColor = UIColor(red: 200/255.0, green: 199/255.0, blue: 204/255.0, alpha:1).cgColor
        self.contentView.layer.addSublayer(self.separator)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.contentView.bounds
        let leftPadding: CGFloat = 8.0
        
        self.discussButton.frame = CGRect(x: leftPadding, y: 0, width: self.discussButton.frame.width, height: bounds.size.height)
        //        self.discussButton.frame = CGRect(x: leftPadding + self.likeButton.frame.maxX , y: 0, width: self.discussButton.frame.width, height: bounds.size.height)
        //
        //        self.shareButton.frame = CGRect(x: leftPadding + self.discussButton.frame.maxX, y: 0, width: self.shareButton.frame.width, height: bounds.size.height)
        
        let height: CGFloat = 0.5
        
        self.separator.frame = CGRect(x: leftPadding, y: bounds.size.height - height, width: bounds.size.width - leftPadding, height: height)
    }
    
    @objc func discuss() {
//        let vc =  DiscussVC()
//        vc.title = self.title
//        vc.storyID = self.storyId
//        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func share() {
        
        let alert = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default) { (action) in
            
        }
        
        let email = UIAlertAction(title: "Email", style: .default) { (action) in
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(facebook)
        alert.addAction(email)
        alert.addAction(cancel)
        self.viewController?.present(alert, animated: true, completion: nil)
    }
    
    
}










