//
//  GameScene.swift
//  pj
//
//  Created by mac11 on 2021/5/5.
//  Copyright © 2021 mac11. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics

class GameScene: SKScene, JDPaddleVectorDelegate , SKPhysicsContactDelegate,  SkillUIDelegate{
    var background: SKTileMapNode! //背景瓦片地图节点
    var paddle:JDGamePaddle!
    var skillUICircle: SkillUI!
    var skillUICircle2: SkillUI!
    var hpBar: SKProgressBar = SKProgressBar()
    var player :Player!
    var enemy : [Enemy?] = []
    var boss :[Boss?] = []
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    var tileMap: SKTileMapNode? = SKTileMapNode()
    var purpleTileMap: SKTileMapNode = SKTileMapNode()
    var lastTime : TimeInterval = 0;
    var status = 0
    func usePuddle() {
        let puddle = Puddle()
        puddle.position.x = player.getPOS().x
        puddle.position.y = player.getPOS().y
        addChild(puddle)
         if (self.hpBar.setProgress(0.1)){
             player.xScale = player.xScale - 0.01
             player.yScale = player.yScale - 0.01
             player.showHurtAtlas()
         }else{
             player.showDieAtlas()
         }
    }
    func useStar() {
        self.player.physicsBody?.categoryBitMask = starPlayerCollisionMask
        self.player.physicsBody?.contactTestBitMask = 0
        self.player.physicsBody?.collisionBitMask = wallCollisionMask | puddleCollisionMask
        player.showStarAtlas()
        player.run(SKAction.sequence([ SKAction.wait(forDuration: 3), SKAction.run {
        self.player.physicsBody?.categoryBitMask = playerCollisionMask
        self.player.physicsBody?.contactTestBitMask = bulletCollisionMask
        self.physicsBody?.collisionBitMask = wallCollisionMask | bulletCollisionMask | puddleCollisionMask
        self.player.showAtlas()

                                  }]))
        
    }
    func moveWithCamara(){
         self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0) ,duration: 0.06))
         self.hpBar.setPos(pos: CGPoint(x: player.getPOS().x - 55 , y: 40) )
         paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: -20) )
         skillUICircle.setPos(pos: CGPoint(x: player.getPOS().x + 50 , y: -30) )
         skillUICircle2.setPos(pos: CGPoint(x: player.getPOS().x + 73 , y: -15))
    }
    func moveWithCamara1(){
        self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 140) ,duration: 0.06))
         self.hpBar.setPos(pos: CGPoint(x: player.getPOS().x - 55 , y: 180) )
         paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: 120) )
         skillUICircle.setPos(pos: CGPoint(x: player.getPOS().x + 50 , y: 110) )
         skillUICircle2.setPos(pos: CGPoint(x: player.getPOS().x + 73 , y: 125))
    }
    func moveWithCamara2(){
        self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 150) ,duration: 0.06))
         self.hpBar.setPos(pos: CGPoint(x: player.getPOS().x - 55 , y: 190) )
         paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: 130) )
         skillUICircle.setPos(pos: CGPoint(x: player.getPOS().x + 50 , y: 120) )
         skillUICircle2.setPos(pos: CGPoint(x: player.getPOS().x + 73 , y: 135))
    }
    var vec : CGVector = CGVector()
    func getVector(vector: CGVector) {
        
        player.moveBy(vector: CGVector(dx: vector.dx / 2 , dy: vector.dy / 2) )
        if(vector.dx.isNaN || vector.dy.isNaN){
            let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 0), duration: 0)
            // self.camera!.run(moveAction)
        }else{
            let moveAction = SKAction.move(by: vector, duration: 0)
            // self.camera!.run(moveAction)
        }
        
        if status == 0{
             moveWithCamara()
        }else if status == 1{
             moveWithCamara1()
        }else if status == 2{
             moveWithCamara2()
        }
        
        vec = CGVector(dx: vector.dx / 2, dy: vector.dy / 2)
        
        for i in 0...enemy.count - 1{
               
                aim(enemy: enemy[i]! , point: player.getPOS())
               }
        for i in 0 ... boss.count - 1{
            bossAim(enemy: boss[i]!, point: player.getPOS())
        }
       
    }
    @objc func newBullet(){
        
        for i in 0...enemy.count - 1{
            if enemy[i]!.hurtCounter >= 3{
                continue
            }
            let point = player.getPOS()
           
           
            let deltaX = Float(point.x - enemy[i]!.getPOS().x)
            let deltaY = Float(point.y + 10 - enemy[i]!.getPOS().y)
            let normal = Double(sqrt(deltaX*deltaX+deltaY*deltaY))
           
            let bullet = Bullet()
            bullet.zPosition = 60
            
           
            let act = SKAction.sequence([SKAction.move(by: CGVector(dx: Double(deltaX) * 1000 / normal, dy: Double(deltaY) * 1000 / normal), duration: 10) ,SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            addChild(bullet)
            bullet.position.x = enemy[i]!.getPOS().x
            bullet.position.y = enemy[i]!.getPOS().y
            bullet.name = "bullet"
            let angle = CGFloat(atan2f(deltaX, deltaY))
            var newAngle = angle
             let pi = CGFloat(M_PI)
            if player.getPOS().x < enemy[i]!.getPOS().x{
               // bullet.xScale = -1
            }else{
               // bullet.xScale = 1
            }
            
            if angle / pi  * 180 < 0{
                       bullet.run(SKAction.rotate(toAngle: -(pi/2 - newAngle)   , duration: 0))
                      
                bullet.yScale = -1
                     
                      
                   }else{
                       bullet.run(SKAction.rotate(toAngle: pi/2 - newAngle   , duration: 0))
                  
                   }
            bullet.run(act)
           
            
        }
    }
    @objc func newBossBullet(){
        var flag = true
        for i in 0...boss.count - 1{
            if boss[i]!.hurtCounter < 3{
                        flag = false
            }
        }
        if flag == true {
            self.view?.presentScene(GameScene(fileNamed: "WinScene"))
        }
        for i in 0...boss.count - 1{
            if boss[i]!.hurtCounter >= 3{
                continue
            }
            let point = player.getPOS()
           
           
            let deltaX = Float(point.x - boss[i]!.getPOS().x)
            let deltaY = Float(point.y  - boss[i]!.getPOS().y)
            let normal = Double(sqrt(deltaX*deltaX+deltaY*deltaY))
           
            let bullet = BossBullet()
            bullet.zPosition = 60
            
           
            let act = SKAction.sequence([SKAction.move(by: CGVector(dx: Double(deltaX) * 1000 / normal, dy: Double(deltaY) * 1000 / normal), duration: 10) ,SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            addChild(bullet)
            bullet.position.x = boss[i]!.getPOS().x
            bullet.position.y = boss[i]!.getPOS().y
            bullet.name = "bossBullet"
            let angle = CGFloat(atan2f(deltaX, deltaY))
            var newAngle = angle
             let pi = CGFloat(M_PI)
            if player.getPOS().x < boss[i]!.getPOS().x{
               // bullet.xScale = -1
            }else{
               // bullet.xScale = 1
            }
            
            if angle / pi  * 180 < 0{
                       bullet.run(SKAction.rotate(toAngle: -(pi/2 - newAngle)   , duration: 0))
                      
                bullet.yScale = -1
                     
                      
                   }else{
                       bullet.run(SKAction.rotate(toAngle: pi/2 - newAngle   , duration: 0))
                  
                   }
            bullet.run(act)
           
            
        }
    }
    func keepMove(){
        player.moveBy(vector: CGVector(dx: vec.dx , dy: vec.dy))
        if(vec.dx.isNaN || vec.dy.isNaN){
            let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 0), duration: 0)
            // self.camera!.run(moveAction)
        }else{
            let moveAction = SKAction.move(by: vec, duration: 0)
            // self.camera!.run(moveAction)
        }
        
        if status == 0{
             moveWithCamara()
        }else if status == 1{
             moveWithCamara1()
        }else if status == 2{
             moveWithCamara2()
        }
      for i in 0...enemy.count - 1{
     
       aim(enemy: enemy[i]! , point: player.getPOS())
      }
        for i in 0 ... boss.count - 1{
                   bossAim(enemy: boss[i]!, point: player.getPOS())
               }
    }
    func followPlayer(_ currentTime: TimeInterval){
        for i in 0...enemy.count - 1{
            
            if enemy[i]!.position.x < player.getPOS().x{
                
                enemy[i]?.xScale = 1
                
            }else{
                enemy[i]?.xScale = -1
              
            }
            
            
            
            enemy[i]?.moveBy(currentTime)
        }
        for i in 0...boss.count - 1{
            if boss[i]!.position.x < player.getPOS().x{
                boss[i]?.xScale = -1
               
                
            }else{
                boss[i]?.xScale = 1
           
              
            }
            
            
        }
    }
    override func update(_ currentTime: TimeInterval) {
        
        keepMove()
        followPlayer(currentTime)
        
        
    }
    func aim(enemy:Enemy, point: CGPoint)  {
        let node = enemy.gun!
        let deltaX = Float(point.x - enemy.position.x)
        let deltaY = Float(point.y - enemy.position.y)
        let pi = CGFloat(M_PI)
        let angle = CGFloat(atan2f(deltaX, deltaY))
        var newAngle = angle
       
        
       
        
     //   newBullet.run(SKAction.sequence( [ SKAction.move(by: CGVector(dx: Double(deltaX * 10), dy: Double(deltaY * 10)), duration: 1), SKAction.wait(forDuration: 0.2), SKAction.removeFromParent() ] ))
        if angle / pi  * 180 < 0{
            node.run(SKAction.rotate(toAngle: -(pi/2 - newAngle)   , duration: 0))
            node.run(SKAction.scaleY(to: -1, duration: 0))
            node.run(SKAction.scaleY(to: -1, duration: 0))
            node.xScale = -1
          
           
        }else{
            node.run(SKAction.rotate(toAngle: pi/2 - newAngle   , duration: 0))
            node.run(SKAction.scaleY(to: 1, duration: 0))
            node.run(SKAction.scaleX(to: 1, duration: 0))
        }
        
    }
    func bossAim(enemy:Boss, point: CGPoint)  {
        let node = enemy.gun!
        let deltaX = Float(point.x - enemy.position.x)
        let deltaY = Float(point.y - enemy.position.y)
        let pi = CGFloat(M_PI)
        let angle = CGFloat(atan2f(deltaX, deltaY))
        var newAngle = angle
       
        
       
        
     //   newBullet.run(SKAction.sequence( [ SKAction.move(by: CGVector(dx: Double(deltaX * 10), dy: Double(deltaY * 10)), duration: 1), SKAction.wait(forDuration: 0.2), SKAction.removeFromParent() ] ))
        if angle / pi  * 180 < 0{
            node.run(SKAction.rotate(toAngle: (pi/2 - newAngle)   , duration: 0))
         node.run(SKAction.scaleY(to: -1, duration: 0))
                    node.run(SKAction.scaleX(to: 1, duration: 0))
                    
           // node.xScale = -1
          
           
        }else{
            node.run(SKAction.rotate(toAngle: -(pi/2 - newAngle )  , duration: 0))
            node.run(SKAction.scaleY(to: 1, duration: 0))
            node.run(SKAction.scaleX(to: -1, duration: 0))
             
            
        }
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
       // print("A name: " )
        //print(contact.bodyA.node?.name)
        //print("B name: " )
        //print(contact.bodyB.node?.name)
        if contact.bodyA.node?.name == "ships"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else if contact.bodyB.node?.name == "ships" {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if contact.bodyA.node?.name == "bossBullet" && contact.bodyB.node?.name == "player"{
            contact.bodyA.node?.removeFromParent()
            let tempBoss = Boss()
            tempBoss.position.x = player.getPOS().x + 20
            tempBoss.position.y = player.getPOS().y - 10
            
            if (self.hpBar.setProgress(0.2)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
            }else{
                player.physicsBody = SKPhysicsBody()
                player.physicsBody?.affectedByGravity = false
               player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                      self.view?.presentScene(GameScene(fileNamed: "EndScene"))
                }    ] ))
            }
          addChild(tempBoss)
          boss.append(tempBoss)
        } else if contact.bodyB.node?.name == "bossBullet" && contact.bodyA.node?.name == "player"{
            let tempBoss = Boss()
            tempBoss.position.x = player.getPOS().x + 20
            tempBoss.position.y = player.getPOS().y - 10
            
            if (self.hpBar.setProgress(0.2)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
            }else{
                 player.physicsBody = SKPhysicsBody()
                 player.physicsBody?.affectedByGravity = false
               player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                      self.view?.presentScene(GameScene(fileNamed: "EndScene"))
                }    ] ))
            }
            addChild(tempBoss)
             boss.append(tempBoss)
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "boss" && contact.bodyB.node?.name == "wall"{
             let boss = contact.bodyA.node! as! Boss
             boss.dir = boss.dir * -1
            boss.removeAction(forKey: "move")

           //  boss.removeAllActions()
             boss.run(SKAction.move(by: CGVector(dx: 500 * boss.dir, dy: 0), duration: 10), withKey: "movee")
             boss.showAtlas()
            
             
           
        } else if contact.bodyB.node?.name == "boss" && contact.bodyA.node?.name == "wall"{
            let boss = contact.bodyB.node! as! Boss
             boss.dir = boss.dir * -1
             boss.removeAction(forKey: "move")
            // boss.removeAllActions()
             boss.run(SKAction.move(by: CGVector(dx: 500 * boss.dir, dy: 0), duration: 10),withKey: "movee")
             boss.showUpsideDoewnAtlas()
            
           
           
                   
        }
        if contact.bodyA.node?.name == "bossBullet" && contact.bodyB.node?.name == "wall"{
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "bossBullet" && contact.bodyA.node?.name == "wall"{
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "bullet" && contact.bodyB.node?.name == "wall"{
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "bullet" && contact.bodyA.node?.name == "wall"{
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode1" && contact.bodyB.node?.name == "player"{
            player.run(SKAction.move(to: CGPoint(x: -20, y: 140), duration: 0))
            status = 1
            moveWithCamara1()
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "tpNode1" && contact.bodyA.node?.name == "player"{
            player.run(SKAction.move(to: CGPoint(x: -20, y: 140), duration: 0))
            status = 1
            moveWithCamara1()
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode2" && contact.bodyB.node?.name == "player"{
            player.run(SKAction.move(to: CGPoint(x: 250, y: 150), duration: 0))
            status = 2
            moveWithCamara1()
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "tpNode2" && contact.bodyA.node?.name == "player"{
            player.run(SKAction.move(to: CGPoint(x: 250, y: 150), duration: 0))
            status = 2
            moveWithCamara1()
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode3" && contact.bodyB.node?.name == "player"{
                  self.view?.presentScene(GameScene(fileNamed: "EndScene"))
               } else if contact.bodyB.node?.name == "tpNode3" && contact.bodyA.node?.name == "player"{
                  self.view?.presentScene(GameScene(fileNamed: "EndScene"))
               }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "enemy"{
            let enemy = contact.bodyB.node! as! Enemy
            enemy.showHurtAtlas()
            if enemy.hurtCounter >= 3 {
                enemy.showDeathAtlas()
                
            }
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "enemy"{
            let enemy = contact.bodyA.node! as! Enemy
            enemy.showHurtAtlas()
            if enemy.hurtCounter >= 3 {
                enemy.showDeathAtlas()
                
            }
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "boss"{
            let enemy = contact.bodyB.node! as! Boss
            enemy.showHurtAtlas()
            if enemy.hurtCounter >= 3 {
                enemy.showDeathAtlas()
                
            }
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "boss"{
            let enemy = contact.bodyA.node! as! Boss
            enemy.showHurtAtlas()
            if enemy.hurtCounter >= 3 {
                enemy.showDeathAtlas()
                
            }
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "player"{
            let puddle = contact.bodyA.node! as! Puddle
            if puddle.counter >= 1{
                player.xScale = player.xScale + 0.005
                player.yScale = player.yScale + 0.005
                contact.bodyA.node?.removeFromParent()
                self.hpBar.setProgress(-0.05)
            }else{
                puddle.counter += 1
            }
           
           
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "player"{
             let puddle = contact.bodyB.node! as! Puddle
             if puddle.counter >= 1{
                           player.xScale = player.xScale + 0.005
                           player.yScale = player.yScale + 0.005
                           contact.bodyB.node?.removeFromParent()
                           self.hpBar.setProgress(-0.05)
                       }else{
                           puddle.counter += 1
                       }
        }
        if contact.bodyA.node?.name == "bullet" && contact.bodyB.node?.name == "player"{
            contact.bodyA.node?.removeFromParent()
            
            
            if (self.hpBar.setProgress(0.1)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
            }else{
               player.physicsBody = SKPhysicsBody()
                player.physicsBody?.affectedByGravity = false
                player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                                 self.view?.presentScene(GameScene(fileNamed: "EndScene"))
                           }    ] ))
                
            }
            
        } else if contact.bodyB.node?.name == "bullet" && contact.bodyA.node?.name == "player"{
            contact.bodyB.node?.removeFromParent()
             
           if (self.hpBar.setProgress(0.1)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
            }
            else{
               player.physicsBody = SKPhysicsBody()
            player.physicsBody?.affectedByGravity = false
            player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                  self.view?.presentScene(GameScene(fileNamed: "EndScene"))
            }    ] ))
              
            }
      
        }
        if (firstBody.node?.name == "ships" && secondBody.node?.name == "rocks"){
            
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        createScene()
        for node in self.children{
            if let test = node.name{
                if test == "wall"{
                    
                    
                    self.tileMap = node as! SKTileMapNode
                    
                    guard let tileMap = self.tileMap else { fatalError("Missing tile map for the level") }
                    print("WAIT")
                    let tileSize = tileMap.tileSize
                    let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
                    let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
                    
                    for col in 0..<tileMap.numberOfColumns {
                        for row in 0..<tileMap.numberOfRows {
                            let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                            let isEdgeTile = tileDefinition?.userData?["isEdge"] as? Bool
                            
                            if (tileDefinition != nil ) {
                                let x = CGFloat(col) * tileSize.width - halfWidth
                                let y = CGFloat(row) * tileSize.height - halfHeight
                                let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                                let tileNode = SKShapeNode(rect: rect)
                                tileNode.position = CGPoint(x: x, y: y)
                                tileNode.name = "wall"
                                tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                                tileNode.physicsBody?.categoryBitMask = wallCollisionMask
                                tileNode.physicsBody?.contactTestBitMask = bulletCollisionMask
                                tileNode.physicsBody?.collisionBitMask = bulletCollisionMask | playerCollisionMask | enemyCollisionMask | starPlayerCollisionMask
                                tileNode.physicsBody?.isDynamic = false
                                tileNode.physicsBody?.usesPreciseCollisionDetection = true
                                tileNode.alpha = 0
                                tileNode.physicsBody?.affectedByGravity = false
                                
                                // print(tileNode.physicsBody)
                                tileMap.addChild(tileNode)
                            }
                        }
                    }
                }
            }
            
            
        }
        
    }
    func createScene() {
        paddle = JDGamePaddle(forScene: self, size:CGSize(width: 30, height: 30), position: CGPoint(x: 8, y: 8))
        paddle.delegate = self
         let texture = SKTexture(imageNamed: "lab anims_green puddle_00.png")
        skillUICircle = SkillUI(texture:  texture, size: CGSize(width: 30, height: 30))
        skillUICircle2 = SkillUI(texture:   SKTexture(imageNamed: "slime skill_blob_01.png"),size: CGSize(width: 30, height: 30))
        skillUICircle.delegate = self
        skillUICircle2.delegate = self
        player = Player()
        let tempboss = Boss()
        tempboss.position.x = 250
        tempboss.position.y = 150
        addChild(tempboss)
        boss.append(tempboss)
        let tpNode = TeleportNode()
        tpNode.position.x = -20
        tpNode.position.y = 30
        tpNode.name = "tpNode1"
        addChild(tpNode)
        let tpNode1 = TeleportNode()
        tpNode1.position.x = 210
        tpNode1.position.y = 25
        tpNode1.name = "tpNode2"
        addChild(tpNode1)
        let tpNode2 = TeleportNode()
        tpNode2.position.x = 100
        tpNode2.position.y = 25
        tpNode2.name = "tpNode3"
        addChild(tpNode2)
        for i in 0...3 {
            let temp = Enemy()
            temp.position = CGPoint(x: 100*i, y: 5*i)
            enemy.append(temp)
            addChild(temp)
        }
        cameraNode = SKCameraNode()
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y:0)
        cameraNode.name = "camara"
        addChild(player)
        
        addChild(cameraNode)
        camera = cameraNode
        let zoomInAction = SKAction.scale(to: 0.27, duration: 0)
        let moveAction = SKAction.move(by: CGVector(dx: 20, dy:60), duration: 2)
       
        cameraNode.run(zoomInAction)
        // cameraNode.run(moveAction)
        paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 60 , y: player.getPOS().y - 20) )
        player.moveBy(vector: playerVector)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(newBullet), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(newBossBullet), userInfo: nil, repeats: true)
        self.hpBar = SKProgressBar.init(baseColor: SKColor(displayP3Red: CGFloat(219.0 / 255.0), green: CGFloat(211.0 / 255.0), blue: CGFloat(193.0 / 255.0 ), alpha: 1), coverColor: SKColor(displayP3Red: CGFloat(64.0 / 255.0), green: CGFloat(213.0 / 255.0), blue: CGFloat(89.0 / 255.0 ), alpha: 1), size: CGSize(width:80,height:5))
      
        
        self.addChild(hpBar)
        self.addChild(skillUICircle)
        skillUICircle.name = "puddle"
        skillUICircle2.name = "star"
        self.addChild(skillUICircle2)
        createScene1()
      
        self.hpBar.position.x = 50
    }
    func createScene1() {
         
           for i in 0...9 {
               let temp = Enemy()
               temp.position = CGPoint(x: -60 + 10 * i, y: 150  + i)
               enemy.append(temp)
               addChild(temp)
           }
          
       }
    
        
    
   
    
}

class SKProgressBar: SKNode {
    var baseSprite: SKSpriteNode!
    var coverSprite: SKSpriteNode!
    var labelNode : SKLabelNode!
    var value : CGFloat = 1.0
    override init() {
        super.init()
    }
    convenience init(baseColor: SKColor, coverColor: SKColor, size: CGSize ) {
        self.init()
        self.baseSprite = SKSpriteNode(color: baseColor, size: size)
        self.coverSprite = SKSpriteNode(color: coverColor, size: size)
        self.labelNode  = SKLabelNode(text: "100%")
        self.labelNode.fontSize = 6.5
        self.labelNode.fontName = "HelveticaNeue-Bold"
        self.labelNode.position.y = -3.5
        self.addChild(baseSprite)
        self.addChild(coverSprite)
        self.addChild(labelNode)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setProgress(_ value:CGFloat) -> Bool {
        
        print("Set progress bar to: \(value)")
        var newValue = self.value - value
        print(newValue)
        guard 0.0 ... 1.0 ~= newValue else {
            self.coverSprite.size = CGSize(width: 0, height: 0)
            self.labelNode.text = "0%"
            return false}
        self.value = newValue
        self.labelNode.text = "\(Int(self.value * 100))%"
        let originalSize = self.baseSprite.size
        var calculateFraction:CGFloat = 0.0
        self.coverSprite.position = self.baseSprite.position
        if newValue == 0.0 {
            calculateFraction = originalSize.width
        } else if 0.01..<1.0 ~= newValue {
            calculateFraction = originalSize.width - (originalSize.width * newValue)
        }
        self.coverSprite.size = CGSize(width: originalSize.width-calculateFraction, height: originalSize.height)
        if newValue>0.0 && newValue<1.0 {
            self.coverSprite.position = CGPoint(x:(self.coverSprite.position.x-calculateFraction)/2,y:self.coverSprite.position.y)
        }
        if newValue < 0.05{
            return false
        }
        return true
    }
    func setPos(pos:CGPoint){
        self.run(SKAction.move(to: pos, duration: 0.06))
    }
}


class TeleportNode: SKSpriteNode {
    
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "slime move_blob_00.png")
        super.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.alpha = 1
       
        
        self.setScale(CGFloat(0.6))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        self.physicsBody?.categoryBitMask = teleportCollisionMask
        self.physicsBody?.contactTestBitMask = playerCollisionMask
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        //test.physicsBody?.isDynamic = false
      
       
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
     }

