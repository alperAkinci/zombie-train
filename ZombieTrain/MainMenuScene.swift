//
//  MainMenuScene.swift
//  ZombieTrain
//
//  Created by Alper on 30/04/16.
//  Copyright © 2016 allperr. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
       print((NSUserDefaults.standardUserDefaults().dictionaryRepresentation() as NSDictionary))

        
        let background = SKSpriteNode(imageNamed: "GreenMainMenu")
        
        background.position = CGPoint(x: self.size.width/2 , y : self.size.height/2)
        
        self.addChild(background)
        
    }
    
    //MARK : Touch Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        sceneTapped()
        
    }
    
   
    //MARK: Convenience Methods
    
    func sceneTapped(){
        
        let scene = GameScene(size:self.size)
        //let scene = GameOverScene(size: size , won: true)
        
        scene.scaleMode = self.scaleMode
        
        //Doorway transition effect
        let reveal = SKTransition.doorwayWithDuration(3.5)
        
        self.view?.presentScene(scene,transition: reveal)
    
        
    }


}

