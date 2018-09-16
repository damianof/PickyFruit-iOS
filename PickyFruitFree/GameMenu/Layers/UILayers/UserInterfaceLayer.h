//
//  UserInterfaceLayer.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "DevicePositionHelper.h"
#import "FruitMessageEnum.h"
#import "GameManager.h"

@class LevelGoal;


@interface UserInterfaceLayer : CCLayerColor <GameManagerDelegate>// CCLayerColor 
{
    //CGPoint _lastTouchLocation;
    int _tagOfPressedButton;
    
    UnitsSize _screenUnitsSize;
    bool _drawUnitsGrid;
    
    float _truckSpeed;
    float _truckPrevSpeed;
    float _truckSpeedIncrement;
    
    CCLayerColor *_levelGoalsLayer;
    ccColor3B _labelGoalNumberColor;
    bool _goalsLayerOnRightSide;
    float _spriteScaleForLevelGoalsLayer;
    float _spriteGoalY;
    float _levelGoalsLayerTotWidth;
    float _levelGoalsLayerTotHeight;
    
    CCMenuItemSprite *_truckBackMenuItem;
    CCMenuItemSprite *_truckFwdMenuItem;
    
    CCLabelBMFont *_labelTimeStatic;
    CCLabelBMFont *_labelTimeElapsed;
    CCLabelBMFont *_labelLivesStatic;
    CCLabelBMFont *_labelLivesRemaining;
    CCLabelBMFont *_labelBonusRemaining;
    
    float _prevLabelTimeElapsedValue;
    int _prevLabelBonusValue;
    
    float _timeElapsed;
    float _elapsedForHighTimeBlink;
    float _elapsedForLowLivesBlink;
    int _livesRemain;
}

//@property (nonatomic, readonly) CCLayer *gameLayer;

//+(id)scene;

//-(void)sendMessageToLabelWithTag:(int)tag 
//                         message:(NSString *)m;

-(void)setupLevelGoalsLayer;
-(void)receiveFruitMessage:(FruitMessageEnum)message
                 fruitName:(NSString*)fruitName
                      goal:(LevelGoal*)goal;

-(void)buttonBackTapped:(id)sender;
-(void)buttonReplayTapped:(id)sender;
-(void)buttonDebugDrawTapped:(id)sender;

-(void)buttonTruckBackTapped:(id)sender;
-(void)buttonTruckForwardTapped:(id)sender;

@end
