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
    let deathAtlas = SKTextureAtlas(named: "style 1_player death.atlas")
    var deathFrames = [SKTexture]()
    var hurtCounter = 0
    var hurtFrames = [SKTexture]()
    var playerPOS = CGPoint()
    var gun : Gun!
    var isDieing = false
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "Idle_idle_0.png")
        super.init(texture:texture, color:SKColor.clear, size: texture.size())
        
        var tempName: String
        for i in 0 ... 4 {
            tempName = String(format: "Idle_idle_%.1d",i)
           
            
            let dbTexture = textureAtlas.textureNamed(tempName)
            idleFrames.append(dbTexture)
        }
        for i in 0 ... 11 {
            tempName = String(format: "style 1_player death_%.2d",i)
           
            
            let dbTexture = deathAtlas.textureNamed(tempName)
            deathFrames.append(dbTexture)
        }
        for i in 0 ... 3 {
            tempName = String(format: "style 1_player death_%.2d",i)
           
            
            let dbTexture = deathAtlas.textureNamed(tempName)
            hurtFrames.append(dbTexture)
        }
        for i in (0 ... 3).reversed() {
            tempName = String(format: "style 1_player death_%.2d",i)
           
            
            let dbTexture = deathAtlas.textureNamed(tempName)
            hurtFrames.append(dbTexture)
        }
        self.alpha = 1
        self.name = "enemy"
        self.zPosition = 50
        self.setScale(CGFloat(0.6))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody?.categoryBitMask = enemyCollisionMask
        self.physicsBody?.contactTestBitMask = wallCollisionMask
        self.physicsBody?.collisionBitMask = wallCollisionMask | puddleCollisionMask
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
       
        
       showAtlas()
        let newGun = Gun()
        self.gun =  newGun
        self.gun.zPosition = 5
        self.zPosition = 0
        self.addChild(newGun)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func showAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.2)) )
       
        
    }
    func showDeathAtlas(){
        if isDieing {
            return
        }
        isDieing = true
        self.gun.removeFromParent()
        self.run(SKAction.animate(with: deathFrames, timePerFrame: 0.2), completion: {() in
            
                self.removeFromParent()
        })
    }
    func showHurtAtlas(){
        
        self.run(SKAction.animate(with: hurtFrames, timePerFrame: 0.2))
        hurtCounter += 1
        print(hurtCounter)
    }
    func moveBy(_ currentTime: TimeInterval){
          var tt = (Double.random(in: -0.5...0.5))
        self.run(SKAction.move(by: CGVector(dx:tt , dy: tt), duration: 0.5))
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(self.position.x), y: Int(self.position.y))     }
}

class Gun: SKSpriteNode{
       
    override init(texture:SKTexture?, color: SKColor, size:CGSize){
        let texture = SKTexture(imageNamed: "main gun_Gun_0.png")
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        self.zPosition = -1
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
}

class Bullet: SKSpriteNode {
    override init (texture: SKTexture?, color: SKColor, size:CGSize){
        let texture = SKTexture(imageNamed: "bullet_projectile_0.png")
         super.init(texture:texture, color: SKColor.clear, size: texture.size())
        self.name = "bullet"
        
        self.setScale(CGFloat(0.6))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 3)
        self.physicsBody?.categoryBitMask = bulletCollisionMask
        self.physicsBody?.contactTestBitMask = wallCollisionMask  | playerCollisionMask
        self.physicsBody?.collisionBitMask = playerCollisionMask
        self.physicsBody?.usesPreciseCollisionDetection = false
        self.physicsBody?.affectedByGravity = false
        
             
    }
    
    required init?(coder aDecoder: NSCoder) {
         fatalError("init has not been implemented")
        }
    
}
