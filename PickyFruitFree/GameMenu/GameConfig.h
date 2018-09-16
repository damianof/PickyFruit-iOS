//
//  GameConfig.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright Shallow Waters Group LLC 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationUIViewController


// box2d config
#define kB2BoxWorldContinuousPhysics false
#define kB2BoxWorldVelocityIterations 4;
#define kB2BoxWorldPositionIterations 1;
#define kB2BoxWorldSubsteps 2;




#endif // __GAME_CONFIG_H