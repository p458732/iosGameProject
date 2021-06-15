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
    let InGameBackgroundSound = SKAudioNode(fileNamed: "ingame.mp3")
    let InBossGameBackgroundSound = SKAudioNode(fileNamed: "ingame2.mp3")
    let slimeGetHurtSound = SKAudioNode(fileNamed: "slime_getHurt.mp3")
    let superStarSound = SKAudioNode(fileNamed: "superstar.mp3")
    let gunShotSound = SKAudioNode(fileNamed: "gunshot.mp3")
    let dieSound = SKAudioNode(fileNamed: "died.mp3")
    let humanGetHurtSound = SKAudioNode(fileNamed: "human_getHurt.mp3")
    let humanDiedSound = SKAudioNode(fileNamed: "human_died.mp3")
    let starBackgroundSound = SKAudioNode(fileNamed: "superstar.mp3")
    var paddle:JDGamePaddle!
    var skillUICircle: SkillUI!
    var skillUICircle2: SkillUI!
    var hpBar: HpBarNode = HpBarNode()
    var player :Player!
    var enemy : [Enemy?] = []
    var boss :[Boss?] = []
    var tpNodes :[TeleportNode?] = []
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    var tileMap: SKTileMapNode? = SKTileMapNode()
    var purpleTileMap: SKTileMapNode = SKTileMapNode()
    var lastTime : TimeInterval = 0;
    var status = 0
    var bossDied = false
    var inBossRoom = false
    func usePuddle() {
        let puddle = Puddle()
        puddle.position.x = player.getPOS().x
        puddle.position.y = player.getPOS().y
        addChild(puddle)
        if (self.hpBar.setProgress(1)){
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
        self.starBackgroundSound.run(SKAction.play())
        player.showStarAtlas()
        player.run(SKAction.sequence([ SKAction.wait(forDuration: 3), SKAction.run {
            self.starBackgroundSound.run(SKAction.stop())
            self.player.physicsBody?.categoryBitMask = playerCollisionMask
            self.player.physicsBody?.contactTestBitMask = bulletCollisionMask
            self.physicsBody?.collisionBitMask = wallCollisionMask | bulletCollisionMask | puddleCollisionMask
            self.player.showAtlas()
            
        }]))
        
    }
    func moveWithCamara(){
        if(player.getPOS().x > -85 && player.getPOS().x < 470 ){
            self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0) ,duration: 0.06))
       
        self.hpBar.setPos(pos: CGPoint(x: player.getPOS().x - 55 , y: 40) )
        paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: -20) )
        skillUICircle.setPos(pos: CGPoint(x: player.getPOS().x + 50 , y: -30) )
        skillUICircle2.setPos(pos: CGPoint(x: player.getPOS().x + 73 , y: -15))
        }
    }
    func moveWithCamara1(){
        
        self.camera?.run(SKAction.move(to: CGPoint(x: -20, y: 160) ,duration: 0.06))
        self.hpBar.setPos(pos: CGPoint(x: -20 - 55 , y: 200) )
        paddle.paddle.setPos(pos: CGPoint(x: -20 - 80 , y: 140) )
        skillUICircle.setPos(pos: CGPoint(x: -20 + 50 , y: 130) )
        skillUICircle2.setPos(pos: CGPoint(x: -20 + 73 , y: 145))
        let zoomInAction = SKAction.scale(to: 0.27, duration: 0)
       
        
        cameraNode.run(zoomInAction)
        
    }
    func moveWithCamara2(){
        if(player.getPOS().x > 318 && player.getPOS().x < 495 ){

        self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 150) ,duration: 0.06))
        self.hpBar.setPos(pos: CGPoint(x: player.getPOS().x - 55 , y: 190) )
        paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: 130) )
        skillUICircle.setPos(pos: CGPoint(x: player.getPOS().x + 50 , y: 120) )
        skillUICircle2.setPos(pos: CGPoint(x: player.getPOS().x + 73 , y: 135))
            
        }
    }
    var vec : CGVector = CGVector()
    func getVector(vector: CGVector) {
        if player.isDieing {
            return
        }
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
        if !inBossRoom{
            gunShotSound.run(SKAction.play())
        }
        for i in 0...enemy.count - 1{
            if enemy[i]!.hurtCounter >= 3{
                continue
            }
            let point = player.getPOS()
            
            
            let deltaX = Float(point.x - enemy[i]!.getPOS().x)
            let deltaY = Float(point.y - enemy[i]!.getPOS().y)
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
        if inBossRoom && !self.bossDied{
            gunShotSound.run(SKAction.play())
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
        if player.isDieing {
            return
        }
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
            var flag = true
            for i in 0...boss.count - 1{
                if boss[i]!.hurtCounter < 3{
                    flag = false
                }
            }
            if flag == true {
                return
            }
            contact.bodyA.node?.removeFromParent()
            let tempBoss = Boss()
            
            tempBoss.position.x = player.getPOS().x + 20
            tempBoss.position.y = player.getPOS().y - 10
            
            if (self.hpBar.setProgress(2)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
                slimeGetHurtSound.run(SKAction.changeVolume(to: 5, duration: 0))
                slimeGetHurtSound.run(SKAction.play())
                
            }else{
                player.physicsBody = SKPhysicsBody()
                player.physicsBody?.affectedByGravity = false
                self.paddle.delegate = nil
                player.isDieing = true
                player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                    self.dieSound.run(SKAction.changeVolume(to: 5, duration: 0))
            
                    self.dieSound.run(SKAction.play())
                    self.view?.presentScene(GameScene(fileNamed: "EndScene"))
                }    ] ))
            }
            addChild(tempBoss)
            boss.append(tempBoss)
        } else if contact.bodyB.node?.name == "bossBullet" && contact.bodyA.node?.name == "player"{
            var flag = true
            for i in 0...boss.count - 1{
                if boss[i]!.hurtCounter < 3{
                    flag = false
                }
            }
            if flag == true {
                return
            }
            let tempBoss = Boss()
            tempBoss.position.x = player.getPOS().x + 20
            tempBoss.position.y = player.getPOS().y - 10
            
            if (self.hpBar.setProgress(2)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                player.showHurtAtlas()
                slimeGetHurtSound.run(SKAction.changeVolume(to: 5, duration: 0))
                slimeGetHurtSound.run(SKAction.play())
            }else{
                player.physicsBody = SKPhysicsBody()
                player.physicsBody?.affectedByGravity = false
                self.paddle.delegate = nil
                player.isDieing = true
                player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                    self.dieSound.run(SKAction.changeVolume(to: 5, duration: 0))
                    self.dieSound.run(SKAction.play())
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
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: -20, y: 140), duration: 0))
            
            status = 1
            moveWithCamara1()
            // contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "tpNode1" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyB.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: -20, y: 140), duration: 0))
            status = 1
            moveWithCamara1()
            // contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode2" && contact.bodyB.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: 400, y: 120), duration: 0))
            status = 2
            moveWithCamara1()
            inBossRoom = true
            InGameBackgroundSound.run(SKAction.stop())
            InBossGameBackgroundSound.run(SKAction.changeVolume(to: 10, duration: 0))
            InBossGameBackgroundSound.run(SKAction.play())
            
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "tpNode2" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyB.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: 400, y: 120), duration: 0))
            status = 2
            moveWithCamara1()
            inBossRoom = true
            InGameBackgroundSound.run(SKAction.stop())
            InBossGameBackgroundSound.run(SKAction.changeVolume(to: 10, duration: 0))
            InBossGameBackgroundSound.run(SKAction.play())
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode3" && contact.bodyB.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            self.view?.presentScene(GameScene(fileNamed: "EndScene"))
        } else if contact.bodyB.node?.name == "tpNode3" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            InGameBackgroundSound.run(SKAction.pause())
            
            self.view?.presentScene(GameScene(fileNamed: "EndScene"))
        }
        
        if contact.bodyA.node?.name == "tpNode4" && contact.bodyB.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: 250, y: 120), duration: 0))
            status = 2
            moveWithCamara1()
            inBossRoom = true
            InGameBackgroundSound.run(SKAction.stop())
            InBossGameBackgroundSound.run(SKAction.changeVolume(to: 15, duration: 0))
            InBossGameBackgroundSound.run(SKAction.play())
            
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "tpNode4" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyB.node as! TeleportNode
            if !door.isOpened {
                return
            }
            player.run(SKAction.move(to: CGPoint(x: 250, y: 120), duration: 0))
            status = 2
            moveWithCamara1()
            inBossRoom = true
            InGameBackgroundSound.run(SKAction.stop())
            InBossGameBackgroundSound.run(SKAction.changeVolume(to: 15, duration: 0))
            InBossGameBackgroundSound.run(SKAction.play())
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "tpNode5" && contact.bodyB.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            self.view?.presentScene(GameScene(fileNamed: "WinScene"))
        } else if contact.bodyB.node?.name == "tpNode5" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            InGameBackgroundSound.run(SKAction.pause())
            
            self.view?.presentScene(GameScene(fileNamed: "WinScene"))
        }
        if contact.bodyA.node?.name == "tpNode6" && contact.bodyB.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            self.view?.presentScene(GameScene(fileNamed: "WinScene"))
        } else if contact.bodyB.node?.name == "tpNode6" && contact.bodyA.node?.name == "player"{
            let door = contact.bodyA.node as! TeleportNode
            if !door.isOpened {
                return
            }
            InGameBackgroundSound.run(SKAction.pause())
            
            self.view?.presentScene(GameScene(fileNamed: "WinScene"))
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "enemy"{
            let enemy = contact.bodyB.node! as! Enemy
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
            if enemy.hurtCounter >= 3 && !enemy.isDieing{
                
                var flag = false
                for i in self.enemy{
                    if i!.hurtCounter < 3 && i!.name == "enemy"{
                        flag = true
                    }
                }
                if !flag{
                    tpNodes[1]?.showAtlas()
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "enemy"{
            let enemy = contact.bodyA.node! as! Enemy
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
            if enemy.hurtCounter >= 3  && !enemy.isDieing{
                var flag = false
                for i in self.enemy{
                    
                    if i!.hurtCounter < 3 && i!.name == "enemy"{
                        flag = true
                    }
                }
                if !flag{
                    tpNodes[1]?.showAtlas()
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "enemy2"{
            let enemy = contact.bodyB.node! as! Enemy
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
            if enemy.hurtCounter >= 3  && !enemy.isDieing{
                var flag = false
                for i in self.enemy{
                    
                    if i!.hurtCounter < 3 && i!.name == "enemy2"{
                        flag = true
                    }
                }
                if !flag{
                    tpNodes[3]?.showAtlas()
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "enemy2"{
            let enemy = contact.bodyA.node! as! Enemy
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
            
            if enemy.hurtCounter >= 3 && !enemy.isDieing{
                var flag = false
                for i in self.enemy{
                    
                    if i!.hurtCounter < 3 && i!.name == "enemy2"{
                        flag = true
                    }
                }
                if !flag{
                    tpNodes[3]?.showAtlas()
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "boss"{
            let enemy = contact.bodyB.node! as! Boss
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
                
            
            if enemy.hurtCounter >= 3  && !enemy.isDieing {
                var flag = true
                for i in 0...boss.count - 1{
                    if boss[i]!.hurtCounter < 3{
                        flag = false
                    }
                }
                if flag == true {
                    self.tpNodes[5]?.showAtlas()
                    self.bossDied = true
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "boss"{
            let enemy = contact.bodyA.node! as! Boss
            if !enemy.isDieing{
                enemy.showHurtAtlas()
                humanGetHurtSound.run(SKAction.play())
            }
            
            
            if enemy.hurtCounter >= 3 && !enemy.isDieing{
                var flag = true
                for i in 0...boss.count - 1{
                    if boss[i]!.hurtCounter < 3{
                        flag = false
                    }
                }
                if flag == true {
                    self.tpNodes[5]?.showAtlas()
                    self.bossDied = true
                }
                humanDiedSound.run(SKAction.play())
                enemy.isDieing = true
                enemy.showDeathAtlas()
                
            }
        }
        if contact.bodyA.node?.name == "puddle" && contact.bodyB.node?.name == "player"{
            let puddle = contact.bodyA.node! as! Puddle
            if puddle.counter >= 1{
                player.xScale = player.xScale + 0.005
                player.yScale = player.yScale + 0.005
                contact.bodyA.node?.removeFromParent()
                self.hpBar.setProgress(-1)
            }else{
                puddle.counter += 1
            }
            
            
        } else if contact.bodyB.node?.name == "puddle" && contact.bodyA.node?.name == "player"{
            let puddle = contact.bodyB.node! as! Puddle
            if puddle.counter >= 1{
                player.xScale = player.xScale + 0.005
                player.yScale = player.yScale + 0.005
                contact.bodyB.node?.removeFromParent()
                self.hpBar.setProgress(-1)
            }else{
                puddle.counter += 1
            }
        }
        if contact.bodyA.node?.name == "bullet" && contact.bodyB.node?.name == "player"{
            contact.bodyA.node?.removeFromParent()
            
            
            if (self.hpBar.setProgress(1)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                slimeGetHurtSound.run(SKAction.changeVolume(to: 5, duration: 0))
                slimeGetHurtSound.run(SKAction.play())
                
                player.showHurtAtlas()
            }else{
                player.physicsBody = SKPhysicsBody()
                player.physicsBody?.affectedByGravity = false
                self.paddle.delegate = nil
                player.isDieing = true
                self.dieSound.run(SKAction.changeVolume(to: 5, duration: 0))
                self.dieSound.run(SKAction.play())
                
                player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run {
                    self.view?.presentScene(GameScene(fileNamed: "EndScene"))
                }    ] ))
                
            }
            
        } else if contact.bodyB.node?.name == "bullet" && contact.bodyA.node?.name == "player"{
            contact.bodyB.node?.removeFromParent()
            
            if (self.hpBar.setProgress(1)){
                player.xScale = player.xScale - 0.01
                player.yScale = player.yScale - 0.01
                slimeGetHurtSound.run(SKAction.changeVolume(to: 5, duration: 0))
                slimeGetHurtSound.run(SKAction.play())
                
                player.showHurtAtlas()
            }
            else{
                player.physicsBody = SKPhysicsBody()
                player.isDieing = true
                self.dieSound.run(SKAction.changeVolume(to: 5, duration: 0))
                self.dieSound.run(SKAction.play())
                
                
                player.physicsBody?.affectedByGravity = false
                self.paddle.delegate = nil
                player.run(SKAction.sequence( [SKAction.animate(with: player.dieTxtureFrames , timePerFrame: 0.2), SKAction.run { self.dieSound.run(SKAction.play())
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
        addChild(InGameBackgroundSound)
        InBossGameBackgroundSound.autoplayLooped = false
        addChild(InBossGameBackgroundSound)
        slimeGetHurtSound.autoplayLooped = false
        dieSound.autoplayLooped = false
        humanDiedSound.autoplayLooped = false
        humanGetHurtSound.autoplayLooped = false
        gunShotSound.autoplayLooped = false
        starBackgroundSound.autoplayLooped = false
        addChild(slimeGetHurtSound)
        
        addChild(dieSound)
        addChild(humanDiedSound)
        addChild(humanGetHurtSound)
        addChild(gunShotSound)
        self.InGameBackgroundSound.run(SKAction.play())
        let texture = SKTexture(imageNamed: "lab anims_green puddle_00.png")
        skillUICircle = SkillUI(texture:  texture, size: CGSize(width: 30, height: 30))
        let tttt = SKTexture(imageNamed: "marioStar.png")
        
        skillUICircle2 = SkillUI(texture:   SKTexture(imageNamed: "marioStar.png"),size: CGSize(width: 10, height: 10))
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
        tpNode.position.y = 29.5
        
        tpNode.showAtlas()
        tpNode.name = "tpNode1"
        addChild(tpNode)
        let tpNode1 = TeleportNode()
        tpNode1.position.x = 210
        tpNode1.position.y = 29.5
        tpNode1.name = "tpNode2"
        addChild(tpNode1)
        let tpNode2 = TeleportNode()
        tpNode2.position.x = 100
        tpNode2.position.y = 29.5
        tpNode2.name = "tpNode3"
        addChild(tpNode2)
        tpNode2.showAtlas()
        let tpNode3 = TeleportNode()
        tpNode3.position.x = -20
        tpNode3.position.y = 193.2
        tpNode3.name = "tpNode4"
        let tpNode4 = TeleportNode()
        tpNode4.position.x = 520
        tpNode4.position.y = 29.5
        tpNode4.name = "tpNode5"
        tpNode4.showAtlas()
        let tpNode5 = TeleportNode()
        tpNode5.position.x = 400
        tpNode5.position.y = 193.5
        tpNode5.name = "tpNode6"
       
      
        addChild(tpNode3)
        addChild(tpNode4)
        addChild(tpNode5)
        tpNodes.append(tpNode)
        tpNodes.append(tpNode1)
        tpNodes.append(tpNode2)
        tpNodes.append(tpNode3)
        tpNodes.append(tpNode4)
        tpNodes.append(tpNode5)
       
        for i in 0...2 {
            let temp = Enemy()
            temp.position = CGPoint(x: 70*i, y: 7*i)
            enemy.append(temp)
            addChild(temp)
        }
        cameraNode = SKCameraNode()
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y:0)
        cameraNode.name = "camara"
        addChild(player)
        addChild(starBackgroundSound)
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
        self.hpBar = HpBarNode.init()
        
        
        self.addChild(hpBar)
        
        self.addChild(skillUICircle)
        
        skillUICircle.name = "puddle"
        skillUICircle2.name = "star"
        self.addChild(skillUICircle2)
        createScene1()
        player.position.x = -80
        self.hpBar.position.x = 50
    
    }
    func createScene1() {
        
        for i in 0...5 {
            let temp = Enemy()
            temp.position = CGPoint(x: -60 + 10 * i, y: 150  + i)
            temp.name = "enemy2"
            enemy.append(temp)
            addChild(temp)
        }
        for i in 0...8 {
            let temp = Enemy()
            temp.position = CGPoint(x: 480 + 10 * i, y: -15  + i)
            temp.name = "enemy3"
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
        self.zPosition = 88
    }
}

class HpBarTempNode: SKSpriteNode {
    
   
   
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "hpbarTemp.png")
        super.init(texture: texture, color:SKColor.clear, size: texture.size())
        
        
       
        
        
    }
    func setPos(pos:CGPoint){
        self.run(SKAction.move(to: pos, duration: 0.06))
        self.zPosition = 88
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    func setProgress(_ value:CGFloat) -> Bool{
       return true
        
    }
}

class HpBarNode: SKSpriteNode {
    
    var hpVal :Int = 10
    var hpBarNodes :[SKSpriteNode] = []
   
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "test.png")
        super.init(texture: texture, color:SKColor.clear, size: texture.size())
        for i in (0...9){
            let temp = HpBarTempNode()
            temp.position.x = CGFloat(-27 + 6 * i)
            temp.isHidden = false
            hpBarNodes.append(temp)
            self.addChild(temp)
        }
        
       
        
        
    }
    func setPos(pos:CGPoint){
        self.run(SKAction.move(to: pos, duration: 0.06))
        self.zPosition = 88
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    func setProgress(_ value:Int) -> Bool{
        hpVal = hpVal - value
        if hpVal <= 0 {
            for i in (0 ... 9){
                hpBarNodes[i].isHidden = true
            }
            return false
        }else{
            for i in (0 ... hpVal - 1){
                hpBarNodes[i].isHidden = false
            }
            if hpVal != 10{
                for i in (hpVal ... 9){
                    hpBarNodes[i].isHidden = true
                }
            }
            
        }
       return true
        
    }
}


class TeleportNode: SKSpriteNode {
    
    let openAtlas = SKTextureAtlas(named: "door_open.atlas")
    var opentextureFrames = [SKTexture]()
    var isOpened = false
    override init(texture:SKTexture?, color:SKColor, size: CGSize){
        let texture = SKTexture(imageNamed: "lab anims_door opening_00.png")
        super.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.alpha = 1
        
        for i in 0 ... 11 {
            let tempName = String(format: "lab anims_door opening_%.2d",i)
            let dbTexture = openAtlas.textureNamed(tempName)
            opentextureFrames.append(dbTexture)
        }
        self.xScale = 0.5
        self.yScale = 0.5
        self.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        self.physicsBody?.categoryBitMask = teleportCollisionMask
        self.physicsBody?.contactTestBitMask = playerCollisionMask
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        self.zPosition = 0
        //test.physicsBody?.isDynamic = false
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    func showAtlas(){
        self.run(SKAction.sequence([SKAction.animate(with: opentextureFrames, timePerFrame: 0.2), SKAction.run {
            self.isOpened = true
        }]) )
        self.texture = SKTexture(imageNamed: "lab anims_door opening_11.png")
        
        
    }
}

