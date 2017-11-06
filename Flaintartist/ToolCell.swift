//
//  ToolCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-25.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable
import NXDrawKit

weak var palettteView: Palette?


final class ToolCell: UICollectionViewCell, NibReusable, PaletteDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    
    var arts = [Art]()
    lazy var artCell = ArtCell()
    weak var paletteView: Palette?

    
    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    let pageControl: FlexiblePageControl = {
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
    }

    
    @IBAction func addButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func markerButton(_ sender: UIButton) {
        print("MARKER")
        markerActivated()
    }
    
    @IBAction func rotateButton(_ sender: Any) {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //NotificationCenter.default.addObserver(self, selector: #selector(markerActivated), name: markerIsActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markerDesactived), name: markerIsDesactivated, object: nil)
    }
    
    fileprivate func setupPalette() {
        let paletteView = Palette()
        paletteView.backgroundColor = .white
        paletteView.delegate = self
        paletteView.setup()
        self.contentView.addSubview(paletteView)
        paletteView.isHidden = true
        palettteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: self.contentView.frame.height - paletteHeight, width: self.contentView.frame.width, height: paletteHeight)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(pageControl)
        contentView.layer.addSublayer(separator)
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        pageControl.frame = CGRect(x: self.contentView.center.x / bounds.width / 2 , y: bounds.height / 2, width: bounds.width, height: height)
        setupPalette()
    }



    @objc func markerActivated() {
        print("MARKER ACTIVED")
        NotificationCenter.default.post(name: markerIsActivated, object: nil)
        let top = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            self.markerButton.transform = top
            self.pageControl.transform = top
            self.pageControl.isHidden = true
            self.addButton.transform = top
            self.rotateButton.transform = top
            palettteView?.isHidden = false
         }, completion: nil)
    }
    
    
    
    @objc func markerDesactived() {
        let top = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
        self.markerButton.transform = top
        self.pageControl.transform = top
        self.pageControl.isHidden = false
        self.addButton.transform = top
        self.rotateButton.transform = top
        palettteView?.isHidden = true
        }, completion: nil)
    }
}
