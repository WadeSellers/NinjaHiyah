//
//  GameScene.swift
//  NinjaHiya
//
//  Created by Wade Sellers on 5/31/17.
//  Copyright © 2017 WadeSellers. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Monster : UInt32 = 0b1 // 1
    static let Projectile : UInt32 = 0b10 // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Create a ninja player
    let player = SKSpriteNode(imageNamed: "player")
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var monstersDestroyed = 0

    override func didMove(to view: SKView) {
        // Set background color of the scene
        backgroundColor = SKColor.white

        // Set ninja player's position
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)

        // Add ninja to the scene
        addChild(player)

        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self

        // Create monsters endlessly over time
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
                ])
        ))

        // Setup a score label
        scoreLabel.color = SKColor.green
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: \(monstersDestroyed)"
        scoreLabel.position = CGPoint(x: 10, y: 1)
        addChild(scoreLabel)

        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

    }

    // Give us a random number
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    // Give us a random number within a specified range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    func addMonster() {
        //1 Create a monster
        let monster = SKSpriteNode(imageNamed: "monster")

        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None

        //2 Set monster spawn spot on the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)

        //3 Position slightly off-screen along the right edge
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)

        //4 Add monster to scene
        addChild(monster)

        //5 Set speed of monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))

        //6 Create actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        // This line is used until we add GameOver message at the end
        //monster.run(SKAction.sequence([actionMove, actionMoveDone]))

        //We add a gameover message here and comment out the line above
        let loseAction = SKAction.run() {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

        //1 get a touch
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        //2 Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        //3 get offset of location to projectile (the x and y difference from projectile/person to touch)
        // We use an overloaded operator here to subtract 1 CGPoint from another.
        let offset = touchLocation - projectile.position

        //4 Bail if you are shooting down or backwards
        if (offset.x < 0) { return }

        //5 We know we are going to throw a projectile, so let's add it
        addChild(projectile)

        //6 Get direction of where to shoot
        let direction = offset.normalized()

        //7 Make it shoot far enough to guarantee it goes off screen
        let shootDistance = direction * 1000

        //8 Add the shot Distance to the current position
        let realDestination = shootDistance + projectile.position

        //9 Create the actions
        let actionMove = SKAction.move(to: realDestination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))

    }

    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("HIT!")
        projectile.removeFromParent()
        monster.removeFromParent()

        monstersDestroyed += 1
        scoreLabel.text = "Score: \(monstersDestroyed)"
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // When a contact happens, this is triggered.
        // In the contact parameter are 2 bodies; the 2 PhysicsBody that contacted.
        // They aren't in any order so we have to figure out what is what...

        // We will set these once we know what is what here...
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // Sort them with bodyA being PhysicCategory.Monster
        // and bodyB being PhysicsCategory.Projectile
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // If the firstBody is a Monster and the secondBody is a Projective,
        // fire off the projectileDidCollideWithMonster func
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    

} // end of Class
