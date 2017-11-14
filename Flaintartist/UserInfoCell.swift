//
//  UserInfoCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable

weak var tooolBar: ToolBar?


final class UserInfoCell: UICollectionViewCell, NibReusable {
    
    var user: User?
    
    var toolBar = ToolBar()

    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(markerActivated), name: markerIsActivated, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     @objc func settingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nav = storyBoard.instantiateViewController(withIdentifier: "SettingsNav") as! UINavigationController
        let vc = nav.topViewController as! SettingsVC
        vc.user = user
        self.viewController?.present(nav, animated: true, completion: nil)
    }
    
    @objc func markerActivated() {
        print("ACTIVATED")        
        toolBar.redoButton?.alpha = 1.0
        toolBar.undoButton?.alpha = 1.0
        toolBar.clearButton?.alpha = 1.0
        toolBar.saveButton?.alpha = 1.0
        //let top = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
        }, completion: nil)
    }

    @objc func done() {
        toolBar.undoButton?.alpha = 0.0
        toolBar.redoButton?.alpha = 0.0
        toolBar.clearButton?.alpha = 0.0
        toolBar.saveButton?.alpha = 0.0
        NotificationCenter.default.post(name: markerIsDesactivated, object: nil)
        //let bottom = CGAffineTransform(translationX: 0, y: -300)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
           // self.doneButton.transform = bottom
        }) { (true) in
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.addSublayer(separator)
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        setupToolBar()
        configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupToolBar() {
        toolBar.frame = self.contentView.bounds
        toolBar.undoButton?.setImage(#imageLiteral(resourceName: "Undo-24"), for: .normal)
        toolBar.redoButton?.setImage(#imageLiteral(resourceName: "Redo-24"), for: .normal)
        toolBar.imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsVC)))
        toolBar.undoButton?.addTarget(self, action: #selector(UserInfoCell.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(UserInfoCell.onClickRedoButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(UserInfoCell.done), for: .touchUpInside)
        toolBar.undoButton?.alpha = 0.0
        toolBar.redoButton?.alpha = 0.0
        toolBar.clearButton?.alpha = 0.0
        toolBar.saveButton?.alpha = 0.0
        // default title is "Save"
        toolBar.saveButton?.setTitle("Done", for: UIControlState())
        toolBar.saveButton?.isEnabled = true
        toolBar.clearButton?.addTarget(self, action: #selector(onClickClearButton), for: .touchUpInside)
        self.contentView.addSubview(toolBar)
        tooolBar = toolBar
    }

    
    @objc func onClickUndoButton() {
        canvassView?.undo()
    }
    
    @objc func onClickRedoButton() {
        canvassView?.redo()
    }
    
    @objc func onClickLoadButton() {
        //self.showActionSheetForPhotoSelection()
    }
    
    @objc func onClickSaveButton() {
        canvassView?.save()
    }
    
    @objc func onClickClearButton() {
        canvassView?.clear()
        toolBar.saveButton?.isEnabled = true
    }
    
    func configure() {
        if let user = user  {
            if user.profilePicUrl != nil {
                toolBar.imageView?.sd_setImage(with: URL(string: user.profilePicUrl!))
            }
        }
    }
}
