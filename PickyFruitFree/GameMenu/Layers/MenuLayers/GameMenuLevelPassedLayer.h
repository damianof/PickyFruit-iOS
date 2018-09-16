//
//  GameMenuLevelPassedLayer.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DevicePositionHelper.h"

@class GameLevel;
@class LevelPassedScoresLayer;
@class FruitSlotSpinnerSystem;


@interface GameMenuLevelPassedLayer : CCLayer 
{
    GameLevel *_currentLevel;
    
    LevelPassedScoresLayer *_starScoreLayer;
    LevelPassedScoresLayer *_timeScoreLayer;
    LevelPassedScoresLayer *_finalScoreLayer;
    
    CCLayerColor *_levelGoalsLayer; // to display the goals
    CCLayerColor *_levelStarsLayer; // to display the stars
    
    UnitsSize _screenUnitsSize;
    UnitsPoint _screenUnitsCenter;
    CGPoint _screenCenter;
    
    float _spriteScaleForLevelGoalsLayer;
    //float _levelGoalsLayerTotWidth;
    //float _levelGoalsLayerTotHeight;
    //FruitSlotSpinnerSystem *_fruitSlotSpinner;
    
    int _counter;
    
    int _tagTouched;
    CCSprite *_spriteTouched;
}

-(void)loadNextLevel;
-(void)loadMainMenu;
-(void)replayCurrentLevel;
-(void)setupLevelGoalsLayer;
-(void)setupLevelStarsLayer;

-(void)addStarScoreLayer;
-(void)addTimeScoreLayer;
-(void)addFinalScoreLayer;

@end
