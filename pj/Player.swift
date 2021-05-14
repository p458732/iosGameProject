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
        
        test.setScale(CGFloat(0.3))
        test.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        test.physicsBody?.categoryBitMask = 0x1 << 1
        test.physicsBody?.contactTestBitMask = 0x1 << 6
        // test.physicsBody?.collisionBitMask = 0x1 << 3
        test.physicsBody?.usesPreciseCollisionDetection = true
        test.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
        scene.addChild(test)
    }
    func moveBy(vector: CGVector){
        let moveAction = SKAction.move(by: vector, duration: 0.02)
        self.test.run(moveAction)
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(test.position.x), y: Int(test.position.y))     }
}
