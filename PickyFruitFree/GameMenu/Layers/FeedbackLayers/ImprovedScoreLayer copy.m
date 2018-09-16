//
//  ImprovedScoreLayer.m
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "ImprovedScoreLayer.h"

#define kImprovedScoreRoundText @"ImprovedScoreRound"

typedef enum{
    LevelImprovedScoreTagINVALID = 0,
    LevelImprovedScoreSprite,
    LevelImprovedScoreTagMAX
} LevelImprovedScoreTags;


@implementation ImprovedScoreLayer


-(CGSize)size
{
    return _size;
}

+(id)createWithColor:(ccColor4B)color
               delay:(float)delay
{
    return [[[self alloc] initWithColor:color
                                  delay:delay] autorelease];
}

-(id)initWithColor:(ccColor4B)color
             delay:(float)delay
{
    if((self = [super init]))
    {   
        _sprite = [CCSprite spriteWithSpriteFrameName:kImprovedScoreRoundText];
        _size = _sprite.boundingBox.size;
        //_container = [CCLayerColor layerWithColor:color
        //                                    width:_size.width 
        //                                   height:_size.height];
        //_container.isTouchEnabled = false;
        
        // add sprite
        _sprite.opacity = kInt0;
        _sprite.anchorPoint = cgzero;
        _sprite.position = cgzero;
        [self addChild:_sprite z:kInt0 tag:LevelImprovedScoreSprite];
        
        // add container
        //[self addChild:_container z:0 tag:0];
        
        _delay = delay;
        _elapsed = kFloat0;

        [self scheduleUpdate];
    }
    return self;

}

-(void)dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
	
    [self removeAllChildrenWithCleanup:YES];
   
    CCLOG(@"ImprovedScoreLayer dealloc");
    
    _sequenceAction = nil;
    //_container = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)dt 
{
    _elapsed += dt;
    
    if(_elapsed > _delay)
    {
        [self stopAllActions];
        [self unscheduleAllSelectors];
        _sprite.opacity = 255;
    }
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    CCLOG(@"ImprovedScoreLayer onExit");
    [super onExit];
}

@end
