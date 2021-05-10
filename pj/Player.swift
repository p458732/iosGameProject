//
//  Player.swift
//  pj
//
//  Created by mac11 on 2021/5/7.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    //let Player: SKSpriteNode!
    let test = SKShapeNode(circleOfRadius: 8)
    init(forScene scene:SKScene){
        test.strokeColor = SKColor.purple
        test.fillColor = SKColor.white
        test.alpha = 1
        test.name = "test"
        test.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(test)
    }
    func moveBy(vector: CGVector){
        let moveAction = SKAction.move(by: vector, duration: 0.03)
        print (self.test.position)
        self.test.run(moveAction)
    }
    func getPOS()->CGPoint{
    return test.position
    }
}
