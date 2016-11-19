//
//  GameScene.swift
//  ZombieTrain
//
//  Created by Alper on 05/03/16.
//  Copyright (c) 2016 allperr. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    //SKCameraNode
    
    var cameraNode = SKCameraNode()
    
    //Visible Playable Area
    var cameraRect : CGRect {
        return CGRect(
            x: getCameraPosition().x - size.width/2
                + (size.width - playableRect.width)/2,
            y: getCameraPosition().y - size.height/2
                + (size.height - playableRect.height)/2,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    //-------------------
    // Game Logic
    var lives = 5 { didSet{
        
        print("Lives:\(lives)")
        //Updating the "Lives:" text at the bottom left
        livesLabel.text = "Lives: \(lives)"}
    
    }
    var gameOver = false
    
    var trainCount = 0{ didSet{
        
        print("Score:\(trainCount)")
        //Updating the "Lives:" text at the bottom left
        scoreLabel.text = "Score: \(trainCount)"
        }
        
    }
    //-------------------
    
    var lastUpdateTime : NSTimeInterval = 0
    //Current time - lastUpdatedTime = Delta Time (The time between each update() is called)
    var dt : NSTimeInterval = 0
    
    //Speed Of Zombie
    //In one second , the zombie should move 480 points , about 1/4 of the scene width.(Length : How far zombie should move in a second.)
    let zombieMovePointsPerSec : CGFloat = 800.0
    let ballMovePointsPerSec : CGFloat = 480.0
    
    let cameraMovePointsPerSec : CGFloat = 200.0
    
    /*
        Direction + Length = Velocity of Zombie (CGPoint)
        (Think of it as how far and in what direction the zombie should move in 1 second. )
    */
    var velocity = CGPoint.zero
    
    //Storing the playeble rectangle
    let playableRect : CGRect
    
    var lastTouchLocation : CGPoint = CGPoint.zero
    
    let zombieRotateRadiansPerSec: CGFloat = 3.0 * π  // 4*(3.14)
    
    //Zombie Animation Action
    var zombieAnimation : SKAction
    
    //Collision Sound Actions
    let enemyCollisionSound : SKAction = SKAction.playSoundFileNamed("car-punch.wav", waitForCompletion: false)
    let ballCollisionSound : SKAction = SKAction.playSoundFileNamed("blinkHard.wav", waitForCompletion: false)
    
    //Cat Colorization to green after hit
    let colorizeCat = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.3)
    
    //Zombie Colorization to red after Hit
    let colorizeRedZombie = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration:0.0)
   
    //Zombie Colorization back to normal color
    let colorizeNormalZombie = SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.15)
    
    //Zombie Blink Action
    let blinkTimes = 10.0
    let duration : NSTimeInterval = 3.0
    var blinkAction : SKAction {  return SKAction.customActionWithDuration( duration ) { node, elapsedTime in
        
        /*Divide the duration by the number of blinks the desired in that time period. Call that a "slice" of time. In each slice, the node should be visible for half the time, and invisible for the other half. That is what will make the node appear to blink.*/
        let slice = 3.0 / self.blinkTimes
        let remainder = Double(elapsedTime) % slice
        node.hidden = remainder > slice / 2
        }
    }
    
    //Checks the zombie is Active or not
    var zombieIsActive = false
    
    //Passing in the "Chalkduster" font 
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")

    
    //Initializer fot playebleRect
    override init(size: CGSize) {
        
        //Playable Rectangle Settings
        
            // 1 - Max Aspect Ratio Supported is 16:9(1.77)
            let maxAspectRatio: CGFloat = 16.0 / 9.0
            // 2 - Playable width will always be equal to the scene width.To calculate the playable height : (Ratio Problem)16 -> size.width , 9 -> X . Solution : ((9*size.width)/16)
            let playableHeight = size.width / maxAspectRatio
            // 3 - Determine the margin on the top and bottom by subtracting the playable height from the scene height and dividing the result by two
            let playableMargin = (size.height - playableHeight)/2.0
            // 4 - The origin is lower-left , drawing centered rectangle on the screen
            playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        //---------------------------
        
        //Zombie Animation Texture Settings
        
            var textures : [SKTexture] = []
            
            for i in 1...4 {
                textures.append(SKTexture(imageNamed: "zombie\(i)"))
            }
        
    
        
            textures.append(textures[2]) // zombie3
            textures.append(textures[1]) // zombie2
            //Texture frame order : 1 2 3 4 3 2
            
            zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.2)
        
        
        
        //initializer of super class
            super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //1 - Creating a Sprites
    
        //MARK: - Creating Sprites
    
        
        let zombie = SKSpriteNode(imageNamed: "zombie1")
    

    
        //MARK: - Override Methods
    
        //didMoveToView : SpriteKit calls this method before it presents in a view. ,Good place to make some initial setup of scene content.
    override func didMoveToView(view: SKView) {
            //To get the saved score
//        let savedScore: Int = NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as! Int
//        
//        print("Highest Score : \(savedScore)")
        
      NSUserDefaults.standardUserDefaults().setObject(0, forKey:"HighestScore")
//        NSUserDefaults.standardUserDefaults().synchronize()
        
        //Make background Black Color
        backgroundColor = SKColor.blackColor()
        
        //Play the background music
        playBackgroundMusic("sky-loop.wav")
        
        //Add Camera Node
        addChild(cameraNode)
        camera  = cameraNode
        setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))
       
        
    //2 - Positioning a Sprite
        
        //MARK: Background
        
        
        //create two copies of the background and then sets their positions, so the second copy of background begins after the first ends.
        for i in 0...1{
            let background = backgroundNode()
            // By default sprite(background image) positions as a bottom left of the screen(0,0)
        
            //Pinning the lower-left corner of background to the lower-left of the scene
            background.anchorPoint = CGPoint.zero // (0,0)
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            
        
            background.name = "background"
            addChild(background)
            background.zPosition = -1
        
        }
        //MARK: Zombie
        
        zombie.position = CGPoint(x: self.size.width/2 , y : self.size.height - 300)

        
            /*
            Challenge : Scale to zombies size x2
            zombie.setScale(2)
            */
        
            //Already is set true by default
            zombie.userInteractionEnabled = true
        
            zombie.zPosition = 100

    
    
    //3 - Setting z-position of nodes
        
        /* Z-Position : Each node draws its child nodes in the order of their z-position , from lowest to highest .
            Default z-position is 0 when we add new node*/
        
        //SpriteKit will draw "background" sprite before anything else you add to the scene
        
        
        
        
    //4 - Add the sprite to the scene graph
        
        addChild(zombie)
        
        
        /*How to get size of node*/
        //let mySize = background.size
        //print(mySize)
        //print(self.size)
    
    
    //5 - Setting Text Labels of Scene
        
        setLivesLabel()
        setScoreLabel()
        setHighScoreLabel()
    
        
    //6 - Actions for GameScene
        //runAction works because the self which is GameScene is a node , and any node can run actions.
    self.runAction(SKAction.repeatActionForever(
        SKAction.sequence([SKAction.runBlock({self.spawnEnemy()}),
                           SKAction.waitForDuration(2)] )))
    
    self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(showBall) , SKAction.waitForDuration(1.0)])))
    
    
    }
    
   
    //Update Function : Called each frame and is a good spot to update the position. if update() takes too long , the frame rate (FPS) might decrease.
    override func update(currentTime: NSTimeInterval) {
        
        //Calculate the time interval since the last call to update() and store that time interval in dt(delta time)
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt*1000) miliseconds since last update")
        
        /*
            Conclusion:
            - There is a time varience between each time uptate() called
            - Thats why the movement looks jagged and irreguler
        */
        
            moveTo(zombie, velocity: velocity)
            
            //Checking if the zombie at the bounds of screen
            boundCheckZombie()
            
            //Rotating zombie based on a direction on frame
            rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec )
        /*
        }
        */
        
        moveTrain()
        
        
        moveCamera()
        
        
        // SKCameraNode
        
        //Test
        //camera follows zombie position
        //camera?.position = zombie.position
        
        
        //MARK: Game Over Scene - Won
      
        // if the remaining live is 0 or less , and make sure the game isnt already over.
        if lives <= 0 && !gameOver {
            gameOver = true
            
            if (NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as! Int) < trainCount{
                
                NSUserDefaults.standardUserDefaults().setObject(trainCount, forKey:"HighestScore")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let gameOverScene = GameOverScene(size: size , won: true)
                gameOverScene.scaleMode = scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                view?.presentScene(gameOverScene,transition: reveal)
           
            }else{
            
                let gameOverScene = GameOverScene(size: size , won: false)
                gameOverScene.scaleMode = scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                view?.presentScene(gameOverScene,transition: reveal)
            }
            
            
            //To get the saved score
            let savedScore: Int = NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as! Int
                
                print("Highest Score : \(savedScore)")
            
        }
        
    }
    
    override func didEvaluateActions() {
        checkCollision()
    }

//MARK: - Convenience Methods
   
    
    func moveTo(sprite: SKSpriteNode,velocity : CGPoint){
    //Method that takes sprite to be moved and a velocity vector which to move it.
    
        //1 - Calculating the vector representing the distance and direction to move the zombie in this frame
            /*Zombie is now moving a different number of points each frame , based on how much time has elapsed(dt).*/
            let amountToMove = velocity * CGFloat(dt)
            
            //print("Amount to move: \(amountToMove)")
            
        //2 - To determine the zombie's new position , simply add vector to the point
            sprite.position = sprite.position + amountToMove
        
        
        
    }
    
    
    func moveZombieTowardTheTappedLocation(location : CGPoint){
        //offset vector
        let offset = location - zombie.position
        
        //Normalizing a vector : Unit Vector , vector length is 1 , at the same direction wanted
        let unitVector = offset.normalized()
        
        //Making length of offsetVector exactly same as zombieMovePointsPerSec
        velocity = unitVector * zombieMovePointsPerSec
        
        startZombieAnimation()
        
    }
    
    
    func boundCheckZombie(){
        //grab the coordinates from the visible playable area
        let leftBottom = CGPoint(x: CGRectGetMinX(cameraRect),
                                 y: CGRectGetMinY(cameraRect))
        let topRight = CGPoint(x: CGRectGetMaxX(cameraRect),
                               y: CGRectGetMaxY(cameraRect))
    
        if zombie.position.y <= leftBottom.y {
            zombie.position.y = leftBottom.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
        if zombie.position.x <= leftBottom.x{
            zombie.position.x = leftBottom.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x{
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
    }
    
   
    
    //Rotating a Zombie
    func rotateSprite(sprite : SKSpriteNode , direction : CGPoint ,rotateRadiansPerSec: CGFloat){
        
        //The shortest distance in radian between current angle of zombie and target angle
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: direction.angle)
        
        //Amount to rotate in each frame
        let amtToRotate = rotateRadiansPerSec * CGFloat(dt)
        
        //print(shortest)
        
        if abs(shortest) > amtToRotate {
            sprite.zRotation += amtToRotate * shortest.sign()
            
        }else{
            sprite.zRotation = direction.angle
        }
    }

    // First Version - Learning Material Function - Not Used
    func notUsedspawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "jeep")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        addChild(enemy)
        
        //Action of Enemy
        
            //example :moveByX
            //let actionMoveBy = SKAction.moveByX(-(size.width+enemy.size.width/2), y: 0, duration: 2)
        
        //Sequence of Actions
        // 1 - First part of the action
        
        let actionMidMoveTo = SKAction.moveTo(CGPoint(x:size.width/2,
                                                    y: CGRectGetMinY(playableRect) + enemy.size.height/2),
                                             duration: 1.0)
        let actionMidMoveBy = SKAction.moveByX(-(size.width/2 + enemy.size.width/2), y: -CGRectGetHeight(playableRect)/2 + enemy.size.height/2 , duration: 1.0)
        
        // 2 - Second part of the action
        let actionMove = SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y: size.height/2),duration: 1.0)
        
        let actionMoveBy = SKAction.moveByX(-(size.width/2 + enemy.size.width/2), y: +CGRectGetHeight(playableRect)/2 - enemy.size.height/2, duration: 1.0)
        
        //Wait-for-duration action
        let wait = SKAction.waitForDuration(0.50)
        
        //Run-block action
        let logMessage = SKAction.runBlock(){
            print("Reached Bottom!")
            
        }
        
        // 3 - The sequence action will run one action after another
        
        //Sequence with moveTo actions
        let sequenceTo = SKAction.sequence([actionMidMoveTo,logMessage,wait,actionMove,actionMidMoveTo])
        
        //Sequence with moveBy actions
        let sequenceBy = SKAction.sequence([actionMidMoveBy,logMessage,wait,actionMoveBy])
        
        //Usage of reversed sequence
        let sequence = SKAction.sequence([sequenceBy,sequenceBy.reversedAction()])
        
        
        //Action that repeats the sequence of other actions forever!
        let repeatAction = SKAction.repeatActionForever(sequence)
        enemy.runAction(repeatAction)
        

    }
    
    
    //Enemy shows up in screen
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "jeep")
        
        enemy.name = "enemy"
        enemy.position = CGPoint(x: CGRectGetMaxX(cameraRect) + enemy.size.width/2,
            y: CGFloat.random(min: CGRectGetMinY(cameraRect) + enemy.size.height/2, max: CGRectGetMaxY(cameraRect) - enemy.size.height/2))
        enemy.zPosition = 400
        
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(CGRectGetMinX(cameraRect) - enemy.size.width/2, duration: 2.0)
        let removeAction = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove,removeAction]))
    }
    
    //Balls show up in screen
    func showBall(){
        let ball = SKSpriteNode(imageNamed: "RainbowBall")
        ball.name = "ball"
        ball.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(cameraRect),
                max: CGRectGetMaxX(cameraRect)),
            y: CGFloat.random(min: CGRectGetMinY(cameraRect),
                max: CGRectGetMaxY(cameraRect)))
        //make sure cat stays top of the screen
        ball.zPosition = 50
        
        ball.setScale(0)// makes ball invisible
        addChild(ball)
        
        //1 - Appear
            let appear = SKAction.scaleTo(1.0, duration: 0.5)
        //2- Wiggle And Scale
            //Wiggle Action
            ball.zRotation = -π / 16.0 // 11.25 degree clockwise(-)
            let leftWiggle = SKAction.rotateByAngle(π, duration: 1.0) // 22.50 degree counterclockwise(+)
            let rightWiggle = leftWiggle.reversedAction()
            let fullWiggle = SKAction.sequence([leftWiggle]) //0.5 + 0.5
            //Scale Action
            let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
            let scaleDown = scaleUp.reversedAction()
            let fullScale = SKAction.sequence([scaleUp , scaleDown, scaleUp , scaleDown])//0.25 + 0.25 + 0.25 + 0.25
            // Group Action : wiggling and scaling at the same time
            let group = SKAction.group([fullWiggle,fullScale])
            let groupWait = SKAction.repeatAction(group, count: 10) // 10 sec
        //3 - Disappear
            let disappear = SKAction.scaleTo(0, duration: 0.5)
        //4 - RemoveFromParent
            let removeFromParent = SKAction.removeFromParent()
        
        let actions = [appear,groupWait,disappear,removeFromParent]
        ball.runAction(SKAction.sequence(actions))
        
    }
    
    
    //Zombie Animation Controller Animations
    func startZombieAnimation(){
        //make sure there isnt already an action running with the key "animation"
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation(){
        zombie.removeActionForKey("animation")
    }
    
    //Collision Detection
    func zombieHitCat(ball:SKSpriteNode){
        ball.name = "train"
        let group = SKAction.group([colorizeCat,ballCollisionSound])
        ball.runAction(SKAction.sequence([group,SKAction.runBlock({
            ball.removeAllActions()
            ball.setScale(1)
            ball.zRotation = 0
        })]))
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode){
        //enemy.removeFromParent()
        zombieIsActive = true
        let group = SKAction.group([enemyCollisionSound,blinkAction,colorizeRedZombie,SKAction.runBlock({
            self.loseBalls()
            self.lives--
        })])
        zombie.runAction(SKAction.sequence([group, SKAction.runBlock({
            self.zombieIsActive = false
            self.zombie.hidden = false
            }), colorizeNormalZombie
        ]))
        
        
        
    }
    
    func checkCollision(){
        
        if zombieIsActive == false {
            
            var hitBalls: [SKSpriteNode] = []
            enumerateChildNodesWithName("ball") { (node, _) -> Void in
                let ball = node as! SKSpriteNode
                if CGRectIntersectsRect(ball.frame, CGRectInset(self.zombie.frame,50,50)){
                    hitBalls.append(ball)
                }
            }
            
            for ball in hitBalls{
                zombieHitCat(ball)
            }
        
            var hitEnemies : [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { (node, _) -> Void in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(enemy.frame, 100, 100), self.zombie.frame){
                    hitEnemies.append(enemy)
                }
            }
            
            for enemy in hitEnemies{
                zombieHitEnemy(enemy)
            }
        
        }
        
    }
    
    
    func moveTrain(){
        
        //keep track of number of score in the line
        trainCount = 0
        
        var targetPosition = zombie.position
        var targetRotation = zombie.zRotation
        enumerateChildNodesWithName("train") { node, _ in
            self.trainCount++
            if !node.hasActions(){
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.zombieMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.zRotation = targetRotation
                
                // ball number is max 8 in train
                
                if self.trainCount < 6 {
                node.runAction(moveAction)
                }
            
            }
            targetPosition = node.position
            targetRotation = node.zRotation
        }
        
        
        //Game Over Scene - Won
//        if trainCount >= 15 && !gameOver {
//            gameOver = true
//            print("You Win!")
//            
//            let gameOverScene = GameOverScene(size : size, won: true)
//            
//            gameOverScene.scaleMode = scaleMode
//            
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            
//            view?.presentScene(gameOverScene, transition: reveal)
//        }

    }
    
    //Make the zombie lose two balls from his ball line
    
    func loseBalls(){
        
        //1 - tracking the number of balls removed from the conga line
        var loseCount = 0
        
        enumerateChildNodesWithName("train"){ node , stop in
            
            //2 - random offset from the balls current position
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100 , max : 100)
            randomSpot.y += CGFloat.random(min: -100 , max: 100)
            
            //3 - ball moved toward the random spot , spinning around and scaling to 0 .This animation removes the ball from the scene.
            
            //giving empty string to the removed node.
            node.name = ""
            node.runAction(SKAction.sequence([
                SKAction.group([SKAction.rotateByAngle(π*4, duration: 1.0),
                    SKAction.moveTo(randomSpot,duration: 1.0),
                    SKAction.scaleTo(0, duration: 1.0)
                    ]),
                SKAction.removeFromParent()
                ]))
            
            //4 - update the variable tracking the number off balls ramoved in ball line
            loseCount++
            
            if loseCount >= 2 {
                
                // Stop enumarating the ball line
                stop.memory  = true
            }
            
        }
    }

    
    //MARK: Text Label Methods
    func setLivesLabel(){
        
        //set the text to a placeholder
        livesLabel.text = "Lives: \(lives)"
        //set the color of the text
        livesLabel.fontColor = SKColor.blackColor()
        //set the font size
        livesLabel.fontSize = 100
        //set the label top of the scene
        livesLabel.zPosition = 100
        //label to stay in the same position, regardless of how the camera moves
        
        
        livesLabel.horizontalAlignmentMode = .Left
        livesLabel.verticalAlignmentMode = .Bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 - CGFloat(120))// (old comment )//overlapAmount()/2)//to resolve the camera behavior bug , also added overlapAmount()/2 to the y-axis
        
        
        //add the node as a child of the camera
        cameraNode.addChild(livesLabel)
        
    }
    
    
    func setScoreLabel(){
        
        //set the text to a placeholder
        scoreLabel.text = "Score: \(lives)"
        //set the color of the text
        scoreLabel.fontColor = SKColor.blackColor()
        //set the font size
        scoreLabel.fontSize = 100
        //set the label top of the scene
        scoreLabel.zPosition = 100
        //label to stay in the same position, regardless of how the camera moves
        
        /*
         Unlike SKSpriteNode, SKLabelNode doesn’t have an anchorPoint property. In its place, you can use the verticalAlignmentMode and horizontalAlignmentMode properties.
         The default alignment modes of SKLabelNode are Center for horizontal and Baseline for vertical.
         */
        
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.verticalAlignmentMode = .Bottom
        scoreLabel.position = CGPoint(
            x: +playableRect.size.width/2 - CGFloat(20),
            y: -playableRect.size.height/2 - CGFloat(120))// (old comment )//overlapAmount()/2)//to resolve the camera behavior bug , also added overlapAmount()/2 to the y-axis
        
        
        //add the node as a child of the camera
        cameraNode.addChild(scoreLabel)
        
    }
    
    func setHighScoreLabel(){
        
      let savedScore: Int = NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as! Int
        
        //set the text to a placeholder
        highScoreLabel.text = "High Score: \(savedScore)"
        //set the color of the text
        highScoreLabel.fontColor = SKColor.blackColor()
        //set the font size
        highScoreLabel.fontSize = 100
        //set the label top of the scene
        highScoreLabel.zPosition = 100
        //label to stay in the same position, regardless of how the camera moves
        
        
        highScoreLabel.horizontalAlignmentMode = .Right
        highScoreLabel.verticalAlignmentMode = .Bottom
        highScoreLabel.position = CGPoint(
            x: 400,
            y: -playableRect.size.height/2 - CGFloat(150))
        
        //add the node as a child of the camera
        cameraNode.addChild(highScoreLabel)
        
    }

    //MARK: Camera Methods
    
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0 }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        return scaledOverlap / scale
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y +
            overlapAmount()/2)
    }
    
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y -
            overlapAmount()/2)
    }
    
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        /*
         if part of the background is offscreen, you simply move the background node to the right by double the width of the background. Since there are two background nodes, this places the first node immediately to the right of the second.
         Result : continuously scrolling background!
        */
        enumerateChildNodesWithName("background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }
    
    
    //MARK: Background Sprites
    
    func backgroundNode() -> SKSpriteNode {
        // 1 - SKSpriteNode with no texture
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        // 2 -
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        // 3 - pin the bottom-left of the sprite to the bottom-right of background1 inside backgroundNode
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        return backgroundNode
    
    }
    
    
//MARK: - Touch Handling Methods
    func sceneTouched(touchLocation : CGPoint){
        
        moveZombieTowardTheTappedLocation(touchLocation)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else{
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
        
    }
}
