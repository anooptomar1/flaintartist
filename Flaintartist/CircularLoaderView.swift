//
//  CircularLoaderView.swift
//  Flaintartist
//
//  Created by Kerby Jean on 5/23/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation


class CircularLoaderView: UIView {
    


let circlePathLayer = CAShapeLayer()
let circleRadius: CGFloat = 12.0

  override init(frame: CGRect) {
      super.init(frame: frame)
      configure()
  }

  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      configure()
  }

  func configure() {
      circlePathLayer.frame = bounds
      circlePathLayer.lineWidth = 1.3
      circlePathLayer.fillColor = UIColor.clear.cgColor
      circlePathLayer.strokeColor = UIColor.flatSkyBlueColorDark().cgColor
      layer.addSublayer(circlePathLayer)
      backgroundColor = UIColor.white
      progress = 0
  }
    
  func circleFrame() -> CGRect {
       var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
       circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
       circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
       return circleFrame
    }
    
  func circlePath() -> UIBezierPath {
       return UIBezierPath(ovalIn: circleFrame())
    }
    
   override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    func reveal() {
        
        // 1
        //backgroundColor = UIColor.clear
        progress = 1
        // 2
        circlePathLayer.removeAnimation(forKey: "strokeEnd")
        // 3
        circlePathLayer.removeFromSuperlayer()
        superview?.layer.mask = circlePathLayer
    }
}












