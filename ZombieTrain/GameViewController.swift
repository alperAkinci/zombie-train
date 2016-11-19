//
//  GameViewController.swift
//  ZombieTrain
//
//  Created by Alper on 05/03/16.
//  Copyright (c) 2016 allperr. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        
        //Its handy to show FPS onscreen by default . Ideally we want at least 30 FPS.
        skView.showsFPS = true
        
        /*
          Keep node count as low as possible :
            -Its good to remove nodes from the scene graph when they are off screen and you no longer need them .
        */
        
        //Display the count of nodes that it rendered in the last pass.
        skView.showsNodeCount = true
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        
    }
  }
