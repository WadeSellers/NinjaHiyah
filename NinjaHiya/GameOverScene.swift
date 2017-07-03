//
//  GameOverScene.swift
//  NinjaHiya
//
//  Created by Wade Sellers on 6/1/17.
//  Copyright © 2017 WadeSellers. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {

    init(size: CGSize, won:Bool) {

        super.init(size: size)

        // Set the scene's background color
        backgroundColor = SKColor.white

        // Set a message to display if you win or lose.
        // This is decided in the init method parameter won BOOL
        // If won is TRUE, You Won, else You Lose
        let message = won ? "You Won!" : "You Lose :["

        // Setup a label for displaying message above
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        // show scene for 3 seconds with a flipHorizontal transition
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                // 5
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}// end of Class
