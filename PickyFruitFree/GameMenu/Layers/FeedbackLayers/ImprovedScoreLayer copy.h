//
//  ImprovedScoreLayer.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface ImprovedScoreLayer : CCNode
{
    //CCLayerColor *_container;
    CCSprite *_sprite;
    
    CGSize _size;
    
    float _elapsed;
    float _delay;
    
    CCSequence *_sequenceAction;
}

@property (nonatomic, readonly) CGSize size;

+(id)createWithColor:(ccColor4B)color
               delay:(float)delay;

-(id)initWithColor:(ccColor4B)color
             delay:(float)delay;


@end
