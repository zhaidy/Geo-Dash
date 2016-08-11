//
//  GameScene.swift
//  Geo Dash
//
//  Created by Dongyu Zhai on 11/8/16.
//  Copyright (c) 2016 Dongyu Zhai. All rights reserved.
//

import SpriteKit

var gameOption = Int()

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var referenceTimer = NSTimer()
    var person = SKSpriteNode()
    
    var isJumping = Bool()
    var isTouching = Bool()
    
    var arrayOfObstacles = [String]()
    
    var score = Int()
    var scoreTimer = NSTimer()
    var highScore = Int()
    
    var highScoreLbl = SKLabelNode()
    var scoreLbl = SKLabelNode()
    
    var died = Bool()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        died = false
        
        referenceTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.pickReference), userInfo: nil, repeats: true)
        
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameScene.addScore), userInfo: nil, repeats: true)
        
        highScoreLbl = self.scene?.childNodeWithName("HighScoreLbl") as! SKLabelNode
        scoreLbl = self.scene?.childNodeWithName("ScoreLbl") as! SKLabelNode
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.integerForKey("highscore") != 0 {
            
            highScore = userDefault.integerForKey("highscore")
            highScoreLbl.text = "HighScore : \(highScore)"
        }
        else {
            highScore = 0
            highScoreLbl.text = "HighScore : \(highScore)"
        }
        
        scoreLbl.text = "Score : \(score)"
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -30)
        
        person = self.scene?.childNodeWithName("Person") as! SKSpriteNode
        person.alpha = 1
        person.physicsBody?.collisionBitMask = 1 | 3
        person.physicsBody?.contactTestBitMask = 1 | 3
        
        switch gameOption {
        case 1:
            person.color = SKColor.greenColor()
            return
        case 2:
            person.color = SKColor.blueColor()
            return
        case 3:
            person.color = SKColor.blackColor()
            return
        default:
            person.color = SKColor.blackColor()
            return
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        isTouching = true
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name == "retryBtn" {
                
                restartScene()
            }
        }
        
        jump()
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        isTouching = false
    }
    
    func addScore() {
        
        score += 1
        scoreLbl.text = "Score : \(score)"
        
        if score > highScore {
            
            highScore = score
            highScoreLbl.text = "HighScore : \(highScore)"
            
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setInteger(score, forKey: "highscore")
        }
    }
    
    func jump() {
        
        if isTouching {
            if isJumping == false {
                person.physicsBody?.applyImpulse(CGVectorMake(0, 3000))
                isJumping = true
            }
        }
        
    }
    
    func restartScene() {
        
        let scene = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.crossFadeWithDuration(0.5)
        let view = self.view as SKView!
        scene?.scaleMode = SKSceneScaleMode.AspectFill
        view.presentScene(scene!, transition: transition)
        
    }
    
    func buildExplosion(spriteToExplode: SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion.sks")
        explosion?.numParticlesToEmit = 200
        
        explosion?.position = spriteToExplode.position
        
        explosion?.runAction(SKAction.playSoundFileNamed("Explosion.wav", waitForCompletion: false))
        
        spriteToExplode.removeFromParent()
        self.addChild(explosion!)
        
        die()
        
    }
    
    func die() {
        
        died = true
        
        scoreTimer.invalidate()
        
        let retryBtn = SKSpriteNode(imageNamed: "retry")
        retryBtn.name = "retryBtn"
        
        let waitDuration = SKAction.waitForDuration(1)
        let fadeIn = SKAction.fadeInWithDuration(0.3)
        
        retryBtn.alpha = 0
        
        retryBtn.position = CGPointMake(self.frame.width / 2 , self.frame.height / 2)
        
        self.addChild(retryBtn)
        
        retryBtn.runAction(SKAction.sequence([waitDuration, fadeIn]))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        
        // Collision with ground
        if bodyA?.physicsBody?.categoryBitMask == 2 && bodyB?.physicsBody?.categoryBitMask == 1 {
            
            isJumping = false
            jump()
        }
        else if bodyA?.physicsBody?.categoryBitMask == 1 && bodyB?.physicsBody?.categoryBitMask == 2 {
            
            isJumping = false
            jump()
        }
        
        // Collision with obstacle
        else if bodyA?.physicsBody?.categoryBitMask == 2 && bodyB?.physicsBody?.categoryBitMask == 3 {
            
            isJumping = false
            jump()
        }
        else if bodyA?.physicsBody?.categoryBitMask == 3 && bodyB?.physicsBody?.categoryBitMask == 2 {
            
            isJumping = false
            jump()
        }
        
        // Collision with Enemy
        else if bodyA?.physicsBody?.categoryBitMask == 2 && bodyB?.physicsBody?.categoryBitMask == 4 {
            
            for node in self.children {
                node.removeAllActions()
            }
            referenceTimer.invalidate()
            buildExplosion(person)
        }
        else if bodyA?.physicsBody?.categoryBitMask == 4 && bodyB?.physicsBody?.categoryBitMask == 2 {
            
            for node in self.children {
                node.removeAllActions()
            }
            referenceTimer.invalidate()
            buildExplosion(person)
        }
    }
    
    func pickReference() {
        
        arrayOfObstacles = ["Obstacle1", "Obstacle2", "Obstacle3"]
        let randomNumber = arc4random() % UInt32(arrayOfObstacles.count)
        
        addReference(arrayOfObstacles[Int(randomNumber)])
    }
    
    func addReference(obstacleName: String) {
        
        let reference = NSBundle.mainBundle().pathForResource(obstacleName, ofType: "sks")
        let referenceNode = SKReferenceNode(URL: NSURL(fileURLWithPath: reference!))
        
        referenceNode.position = CGPointMake((self.scene?.frame.size.width)!, 100)
        
        self.addChild(referenceNode)
        
        let moveAction = SKAction.moveToX(0 - referenceNode.scene!.frame.width, duration: 10.0)
        let distroyAction = SKAction.removeFromParent()
        
        referenceNode.runAction(SKAction.sequence([moveAction, distroyAction]))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if !died {
            
            if person.position.x <= 0 - person.frame.width / 2 {
                
                die()
                
                for node in self.children {
                    
                    if node.name != "retryBtn" {
                        
                        node.removeAllActions()
                    }
                }
                
                referenceTimer.invalidate()
            }
        }
    }
}
