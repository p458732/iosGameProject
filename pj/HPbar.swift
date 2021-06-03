//
//  File.swift
//  pj
//
//  Created by mac12 on 2021/5/17.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation
import SpriteKit
class SKProgressBar: SKNode {
    var baseSprite: SKSpriteNode!
    var coverSprite: SKSpriteNode!
    override init() {
        super.init()
    }
    convenience init(baseColor: SKColor, coverColor: SKColor, size: CGSize ) {
        self.init()
        self.baseSprite = SKSpriteNode(color: baseColor, size: size)
        self.coverSprite = SKSpriteNode(color: coverColor, size: size)
        self.addChild(baseSprite)
        self.addChild(coverSprite)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setProgress(_ value:CGFloat) {
        print("Set progress bar to: \(value)")
        guard 0.0 ... 1.0 ~= value else { return }
        let originalSize = self.baseSprite.size
        var calculateFraction:CGFloat = 0.0
        self.coverSprite.position = self.baseSprite.position
        if value == 0.0 {
            calculateFraction = originalSize.width
        } else if 0.01..<1.0 ~= value {
            calculateFraction = originalSize.width - (originalSize.width * value)
        }
        self.coverSprite.size = CGSize(width: originalSize.width-calculateFraction, height: originalSize.height)
        if value>0.0 && value<1.0 {
            self.coverSprite.position = CGPoint(x:(self.coverSprite.position.x-calculateFraction)/2,y:self.coverSprite.position.y)
        }
    }
}
