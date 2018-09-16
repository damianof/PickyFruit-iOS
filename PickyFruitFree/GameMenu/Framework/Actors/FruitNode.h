//
//  Fruit.h
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "cocos2d.h"
//#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "BodyNodeWithSprite.h"

#import "ActorProtocol.h"

@class WorldHelper;
@class ActorInfo;


@interface FruitNode : BodyNodeWithSprite 
    //<ActorProtocol, CCTargetedTouchDelegate> 
    <CCTargetedTouchDelegate> 
{
}

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;


@end
