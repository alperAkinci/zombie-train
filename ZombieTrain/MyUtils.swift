//
//  MyUtils.swift
//  ZombieTrain
//
//  Created by Alper on 08/03/16.
//  Copyright © 2016 allperr. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

// Variables

var backgroundMusicplayer : AVAudioPlayer?

//Overloading Functions


//CGPoint add,subtract,multiply,divide operation
func + (left : CGPoint , right : CGPoint)-> CGPoint{
    return CGPoint(x:left.x + right.x , y: left.y + right.y)
}

/*
    In-Out Paramaters :
     -If you want a function to modify a parameter’s value, and you want those changes to persist after the function call has ended, define that parameter as an in-out parameter instead.
*/
func - (left : CGPoint , right : CGPoint)-> CGPoint{
    return CGPoint(x:left.x - right.x , y: left.y - right.y)
}

func * (left : CGPoint , right : CGPoint)-> CGPoint{
    return CGPoint(x:left.x * right.x , y: left.y * right.y)
}

func / (left : CGPoint , right : CGPoint)-> CGPoint{
    return CGPoint(x:left.x / right.x , y: left.y / right.y)
}


//CGPoint add,subtract,multiply,divide assignment
func += (inout left : CGPoint , right : CGPoint){
    left = left + right
}
func -= (inout left : CGPoint , right : CGPoint){
    left = left - right
}
func *= (inout left : CGPoint , right : CGPoint){
    left = left * right
}
func /= (inout left : CGPoint , right : CGPoint){
    left = left / right
}


//CGPoint , CGFLoat scalar operations
func * (left : CGPoint , scalar : CGFloat)-> CGPoint{
    return CGPoint(x:left.x * scalar , y: left.y * scalar)
}
func / (left : CGPoint , scalar : CGFloat)-> CGPoint{
    return CGPoint(x:left.x / scalar , y: left.y / scalar)
}
func *= (inout left : CGPoint , scalar : CGFloat){
    left = left * scalar
}
func /= (inout left : CGPoint , scalar : CGFloat){
    left = left / scalar
}


//This block is true when the app is running on 32bit architecture
#if !(arch(x86_64) || arch(arm64))
    
    //This allows us to use atan2 and sqrt with CGFLoats , regardless of the devices architecture
    func atan2(y : CGFloat , x: CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y),Float(x)))
    }
    
    func sqrt(a:CGFloat)-> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif




let π = CGFloat(M_PI) // 3.14

func shortestAngleBetween(angle1:CGFloat , angle2: CGFloat) -> CGFloat{
    let twoπ = π * 2.0
    var angle = (angle2 - angle1) % twoπ
    
    if (angle >= π){
        angle = angle - twoπ
    }
    if (angle <= -π){
        angle = angle + twoπ
    }
    
    return angle
}


//MARK: - Extensions

extension CGPoint{
    func length()->CGFloat{
        return sqrt((x*x)+(y*y))
    }
    
    func normalized()->CGPoint{
        return self / length()
    }
    
    var angle:CGFloat {
        return atan2(y,x)
    }
}

extension CGFloat{
    func sign()->CGFloat{
        return (self >= 0.0) ? 1.0 : -1.0
    }
    
    //Generates Random Number between 1-0
    static func random() -> CGFloat {
        // arc4random() -> gives random integer between 0 and the largest value of unsigned 32-bit integer
        return CGFloat(Float(arc4random()) / Float(UInt32.max))//0-1 float
    }
    
    //Generates Random Number between specified Min - Max Values
    static func random(min min: CGFloat , max:CGFloat)->CGFloat{
        assert(min<max)
        return CGFloat.random() * (max - min) + min
    }
}


func playBackgroundMusic(fileName : String)  {
    
    let resourceURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: nil)
    
    guard let url = resourceURL else {
        
        print("Could not find the file : \(fileName)")
        return
    
    }
    
    do{
        //AVAudioPlayer to play some background music
        try backgroundMusicplayer  = AVAudioPlayer(contentsOfURL: url)
        backgroundMusicplayer?.numberOfLoops = -1 //plays in an endless loop
        backgroundMusicplayer?.prepareToPlay()
        backgroundMusicplayer?.play()
    
    } catch {
        print ("Could not create Audio Player!")
        return
    }
    
}











