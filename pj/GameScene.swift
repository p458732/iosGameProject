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
    var paddle:JDGamePaddle!
    var player: Player!
    var playerVector =  CGVector(dx: 0, dy: 0)
    
    func getVector(vector: CGVector) {
        self.playerVector.dx = vector.dx
        self.playerVector.dy = vector.dy
      
    }
    
    override func didMove(to view: SKView) {
        createScene()
    }
    func createScene() {
        paddle = JDGamePaddle(forScene: self, size:CGSize(width: 200, height: 200), position: CGPoint(x: self.frame.minX + 80.0, y: self.frame.minY + 80.0))
        paddle.delegate = self
        player = Player(forScene: self)
        self.player.moveBy(vector: playerVector)
    }
    
}

