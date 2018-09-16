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

#import "cocos2d.h"
#import "Box2D.h"
#import "DevicePositionHelper.h"
#import "MathHelper.h"

#import "CCLayerWithWorld.h"

#import "TargetLayerEnum.h"
#import "GameManager.h"

#import "FruitNode.h"
#import "ChainNode.h"
#import "TruckNode.h"

//#import "EnemyNode.h"
#import "LightiningAnimationNode.h"

#import "ParticleRain.h"
#import "CollisionTypeEnum.h"
#import "ParticleSystemWithBox2D.h"

#import "GB2ShapeCache.h"
#import "FruitNodeForTree.h"


@class StaticSpriteInfo;
@class GameGroup;
@class VertCartNode;
@class TreeSystemNode;
@class ScrollingGround;


@interface GameLayer4 : CCLayerWithWorld 
{ 
    ParticleSystemWithBox2D *_hailSystem1;
    ParticleSystemWithBox2D *_hailSystem2;
    ParticleSystemWithBox2D *_hailSystem3;
    
    ScrollingGround *_scrollingGround;
    float _groundAndTruckSpeed;
}

+(id)scene;

-(LightiningAnimationNode *)addLightiningInRegion:(NSString *)n 
                                              tag:(int)t 
                                           region:(UnitsRect)ur;

-(void)activateHailSystem:(bool)active;
-(bool)updateHailSystemPosition:(ParticleSystemWithBox2D *)ps
                          delta:(ccTime)dt;
//-(void)countFruitSaved;

@end
