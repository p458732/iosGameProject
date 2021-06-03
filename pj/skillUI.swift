//
//  skillUI.swift
//  pj
//
//  Created by mac12 on 2021/5/26.
//  Copyright © 2021 mac11. All rights reserved.
//

import Foundation

import SpriteKit

protocol SkillUIDelegate {
    func usePuddle()
    func useStar()
}

class SkillUI:SKSpriteNode
{
   
    let skillUICircle: SKShapeNode?
    var touching:Bool =  false
    var delegate:SkillUIDelegate?
    var tex :SKTexture?
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
              
               let paddleSize:CGSize = CGSize(width: size.height * 0.7 , height: size.height * 0.7)
               
               skillUICircle = SKShapeNode(circleOfRadius: 10 ) // Create circle
               skillUICircle?.position = CGPoint(x: 0, y: 0)  // Center (given scene anchor point is 0.5 for x&y)
               skillUICircle?.strokeColor =  SKColor.init(cgColor: CGColor(srgbRed: CGFloat(188.0 / 255.0), green: CGFloat(230.0 / 255.0 ), blue: CGFloat(227.0 / 255.0), alpha: 1))
                      //circle.glowWidth = 1.0
               skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: CGFloat(100.0 / 255.0), green: CGFloat(224.0 / 255.0 ), blue: CGFloat(197.0 / 255.0), alpha: 0.5))
               skillUICircle?.name = "skill1"
               super.init(texture: texture, color: UIColor.clear, size: paddleSize)
               self.zPosition = 56
               self.isUserInteractionEnabled = true
               self.position = CGPoint(x: 0, y: size.height * 0.5 )
               self.tex = texture
               
             
               
               self.addChild(skillUICircle!)
        
    }

    func setPos(pos:CGPoint){
        self.run(SKAction.move(to: pos, duration: 0.06))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        touching = true
        let position = touch.location(in: self)
        if((skillUICircle!.contains(position)))
        {
            if self.name == "puddle" {
                
            
            skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5))
            delegate?.usePuddle()
            self.isUserInteractionEnabled = false
            skillUICircle?.run(SKAction.sequence([ SKAction.wait(forDuration: 2), SKAction.run {
                self.skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: CGFloat(100.0 / 255.0), green: CGFloat(224.0 / 255.0 ), blue: CGFloat(197.0 / 255.0), alpha: 0.5))
                self.isUserInteractionEnabled = true
            }]))
            }else if self.name == "star"{
                skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5))
                delegate?.useStar()
                self.isUserInteractionEnabled = false
                skillUICircle?.run(SKAction.sequence([ SKAction.wait(forDuration: 5), SKAction.run {
                self.skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: CGFloat(100.0 / 255.0), green: CGFloat(224.0 / 255.0 ), blue: CGFloat(197.0 / 255.0), alpha: 0.5))
                self.isUserInteractionEnabled = true
                           }]))
                
            }
          
            
        }
      
    }
    func changeColor()  {
        skillUICircle?.fillColor = SKColor.init(cgColor: CGColor(srgbRed: CGFloat(100.0 / 255.0), green: CGFloat(224.0 / 255.0 ), blue: CGFloat(197.0 / 255.0), alpha: 0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false
      
        
        if(delegate != nil)
        {
            let zero:CGVector = CGVector.zero
           
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Puddle: SKSpriteNode {
    //let Player: SKSpriteNode!
     let puddleAtlas = SKTextureAtlas(named: "puddle.atlas")
     var puddleFrames = [SKTexture]()
     var counter = 0
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "lab anims_green puddle_00.png")
        super.init(texture:texture, color:SKColor.clear, size: texture.size())
        
        var tempName: String
        for i in 0 ... 7 {
            tempName = String(format: "lab anims_green puddle_%.2d",i)
            print(tempName)
            let dbTexture = puddleAtlas.textureNamed(tempName)
            puddleFrames.append(dbTexture)
        }
       
        self.alpha = 1
        self.name = "puddle"
        self.zPosition = 0
        self.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        self.physicsBody?.categoryBitMask = puddleCollisionMask
        self.physicsBody?.contactTestBitMask = enemyCollisionMask | playerCollisionMask | starPlayerCollisionMask
        self.physicsBody?.collisionBitMask = wallCollisionMask
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
        showAtlas()
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func showAtlas(){
        self.run(SKAction.repeatForever(SKAction.animate(with: puddleFrames, timePerFrame: 0.2)) )
        
    }
    
    func moveBy(vector: CGVector){
        let moveAction = SKAction.move(by: vector, duration: 0.02)
        self.run(moveAction)
    }
    func getPOS()->CGPoint{
        return CGPoint(x: Int(self.position.x), y: Int(self.position.y))     }
}
