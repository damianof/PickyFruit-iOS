//
//  GameLayer3.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

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

#import "EnemyNode.h"
#import "LightiningAnimationNode.h"

#import "ParticleRain.h"
#import "CollisionTypeEnum.h"
#import "ParticleSystemWithBox2D.h"

#import "GB2ShapeCache.h"

@class StaticSpriteInfo;
@class GameGroup;
@class VertCartNode;


@interface GameLayer3 : CCLayerWithWorld 
{ 
    /*ParticleSystemWithBox2D *_hailSystem1;
    ParticleSystemWithBox2D *_hailSystem2;
    ParticleSystemWithBox2D *_hailSystem3;*/
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
