//
//  OverlayScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-09.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SpriteKit


class OverlayScene: SKScene {

    var pauseNode: SKSpriteNode!
    var scoreNode: SKLabelNode!
    var pathToDraw: CGMutablePath?
    var lineNode: SKShapeNode?
    var lastTouch = CGPoint.zero
    

    var score = 0 {
        didSet {
            self.scoreNode.text = "Score: \(self.score)"
        }
    }

    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        
        let spriteSize = size.width/12
        self.pauseNode = SKSpriteNode(imageNamed: "Pause Button")
        self.pauseNode.size = CGSize(width: spriteSize, height: spriteSize)
        self.pauseNode.position = CGPoint(x: spriteSize + 8, y: spriteSize + 8)
        
        self.scoreNode = SKLabelNode(text: "Score: 0")
        self.scoreNode.fontName = "DINAlternate-Bold"
        self.scoreNode.fontColor = UIColor.black
        self.scoreNode.fontSize = 24
        self.scoreNode.position = CGPoint(x: size.width/2, y: self.pauseNode.position.y - 9)
        
//        self.addChild(self.pauseNode)
//        self.addChild(self.scoreNode)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}
