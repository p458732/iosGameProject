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
    let dieAtlas = SKTextureAtlas(named: "death_blob death.atlas")
    let textureAtlas = SKTextureAtlas(named: "slime move_blob.atlas")
    let hurtAtlas =  SKTextureAtlas(named: "death_blob death.atlas")
    let starAtlas = SKTextureAtlas(named: "slime skill_blob.atlas")
    var txtureFrames = [SKTexture]()
    var starFrames = [SKTexture]()
    var dieTxtureFrames = [SKTexture]()
    var hurtTxtureFrames = [SKTexture]()
    var isYellow = false
    var isDieing = false 
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
        for i in 0 ... 12 {
            tempName = String(format: "death_blob death_%.2d",i)
            print(tempName)
            let dbTexture = dieAtlas.textureNamed(tempName)
            dieTxtureFrames.append(dbTexture)
        }
        for i in 0 ... 5 {
            tempName = String(format: "death_blob death_%.2d",i)
            print(tempName)
            let dbTexture = hurtAtlas.textureNamed(tempName)
            hurtTxtureFrames.append(dbTexture)
        }
        for i in (0 ... 5).reversed()  {
            tempName = String(format: "death_blob death_%.2d",i)
            print(tempName)
            let dbTexture = hurtAtlas.textureNamed(tempName)
            hurtTxtureFrames.append(dbTexture)
        }
        
        for i in 0 ... 5{
            tempName = String(format: "slime skill_blob_%.2d",i)
            print(tempName)
            let dbTexture = starAtlas.textureNamed(tempName)
            starFrames.append(dbTexture)
        }
        self.alpha = 1
        self.name = "player"
        
        self.setScale(CGFloat(0.6))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        self.physicsBody?.categoryBitMask = playerCollisionMask
        self.physicsBody?.contactTestBitMask = bulletCollisionMask
        self.physicsBody?.collisionBitMask = wallCollisionMask | bulletCollisionMask | puddleCollisionMask
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
        showAtlas()
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func showAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: txtureFrames, timePerFrame: 0.2)) )
    }
    func showDieAtlas(){
        
        self.run(SKAction.animate(with: dieTxtureFrames , timePerFrame: 0.2) )
    }
    func showHurtAtlas(){
        self.run(SKAction.animate(with: hurtTxtureFrames , timePerFrame: 0.1) )
    }
    func showStarAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: starFrames, timePerFrame: 0.2)) )
        
    }
    func moveBy(vector: CGVector){
        let moveAction = SKAction.move(by: vector, duration: 0.02)
        self.run(moveAction)
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(self.position.x), y: Int(self.position.y))     }
}
