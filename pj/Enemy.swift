//
//  File.swift
//  pj
//
//  Created by mac12 on 2021/5/17.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    //let Player: SKSpriteNode!
    
    let textureAtlas = SKTextureAtlas(named: "Idle.atlas")

    var idleFrames = [SKTexture]()
    var playerPOS = CGPoint()
    var gun : Gun!
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "Idle_idle_0.png")
        super.init(texture:texture, color:SKColor.clear, size: texture.size())
        
        var tempName: String
        for i in 0 ... 4 {
            tempName = String(format: "Idle_idle_%.1d",i)
            print(tempName)
            let dbTexture = textureAtlas.textureNamed(tempName)
            idleFrames.append(dbTexture)
        }
    
        self.alpha = 1
        self.name = "enemy"
        
        self.setScale(CGFloat(0.6))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody?.categoryBitMask = 0x1 << 1
        self.physicsBody?.contactTestBitMask = 0x1 << 6
        //self.physicsBody?.collisionBitMask = 0x1 << 3
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
        
       showAtlas()
        let newGun = Gun()
        self.gun =  newGun
        self.gun.zPosition = 5
        self.addChild(newGun)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func showAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.2)) )
       
        
    }
    func moveBy(_ currentTime: TimeInterval){
          var tt = (Double.random(in: -0.5...0.5))
        self.run(SKAction.move(by: CGVector(dx:tt , dy: tt), duration: 0.5))
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(self.position.x), y: Int(self.position.y))     }
}

class Gun: SKSpriteNode{
       
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
         let texture = SKTexture(imageNamed: "main gun_Gun_0.png")
         super.init(texture:texture, color:SKColor.clear, size: texture.size())
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
}
