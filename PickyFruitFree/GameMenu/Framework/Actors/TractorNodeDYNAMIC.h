//
//  TractorNode.h
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
@class TractorDriverNode;
@class TrailerNode;
@class FruitNodeForTree;


@interface TractorNode : BodyNodeWithSprite <ActorProtocol>//<CCTargetedTouchDelegate> 
{
    ActorInfo* _info;
    
    TractorWheelNode *_wheelBackNode;
    TractorWheelNode *_wheelFrontNode;
    TractorDriverNode *_driverNode;
    
    b2RevoluteJoint *_motorJoint;
    
    float _tractorSpeed;
    int _screenWidth;
    
   // NSMutableArray *_trailerNodes;
    int _numberOfTrailers;
}

@property (nonatomic, retain) ActorInfo *info;
@property (nonatomic, readonly) b2RevoluteJoint *motorJoint;
@property (nonatomic, assign) int numberOfTrailers;

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(ActorInfo*)getInfoForTrailer:(int)trailerTag;
-(void)addTrailerWithTag:(int)trailerTag;

-(int)checkIfFruitIsInTrailer:(FruitNodeForTree*)fruit;

-(void)updateMotorSpeed:(float)s;

@end
