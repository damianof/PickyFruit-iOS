//
//  TruckNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "BodyNodeWithSprite.h"

#import "ActorProtocol.h"

@class ActorInfo;
@class ChainNode;
@class TruckWheelNode;


@interface TruckNode : BodyNodeWithSprite <ActorProtocol>//<CCTargetedTouchDelegate> 
{
    ActorInfo* _info;
    
    TruckWheelNode *_wheelBackNode;
    //TruckWheelNode *_wheelMiddleNode;
    TruckWheelNode *_wheelFrontNode;
    
    b2RevoluteJoint *_motorJoint;
    
    ChainNode *_truckChain;
    
    float _truckSpeed;
}

@property (nonatomic, retain) ActorInfo *info;
@property (nonatomic, readonly) b2RevoluteJoint *motorJoint;
@property (nonatomic, readonly) CGRect truckBedRect;

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(ActorInfo*)getInfoForChain;

-(void)updateMotorSpeed:(float)s;

@end
