//
//  LevelPassedScoresLayer.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface LevelPassedScoresLayer : CCNode 
{
    CCLayerColor *_layerColor;
    CCSprite *_spriteImprovedScore;
    
    CCLabelBMFont *_labelStatic;
    CCLabelBMFont *_labelAnimated;
    CCLabelBMFont *_labelBonusStatic;
    CCLabelBMFont *_labelBonusAnimated;
    
    CGSize _size;
    
    float _elapsed;
    float _delay;
    float _stepIncrement;
    int _scoreCounter;
    int _score;
    
    float _elapsedForCounterSound;
    
    int _bonusScoreIncrement;
    float _bonusScoreSubStepCounter;
    
    int _bonusScoreCounter;
    int _bonusScore;
    
    bool _addImprovedScoreSprite;
    bool _hideOnComplete;
    
    int _prevLabelScoreValue;
    int _prevLabelBonusScoreValue;
}

@property (nonatomic, readonly) CGSize size;

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
      hideOnComplete:(bool)hideOnComplete;

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
      hideOnComplete:(bool)hideOnComplete
      bonusLabelText:(NSString*)bonusText
 bonusScoreToAnimate:(int)bonusScore
 addImprovedScoreSprite:(bool)addImprovedScoreSprite;

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
    hideOnComplete:(bool)hideOnComplete;

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
    hideOnComplete:(bool)hideOnComplete
    bonusLabelText:(NSString*)bonusText
bonusScoreToAnimate:(int)bonusScore
addImprovedScoreSprite:(bool)addImprovedScoreSprite;


@end
