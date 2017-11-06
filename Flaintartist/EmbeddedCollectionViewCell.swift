//
//  EmbeddedCollectionViewCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-25.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import Reusable

final class EmbeddedCollectionViewCell: UICollectionViewCell, Reusable {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        self.contentView.addSubview(view)
        return view
    }()
        
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
    }
}

final class PageControlCell: UICollectionViewCell, IGListAdapterDelegate {
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        control.currentPageIndicatorTintColor = UIColor.lightGray
        control.pageIndicatorTintColor = UIColor.lightGrayColor
        control.numberOfPages = 3
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pageControl.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        pageControl.currentPage = index
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {}
}
