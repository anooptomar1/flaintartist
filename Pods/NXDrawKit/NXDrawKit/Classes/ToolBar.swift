//
//  ToolBar.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/13/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit

open class ToolBar: UIView {
    
    @objc open weak var imageView: UIImageView?
    @objc open weak var undoButton: UIButton?
    @objc open weak var redoButton: UIButton?
    @objc open weak var saveButton: UIButton?
    @objc open weak var clearButton: UIButton?
    
    fileprivate weak var lineView: UIView?

    // MARK: - Public Methods
    public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initialize() {
        self.setupViews()
        self.setupLayout()
    }
    
    // MARK: - Private Methods
    fileprivate func setupViews() {
        self.backgroundColor = UIColor.white
        
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        self.imageView = imageView
        self.addSubview(imageView)
        
        let lineView = UIView()
        lineView.backgroundColor =  UIColor(red: 200/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1)
        self.addSubview(lineView)
        self.lineView = lineView
        self.lineView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        var button: UIButton = self.button("Clear")
        self.addSubview(button)
        self.clearButton = button
        
        button = self.button(iconName: "icon_undo")
        self.addSubview(button)
        self.undoButton = button
        
        button = self.button(iconName: "icon_redo")
        self.addSubview(button)
        self.redoButton = button
        
        button = self.button("Save")
        self.addSubview(button)
        self.saveButton = button
    }
    
    fileprivate func setupLayout() {
        
        self.imageView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.imageView?.clipsToBounds = true
        self.imageView?.layer.cornerRadius = (self.imageView?.frame.height)!/2
        
        let height: CGFloat = 0.5
        
        self.lineView?.frame = CGRect(x: 0, y: (self.lineView?.bounds.size.height)! - height, width: bounds.size.width, height: height)
        
        self.undoButton?.frame = CGRect(x: 15, y: 0, width: self.height * 0.5, height: self.height * 0.5)
        self.undoButton?.center = CGPoint(x: (self.undoButton?.center.x)!, y: self.height / 2.0)

        self.redoButton?.frame = CGRect(x: (self.undoButton?.frame)!.maxX + 20, y: 0, width: self.height * 0.5, height: self.height * 0.5)
        self.redoButton?.center = CGPoint(x: (self.redoButton?.center.x)!, y: self.height / 2.0)

        self.saveButton?.frame = CGRect(x: self.width - (self.width * 0.1) - 15, y: 0, width: self.width * 0.1, height: self.width * 0.1)
        self.saveButton?.center = CGPoint(x: (self.saveButton?.center.x)!, y: self.height / 2.0)

        self.clearButton?.frame = CGRect(x: (self.saveButton?.frame)!.minX - (self.width * 0.1) - 15, y: 0, width: self.width * 0.1, height: self.width * 0.1)
        self.clearButton?.center = CGPoint(x: (self.clearButton?.center.x)!, y: self.height / 2.0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    fileprivate func button(_ title: String? = nil, iconName: String? = nil) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        
        if title != nil {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15 * self.multiflierForDevice())
            button.setTitle(title, for: UIControlState())
            button.setTitleColor(UIColor.black, for: UIControlState())
            button.setTitleColor(UIColor.gray, for: .disabled)
        }

        if iconName != nil {
            let podBundle = Bundle(for: self.classForCoder)
            if let bundleURL = podBundle.url(forResource: "NXDrawKit", withExtension: "bundle") {
                if let bundle = Bundle(url: bundleURL) {
                    let image = UIImage(named: iconName!, in: bundle, compatibleWith: nil)
                    button.setImage(image, for: UIControlState())
                }
            }
        }
        
        button.isEnabled = false
        
        return button
    }
    
    fileprivate func multiflierForDevice() -> CGFloat {
        if UIScreen.main.bounds.size.width <= 320 {
            return 0.75
        } else if UIScreen.main.bounds.size.width > 375 {
            return 1.0
        } else {
            return 0.9
        }
    }
}
