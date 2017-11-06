//
//  ArtInfoCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-26.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

final class ArtInfoCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = .darkText
        view.font = .boldSystemFont(ofSize: 15)
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = UIColor.darkText
        view.font = .systemFont(ofSize: 15)
        self.contentView.addSubview(view)
        return view
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
    }
    
    var title: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    var desc: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        label.frame = CGRect(x: 20, y: 0, width: bounds.width, height: bounds.height - 20)
        descriptionLabel.frame = CGRect(x: 20, y: label.frame.height - 10, width: bounds.width, height: 20)
        
    }
}

