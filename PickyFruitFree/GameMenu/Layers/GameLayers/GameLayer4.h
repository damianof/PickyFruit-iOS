//
//  GameLayer4.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/17/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
// This is the same as GameLayer3 but with the parallax

//#import <Foundation/Foundation.h>
//#import <vector>

#import "CCLayerWithWorld.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "DevicePositionHelper.h"
#import "MathHelper.h"
#import "TargetLayerEnum.h"
#import "GameManager.h"
//#import "LightiningAnimationNode.h"

#import "CollisionTypeEnum.h"
#import "FruitNodeForTree.h"

@class StaticSpriteInfo;
@class GameGroup;
@class VertCartNode;
@class TreeSystemNode;
@class ScrollingGround;
@class ScrollingHills;

@interface GameLayer4 : CCLayerWithWorld 
{    
    ScrollingHills *_scrollingGround;
    float _groundAndTruckSpeed;
}

/*
-(LightiningAnimationNode *)addLightiningInRegion:(NSString *)n 
                                              tag:(int)t 
                                           region:(UnitsRect)ur;

-(void)activateHailSystem:(bool)active;
-(bool)updateHailSystemPosition:(ParticleSystemWithBox2D *)ps
                          delta:(ccTime)dt;
*/

@end
