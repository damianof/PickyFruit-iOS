//
//  TrailerNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/1/2012.
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
@class TractorWheelNode;
@class TractorNode;


@interface TrailerNode : BodyNodeWithSprite <ActorProtocol>//<CCTargetedTouchDelegate> 
{
    ActorInfo* _info;
    
    TractorWheelNode *_wheelMiddleNode;
    
    ChainNode *_truckChain;
    
    float _truckSpeed;
    
    TractorNode *_tractorNode; // weak reference
    
    int _fruitsInTrailer;
    int _heightRows;
    float _height;
}

@property (nonatomic, retain) ActorInfo *info;
@property (nonatomic, readonly) CGRect trailerBedRect;
@property (nonatomic, readonly) TractorWheelNode *wheel;

-(void)setTractorNode:(TractorNode*)tn;

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(void)increaseFruitCount;
//-(ActorInfo*)getInfoForChain;

@end
