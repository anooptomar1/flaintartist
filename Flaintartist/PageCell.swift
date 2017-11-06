//
//  PageCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Reusable

final class PageCell: UICollectionViewCell, NibReusable {
    
    var look: QuickLook?
    
    let colorView: UIView = {
        let view = UIView()
        return view
    }()
    
     let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let label: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 4
        lab.textAlignment = .center
        lab.translatesAutoresizingMaskIntoConstraints = true
        lab.font = UIFont.systemFont(ofSize: 20)
        return lab
    }()
    
    private let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.addSublayer(separator)
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        colorView.frame = bounds
        label.frame = CGRect(x: contentView.center.x - bounds.width/4, y: 0, width: bounds.width/2, height: 60)
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    func configure(look: QuickLook) {
        self.look = look
        contentView.backgroundColor = look.color
        label.text = look.title
    }
}
