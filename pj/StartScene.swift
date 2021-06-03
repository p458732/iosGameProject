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

class StartScene: SKScene, SKPhysicsContactDelegate{
    var background: SKTileMapNode! //背景瓦片地图节点
   
    
    
  
    var player :Player!
    
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    var tileMap: SKTileMapNode? = SKTileMapNode()
    var purpleTileMap: SKTileMapNode = SKTileMapNode()
    var lastTime : TimeInterval = 0;
    let button = SKSpriteNode(imageNamed: "startBtn")
    let EXitbutton = SKSpriteNode(imageNamed: "exitBtn")
    let logo = SKSpriteNode(imageNamed: "logo")
    func moveWithCamara(){
         self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0) ,duration: 0.06))
        
      
       
    }
    var vec : CGVector = CGVector()
    
    
  
   
    override func didMove(to view: SKView) {
        createScene()
         button.name = "btn"
         button.size.height = 16
         button.size.width = 24
         button.position.x = 170
         button.position.y = 0
         self.addChild(button)
        
         EXitbutton.name = "btn"
         EXitbutton.size.height = 16
         EXitbutton.size.width = 24
         EXitbutton.position.x = 200
         EXitbutton.position.y = 1
        self.addChild(EXitbutton)
         //Adjust button properties (above) as needed
         }
   
    
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
       
        let position = touch.location(in: self)
        if((button.contains(position)))
        {
       
        
                    print("test")
           
   
              let yourNextScene = GameScene(fileNamed: "GameScene")
              self.view?.presentScene(yourNextScene!)
   
        
         }
        else if((EXitbutton.contains(position)))
             {
            
             
                         exit(0)
                
        
                   // let yourNextScene = YourNextScene(fileNamed: "YourNextScene")
                    //self.view?.presentScene(yourNextScene!)
        
             
              }
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
    
    
   
    func createScene() {
       
        player = Player()
        
        player.position.x = -50
        player.position.y  = 20
        logo.position.x = 100
        logo.position.y = 30
        logo.size.width = 70
        logo.size.height = 30
        logo.alpha = 0
        cameraNode = SKCameraNode()
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y:0)
        cameraNode.name = "camara"
        addChild(player)
        self.button.alpha = 0
        self.EXitbutton.alpha = 0
        addChild(cameraNode)
        addChild(logo)
        camera = cameraNode
        let zoomInAction = SKAction.scale(to: 0.27, duration: 0)
        let moveAction = SKAction.move(by: CGVector(dx: 20, dy:60), duration: 2)
       
        cameraNode.run(zoomInAction)
        // cameraNode.run(moveAction)
        
        player.run(SKAction.sequence([SKAction.move(by: CGVector(dx: 220, dy: 0), duration: 5),
                                      SKAction.run {
                                        
                                        self.logo.run(SKAction.sequence([ SKAction.fadeAlpha(to: 1, duration: 0.5), SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.5), SKAction.scale(to: 0.7, duration: 0.5)]))]))
                                        self.button.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
                                        self.EXitbutton.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
                                       
            }]) )
        self.camera?.run(SKAction.move(by: CGVector(dx: 160, dy: 0) ,duration: 5))
    }
    
    
        
    
   
    
}

