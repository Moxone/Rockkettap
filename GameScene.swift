//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Rob Percival on 05/07/2016.
//  Copyright © 2016 Appfish. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var rocket = SKSpriteNode()
    
    var bg = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var score = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    enum ColliderType: UInt32 {
        
        case rocket = 1
        case Object = 2
        case Gap = 4
        
    }
    
    var gameOver = false
    
    func makespikes() {
        
        let moveSpikes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removeSpikes = SKAction.removeFromParent()
        let moveAndRemoveSpikes = SKAction.sequence([moveSpikes, removeSpikes])
        
        let gapHeight = rocket.size.height * 4
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let spikeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        let spikeTexture = SKTexture(imageNamed: "spike1.png")
        
        let spike1 = SKSpriteNode(texture: spikeTexture)
        
        spike1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + spikeTexture.size().height / 2 + gapHeight / 2 + spikeOffset)
        
        spike1.run(moveAndRemoveSpikes)
        
        spike1.physicsBody = SKPhysicsBody(rectangleOf: spikeTexture.size())
        spike1.physicsBody!.isDynamic = false
        
        spike1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        spike1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        spike1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        spike1.zPosition = -1
        
        self.addChild(spike1)
        
        let spike2Texture = SKTexture(imageNamed: "spike2.png")
        
        let spike2 = SKSpriteNode(texture: spike2Texture)
        
        spike2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - spikeTexture.size().height / 2 - gapHeight / 2 + spikeOffset)
        
        spike2.run(moveAndRemoveSpikes)
        
        spike2.physicsBody = SKPhysicsBody(rectangleOf: spikeTexture.size())
        spike2.physicsBody!.isDynamic = false
        
        spike2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        spike2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        spike2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        spike2.zPosition = -1
        
        self.addChild(spike2)
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + spikeOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spikeTexture.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        
        gap.run(moveAndRemoveSpikes)
        
        gap.physicsBody!.contactTestBitMask = ColliderType.rocket.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
            
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                
                score += 1
                
                scoreLabel.text = String(score)
                
                
            } else {
                
                self.speed = 0
                
                gameOver = true
                
                timer.invalidate()
                
                gameOverLabel.fontName = "Helvetica"
                
                gameOverLabel.fontSize = 30
                
                gameOverLabel.text = "Game Over! Tap to play again."
                
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
            }
            
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        
    }
    
    func setupGame() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makespikes), userInfo: nil, repeats: true)
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            bg.size.height = self.frame.height
            
            bg.run(moveBGForever)
            
            bg.zPosition = -2
            
            self.addChild(bg)
            
            i += 1
            
        }
        
        
        let rocketTexture = SKTexture(imageNamed: "rocket1.png")
        let rocketTexture2 = SKTexture(imageNamed: "rocket2.png")
        
        let animation = SKAction.animate(with: [rocketTexture, rocketTexture2], timePerFrame: 0.1)
        let makerocketFlap = SKAction.repeatForever(animation)
        
        rocket = SKSpriteNode(texture: rocketTexture)
        
        rocket.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        rocket.run(makerocketFlap)
        
        rocket.physicsBody = SKPhysicsBody(circleOfRadius: rocketTexture.size().height / 2)
        
        rocket.physicsBody!.isDynamic = false
        
        rocket.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        rocket.physicsBody!.categoryBitMask = ColliderType.rocket.rawValue
        rocket.physicsBody!.collisionBitMask = ColliderType.rocket.rawValue
        
        self.addChild(rocket)
        
        let ground = SKNode()
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        
        scoreLabel.fontSize = 60
        
        scoreLabel.text = "0"
        
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            
            rocket.physicsBody!.isDynamic = true
            
            rocket.physicsBody!.velocity = CGVector(dx: 0, dy: 200)
            
            rocket.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 100))
            
        } else {
            
            gameOver = false
            
            score = 0
            
            self.speed = 1
            
            self.removeAllChildren()
            
            setupGame()
            
            
        }
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
}
