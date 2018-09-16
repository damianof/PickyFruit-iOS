//
//  TreeNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/17/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "Box2D.h"
#import "BodyNodeWithSprite.h"

@class CCLayerWithWorld;
@class TreeSystemNode;
@class MathHelper;
@class FruitNodeForTree;
@class ActorInfo;
@class TreeInfo;
@class FruitSlotInfo;

@interface TreeNode : BodyNodeWithSprite
{
    TreeSystemNode *_treeSystemNode;
    TreeInfo *_info;
        
    float _elapsed;
    float _speed;
    bool _fruitCreated;
    
    CCArray* _fruitSlots;
    int _maxFruitSlots;
    int _fruitSlotsRecursionCounter;
}

@property (nonatomic, retain) TreeInfo *info;
@property (nonatomic, readwrite) float speed;
@property (nonatomic, readwrite) bool fruitCreated;

+(id)createWithLayer:(CCLayerWithWorld*)layer
            treeInfo:(TreeInfo*)treeInfo
            position:(b2Vec2)p;

-(id)initWithLayer:(CCLayerWithWorld*)layer
          treeInfo:(TreeInfo*)treeInfo
          position:(b2Vec2)p;

-(void)setTreeSystemNode:(TreeSystemNode*)tsn;

-(void)removeBodies;
-(FruitSlotInfo*)getRandomFruitSlot;
-(void)resetSlots;

@end
