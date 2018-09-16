//
//  FruitNodeForTree.h
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "Box2D.h"
#import "RottenStateEnum.h"
#import "ExplosionStateEnum.h"
#import "OutsideScreenEnum.h"
#import "GB2ShapeCache.h"
#import "BodyNodeWithSprite.h"
#import "ActorProtocol.h"

@class ActorInfo;
@class TreeSystemNode;
@class FruitSlotInfo;


@interface FruitNodeForTree : BodyNodeWithSprite 
    <ActorProtocol, CCTargetedTouchDelegate> 
{
    ActorInfo* _info;
    
    bool _isClone;
    bool _hasClone;
    bool _inTruck;
    //bool _touchesOtherFruitInTruck;
    RottenStateEnum _rottenState;
    ExplosionStateEnum _explosionState;
    
    int _parentTreeTag;
    // loose references
    TreeSystemNode *_treeSystemNode;
    FruitSlotInfo *_fruitSlotInfo;
}

@property (nonatomic, retain) ActorInfo *info;
@property (nonatomic, readwrite) bool isClone;
@property (nonatomic, readwrite) bool hasClone;
@property (nonatomic, readwrite) bool inTruck;
@property (nonatomic, readwrite) int parentTreeTag;
@property (nonatomic, assign) RottenStateEnum rottenState;
@property (nonatomic, assign) ExplosionStateEnum explosionState;

+(id)createWithLayer:(CCLayerWithWorld*)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld*)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(void)setTreeSystemNode:(TreeSystemNode*)tsn;
-(void)setSlotInfo:(FruitSlotInfo *)si;
-(int)checkIfInTrailer;


@end
