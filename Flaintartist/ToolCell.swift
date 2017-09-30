//
//  ToolCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-25.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable

final class ToolCell: UICollectionViewCell, NibReusable {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    
    
    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    private let pageControl: FlexiblePageControl = {
        let control = FlexiblePageControl()
        control.isUserInteractionEnabled = true
        control.dotSize = 6
        control.dotSpace = 5
        control.hidesForSinglePage = true
        control.displayCount = 5
        control.numberOfPages = 5
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = UIColor.gray
        control.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        control.updateViewSize()
        return control
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(red: 250, green: 250, blue: 250, alpha: 1)
        //FAFAFA
    }
    
    @IBAction func addButton(_ sender: Any) {
        print("ADD ART")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func rotateButton(_ sender: Any) {

    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(pageControl)
        contentView.layer.addSublayer(separator)
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        pageControl.frame = CGRect(x: self.center.x / bounds.width / 2 , y: bounds.height / 2, width: bounds.width, height: height)
    }

}
