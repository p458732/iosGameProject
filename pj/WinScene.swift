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

class WinScene: SKScene, SKPhysicsContactDelegate{
    var background: SKTileMapNode! //背景瓦片地图节点
   
    
    
  
    var player :Player!
    let WinGameBackgroundSound = SKAudioNode(fileNamed: "winGame.mp3")
    var cameraNode: SKCameraNode!
    var playerVector =  CGVector(dx: 0, dy: 0)
    var tileMap: SKTileMapNode? = SKTileMapNode()
    var purpleTileMap: SKTileMapNode = SKTileMapNode()
    var lastTime : TimeInterval = 0;
    let button = SKSpriteNode(imageNamed: "againBtn")
    let EXitbutton = SKSpriteNode(imageNamed: "exitBtn")
    let logo = SKSpriteNode(imageNamed: "winlogo")
    func moveWithCamara(){
         self.camera?.run(SKAction.move(to: CGPoint(x: player.getPOS().x, y: 0) ,duration: 0.06))
        
      
       
    }
    var vec : CGVector = CGVector()
    
    
  
   
    override func didMove(to view: SKView) {
       
         button.name = "againBtn"
         button.size.height = 85
         button.size.width = 150
         button.position.x = 0
         button.position.y = -40
         self.addChild(button)
        
         self.addChild(WinGameBackgroundSound)
         EXitbutton.name = "btn"
         EXitbutton.size.height = 95
         EXitbutton.size.width = 170
         EXitbutton.position.x = 0
         EXitbutton.position.y = -120
        self.addChild(EXitbutton)
        logo.position.x = 0
        logo.position.y = 90
        self.addChild(logo)
         //Adjust button properties (above) as needed
         }
   
    
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
       
        let position = touch.location(in: self)
        if((button.contains(position)))
        {
       
        
                    print("test")
           
   
              let yourNextScene = GameScene(fileNamed: "GameScene")
            yourNextScene?.scaleMode = .aspectFill
            WinGameBackgroundSound.run(SKAction.stop())
              self.view?.presentScene(yourNextScene!)
   
        
         }
        else if((EXitbutton.contains(position)))
             {
            
             
                         exit(0)
                
        
                   // let yourNextScene = YourNextScene(fileNamed: "YourNextScene")
                    //self.view?.presentScene(yourNextScene!)
        
             
              }
      }
   
    
   
    
    
    
        
    
   
    
}

