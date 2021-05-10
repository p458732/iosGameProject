//
//  GameScene.swift
//  pj
//
//  Created by mac11 on 2021/5/5.
//  Copyright © 2021 mac11. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, JDPaddleVectorDelegate {
    var background: SKTileMapNode! //背景瓦片地图节点
    var paddle:JDGamePaddle!
    var player: Player!
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    
    var purpleTileMap:SKTileMapNode = SKTileMapNode()
    
    func getVector(vector: CGVector) {
        
        player.moveBy(vector: vector)
        let moveAction = SKAction.move(by: vector, duration: 0)
        self.camera!.run(moveAction)
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
         
     
    }
    override func didMove(to view: SKView) {
        createScene()
        for node in self.children{
            print(node.name)
            if(node.name == "test"){
                //    purpleTileMap = node as! SKTileMapNode
                
            }else{
                
            }
        }
        
    }
    func createScene() {
        paddle = JDGamePaddle(forScene: self, size:CGSize(width: 10, height: 10), position: CGPoint(x: 8, y: 8))
        paddle.delegate = self
        player = Player(forScene: self)
        cameraNode = SKCameraNode()
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y:0)
        cameraNode.name = "camara"
        addChild(cameraNode)
        camera = cameraNode
        let zoomInAction = SKAction.scale(to: 0.2, duration: 0)
        let moveAction = SKAction.move(by: CGVector(dx: 20, dy:60), duration: 2)
        cameraNode.run(zoomInAction)
        // cameraNode.run(moveAction)
        self.player.moveBy(vector: playerVector)
        
    }
    
    
}

