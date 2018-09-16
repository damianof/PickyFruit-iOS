//
//  GameMenuLevelFailedLayer.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/9/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameLevel;


@interface GameMenuLevelFailedLayer : CCLayer 
{
    GameLevel *_currentLevel;
    
    CCLayerColor *_levelGoalsLayer;
    float _spriteScaleForLevelGoalsLayer;
    float _levelGoalsLayerTotWidth;
    float _levelGoalsLayerTotHeight;
    
    int _counter;
    
    int _tagTouched;
    CCSprite *_spriteTouched;
}

//+(id)scene;
-(void)loadNextLevel;
-(void)loadMainMenu;
-(void)replayCurrentLevel;

@end
