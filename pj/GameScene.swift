//
//  GameScene.swift
//  pj
//
//  Created by mac11 on 2021/5/5.
//  Copyright © 2021 mac11. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, JDPaddleVectorDelegate , SKPhysicsContactDelegate{
    var background: SKTileMapNode! //背景瓦片地图节点
    var paddle:JDGamePaddle!
    var player :Player!
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    var tileMap: SKTileMapNode? = SKTileMapNode()
    var purpleTileMap: SKTileMapNode = SKTileMapNode()
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
        self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0), duration: 0.06))
        vec = CGVector(dx: vector.dx / 2, dy: vector.dy / 2)
        paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: -20) )
        
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
    self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0) ,duration: 0.06))
        paddle.paddle.setPos(pos: CGPoint(x: player.getPOS().x - 80 , y: -20) )
    }
    
    override func update(_ currentTime: TimeInterval) {
    
        keepMove()
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        print("A name: " )
        print(contact.bodyA.node?.name)
        print("B name: " )
        print(contact.bodyB.node?.name)
        if contact.bodyA.node?.name == "ships"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else if contact.bodyB.node?.name == "ships" {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if contact.bodyA.node?.name == "bullet" && contact.bodyB.node?.name == "rocks"{
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "bullet" && contact.bodyA.node?.name == "rocks"{
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyA.node?.name == "bullet" && contact.bodyB.node?.name == "coins"{
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "bullet" && contact.bodyA.node?.name == "coins"{
            contact.bodyA.node?.removeFromParent()
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
                                tileNode.name = "ss"
                                tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                                 tileNode.physicsBody?.categoryBitMask = 0x1 << 6
                                 tileNode.physicsBody?.contactTestBitMask = 0x1 << 7
                                tileNode.physicsBody?.collisionBitMask = 0x1 << 1
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
        player = Player()
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
        
    }
    
    
}

