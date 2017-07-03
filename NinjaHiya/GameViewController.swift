//
//  GameViewController.swift
//  NinjaHiya
//
//  Created by Wade Sellers on 5/31/17.
//  Copyright © 2017 WadeSellers. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}
