//
//  LevelPassedScoresLayer.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


//@protocol AnimationCompleteDelegate
//- (void)didCompleteAnimation;
//@end


@interface LevelPassedScoresLayer : CCNode //<AnimationCompleteDelegate>
{
    //id <AnimationCompleteDelegate> _delegate;
    //CCCallFunc *_nextAction;
    id _nextTarget;
    SEL _nextAction;

    CCLayerColor *_container;
    CCLabelTTF *_labelStatic;
    CCLabelTTF *_labelAnimated;
    
    CGSize _size;
    
    float _elapsed;
    float _delay;
    float _stepIncrement;
    int _scoreCounter;
    int _score;
    
    bool _removeOnComplete;
    bool _removing;
    
    CCSequence *_sequenceAction;
}

//@property (nonatomic, assign) id <AnimationCompleteDelegate> delegate;
@property (nonatomic, readonly) CGSize size;

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
          nextTarget:(id)nextTarget
          nextAction:(SEL)nextAction
    removeOnComplete:(bool)removeOnComplete;

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
        nextTarget:(id)nextTarget
        nextAction:(SEL)nextAction
  removeOnComplete:(bool)removeOnComplete;

-(void)didCompleteAnimation;
-(void)performNextAction;


@end
