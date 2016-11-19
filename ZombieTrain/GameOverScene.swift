//
//  GameOverScene.swift
//  ZombieTrain
//
//  Created by Alper on 12/04/16.
//  Copyright © 2016 allperr. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let won : Bool
    var highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let savedScore: Int = NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as! Int
    
    init(size: CGSize ,won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        var background : SKSpriteNode
         setHighScoreLabel()
        if(won){
            background = SKSpriteNode(imageNamed: "YouWinScene")
            background.zPosition = 50
            runAction(SKAction.sequence([SKAction.waitForDuration(0.1),SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)]))
            highScoreLabel.text = "Congrats! New High Score: \(savedScore)"
            
        }else{
            background = SKSpriteNode(imageNamed: "GameOverScene")
            runAction(SKAction.sequence([SKAction.waitForDuration(0.1),SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)]))
        
        }
        
        background.position = CGPoint(x: self.size.width/2 , y : self.size.height/2)
       
        
        self.addChild(background)
        
        
        
        
    }
    
    //MARK : Touch Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        sceneTapped()
        
    }
    
    
    //MARK: Convenience Methods
    
    func sceneTapped(){
        
        let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        
        scene.scaleMode = self.scaleMode
        
        //Doorway transition effect
        let reveal = SKTransition.doorwayWithDuration(1.5)
        
        self.view?.presentScene(scene,transition: reveal)
        
    }
    
    func setHighScoreLabel(){
        
        
        
        //set the text to a placeholder
        highScoreLabel.text = "High Score: \(savedScore)"
        //set the color of the text
        highScoreLabel.fontColor = SKColor.blackColor()
        //set the font size
        highScoreLabel.fontSize = 100
        //set the label top of the scene
        highScoreLabel.zPosition = 500
        //label to stay in the same position, regardless of how the camera moves
        
        /*
         Unlike SKSpriteNode, SKLabelNode doesn’t have an anchorPoint property. In its place, you can use the verticalAlignmentMode and horizontalAlignmentMode properties.
         The default alignment modes of SKLabelNode are Center for horizontal and Baseline for vertical.
         */
        
        highScoreLabel.horizontalAlignmentMode = .Center
        highScoreLabel.verticalAlignmentMode = .Center
        highScoreLabel.position = CGPoint(x: self.size.width/2 , y : self.size.height - 300)
// (old comment )//overlapAmount()/2)//to resolve the camera behavior bug , also added overlapAmount()/2 to the y-axis
        
        
        //add the node as a child of the camera
        self.addChild(highScoreLabel)
        
    }


}
