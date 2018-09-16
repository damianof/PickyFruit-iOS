//
//  LevelPassedScoresLayer.m
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "LevelPassedScoresLayer.h"


typedef enum{
    LevelPassedScoresTagINVALID = 0,
    LevelPassedScoresTagLabelStatic,
    LevelPassedScoresTagLabelAnimated,
    LevelPassedScoresTagMAX
} LevelPassedScoresTags;


@implementation LevelPassedScoresLayer


//@synthesize 
//delegate = _delegate;

-(CGSize)size
{
    return _size;
}

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
          nextTarget:(id)nextTarget
          nextAction:(SEL)nextAction
    removeOnComplete:(bool)removeOnComplete
{
    return [[[self alloc] initWithColor:color
                                   size:size
                              labelText:text
                         scoreToAnimate:score
                              scoreBase:scoreBase
                                  delay:delay
                               fontSize:fontSize
                             nextTarget:nextTarget
                             nextAction:nextAction
                       removeOnComplete:removeOnComplete] autorelease];
}

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
        nextTarget:(id)nextTarget
        nextAction:(SEL)nextAction
  removeOnComplete:(bool)removeOnComplete
{
    if((self = [super init]))
    {   
        _removeOnComplete = removeOnComplete;
        
        _nextTarget = nextTarget;
        _nextAction = nextAction;
        /*_nextAction = nil;
        if(nextAction != nil)
        {
            _nextAction = [nextAction retain];
        }*/
        
        _size = size;
        _container = [CCLayerColor layerWithColor:color
                                            width:size.width 
                                           height:size.height];
        _container.isTouchEnabled = false;
        
        // add static label
        _labelStatic = [CCLabelTTF labelWithString:text //@"Fruit score: "
                                          fontName:@"Marker Felt"
                                          fontSize:fontSize];
        _labelStatic.opacity = 70;
        _labelStatic.anchorPoint = CGPointMake(0.0f, 0.0f);
        _labelStatic.position = cgzero;
        [_container addChild:_labelStatic z:0 tag:LevelPassedScoresTagLabelStatic];
        
        // add animated label
        _labelAnimated = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", 0]
                                            fontName:@"Marker Felt"
                                            fontSize:fontSize];
        _labelAnimated.opacity = 70;
        _labelAnimated.anchorPoint = CGPointMake(1.0f, 0.0f);
        _labelAnimated.position = CGPointMake(_size.width, 0);
        [_container addChild:_labelAnimated z:0 tag:LevelPassedScoresTagLabelAnimated];
        
        // add container
        [self addChild:_container z:0 tag:0];
        
        _score = score * scoreBase;
        _stepIncrement = _score * kOnePointFiveInverted; // (score / 1.5) to complete animation in 1.5 second
        _delay = delay;
        _elapsed = 0;
        
        // shift the label positions so 
        //_labelStatic.position = CGPointMake(self.contentSize.width*0.5, self.contentSize.height*0.5);
        
        id fadeIn = [CCFadeIn actionWithDuration:0.2f];
        id upd = [CCCallFunc actionWithTarget:self selector:@selector(scheduleUpdate)];
        id seq = [CCSequence actions:fadeIn, upd, nil];
        [self runAction:seq];
    }
    return self;

}

-(void)dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
   
    _sequenceAction = nil;
    
    //[_nextAction release];
    _nextTarget = nil;
    _nextAction = nil;
    
    //_delegate = nil;
    _container = nil;
    _labelStatic = nil;
    _labelAnimated = nil;
    
    [super dealloc];
}

-(void)onEnterTransitionDidFinish
{
    //CCLOG(@"LevelPassedScoreLayer onEnterTransitionDidFinish");
    [super onEnterTransitionDidFinish];
}

- (void)update:(ccTime)dt 
{
    _elapsed += dt;
    
    if(_elapsed > _delay)
    {
        _labelStatic.opacity = 255;
        _labelAnimated.opacity = 255;
        
        int increment = _stepIncrement * dt;
        _scoreCounter += increment;
        
        //CCLOG(@"update elapsed %.2f delay %.2f scoreCounter %df _stepIncrement %.2f", _elapsed, _delay, _scoreCounter, _stepIncrement);
        
        if(_scoreCounter > _score || _score == 0)
        {
            _scoreCounter = _score;
            [self unscheduleAllSelectors];
            [self didCompleteAnimation];
            /*if(self.delegate)
            {
                [self.delegate didCompleteAnimation];
            }*/
        }
        
        [_labelAnimated setString:[NSString stringWithFormat:@"%d", _scoreCounter]];
    }
}

-(void)removeFromParent
{
    _removing = true;
    CCLOG(@"LevelPassedScoresLayer removeFromParent");
    [self removeFromParentAndCleanup:NO];
}

-(void)performNextAction
{
    if(_nextAction != nil)
    {
        [_nextTarget performSelector:_nextAction];
    }
}

-(void)didCompleteAnimation
{
    CCLOG(@"LevelPassedScoresLayer didCompleteAnimation [%@]", _labelStatic.string);
    
    [_labelAnimated setString:@"Remove"];
    
    if(_removeOnComplete)
    {
        id wait = [CCDelayTime actionWithDuration:0.3f]; // wait a little so that user can see score
        //id fadeOut = [CCFadeOut actionWithDuration:0.1f]; // fade out
        id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeFromParent)];
        
        if(_nextAction != nil)
        {
            id next = [CCCallFunc actionWithTarget:self selector:@selector(performNextAction)];
            _sequenceAction = [CCSequence actions:wait, next, remove, nil];
        }
        else
        {
            _sequenceAction = [CCSequence actions:wait, remove, nil];
        }
        
        [self runAction:_sequenceAction];

    }
    else if(_nextAction != nil)
    {
        id next = [CCCallFunc actionWithTarget:self selector:@selector(performNextAction)];
        id wait = [CCDelayTime actionWithDuration:0.3f]; // wait a little so that user can see score

        if(_removeOnComplete)
        {
            id fadeOut = [CCFadeOut actionWithDuration:0.1f]; // fade out
            id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeFromParent)];
            _sequenceAction = [CCSequence actions:wait, fadeOut, next, remove, nil];
        }
        else
        {
            id next = [CCCallFunc actionWithTarget:_nextTarget selector:_nextAction];
            _sequenceAction = [CCSequence actions:wait, next, nil];
        }
        [self runAction:_sequenceAction];
    }
}

-(void)forceCompletionAndCleanup
{
    if (_removing == false) 
    {
        //[_nextAction release];
        _nextTarget = nil;
        _nextAction = nil;
        [self removeFromParent];
    }
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    _sequenceAction = nil;
    [super onExit];
    [self forceCompletionAndCleanup];
}

@end
