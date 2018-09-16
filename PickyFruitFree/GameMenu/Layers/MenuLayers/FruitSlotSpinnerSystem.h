//
//  FruitSlotSpinnerSystem.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class FruitSlotSpinner;


@interface FruitSlotSpinnerSystem : CCLayerColor
{
    //CCCallFunc *_nextAction;
    id _nextTarget;
    SEL _nextAction;
    
    int _numberOfSpinners;    
    int _numberOfSprites;
    
    float _timeout;
    
    float _timeElapsed;
    
    float _elapsedForCounterSound;
    
    int _cellWidth;
    int _gap;
    int _cellHalfWidth;
    
    CCSequence *_sequenceAction;
}

@property (nonatomic, readonly) int cellWidth;
@property (nonatomic, readonly) int cellHalfWidth;
@property (nonatomic, readonly) int gap;
@property (nonatomic, readonly) bool allTargetsReached;

+(id)createWithLevelGoals:(NSArray*)levelGoals
                  timeout:(float)timeout
               nextTarget:(id)nextTarget
               nextAction:(SEL)nextAction;

-(id)initWithLevelGoals:(NSArray*)levelGoals
                timeout:(float)timeout
             nextTarget:(id)nextTarget
             nextAction:(SEL)nextAction;

//+(id)createWithNumberOfSpinners:(int)nos;
//-(id)initWithNumberOfSpinners:(int)nos;

-(void)randomSpin:(float)dt;
-(void)goToTargetsAndStop;
-(void)runNextAction;


@end
