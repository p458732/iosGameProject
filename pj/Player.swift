//
//  Player.swift
//  pj
//
//  Created by mac11 on 2021/5/7.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    //let Player: SKSpriteNode!
    let test = SKShapeNode(circleOfRadius: 8)
    let textureAtlas = SKTextureAtlas(named: "slime move_blob.atlas")
    var txtureFrames = [SKTexture]()
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "slime move_blob_00.png")
        super.init(texture:texture, color:SKColor.clear, size: texture.size())
        
        var tempName: String
        for i in 0 ... 5 {
            tempName = String(format: "slime move_blob_%.2d",i)
            print(tempName)
            let dbTexture = textureAtlas.textureNamed(tempName)
            txtureFrames.append(dbTexture)
        }
        
        test.strokeColor = SKColor.purple
        test.fillColor = SKColor.white
        test.alpha = 1
        test.name = "test"
        
        test.setScale(CGFloat(0.3))
        test.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        test.physicsBody?.categoryBitMask = 0x1 << 1
        test.physicsBody?.contactTestBitMask = 0x1 << 6
        // test.physicsBody?.collisionBitMask = 0x1 << 3
        test.physicsBody?.usesPreciseCollisionDetection = true
        test.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
        showAtlas()
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func showAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: txtureFrames, timePerFrame: 0.2)) )
    }
    func moveBy(vector: CGVector){
        let moveAction = SKAction.move(by: vector, duration: 0.02)
        self.test.run(moveAction)
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(test.position.x), y: Int(test.position.y))     }
}
