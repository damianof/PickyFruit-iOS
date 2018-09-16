//
//  ChainNode.h
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "cocos2d.h"
//#import "Box2D.h"
#import "BodyNodeWithSprite.h"
#import "ActorProtocol.h"

@class ActorInfo;
@class BodyNode;
@class ChainRingNode;


@interface ChainNode : BodyNodeWithSprite <ActorProtocol>//<CCTargetedTouchDelegate>
{
    ActorInfo* _info;
    
    b2Vec2 _endRingPosition;
    int _rings;
    bool _isLoose;
    bool _created;

    BodyNode *_firstBodyNode;
    BodyNode *_lastBodyNode;
    BodyNode *_staticBodyNode;
}

@property (nonatomic, readonly) BodyNode *firstBodyNode;
@property (nonatomic, readonly) BodyNode *lastBodyNode;
@property (nonatomic, readonly) BodyNode *staticBodyNode;

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(void)setNumberOfRings:(int)r
                isLoose:(bool)il
        endRingPosition:(b2Vec2)erp;

-(void)createChainRings;

@end

