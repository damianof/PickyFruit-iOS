//
//  GameLayer3.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import "cocos2d.h"
#import "CCLayerWithWorld.h"

@class StaticSpriteInfo;
@class GameGroup;


@interface GameLayerTest : CCLayerWithWorld 
{    
    CCNode *_enemiesLayer; // for testing
    NSMutableArray* _enemiesPool;
}

@end
