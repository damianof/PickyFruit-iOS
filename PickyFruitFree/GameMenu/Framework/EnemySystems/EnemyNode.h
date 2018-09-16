//
//  EnemyNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "cocos2d.h"
#import "BodyNodeWithSprite.h"
#import "ActorProtocol.h"
#import "DeadStateEnum.h"

@class ActorInfo;
@class WorldHelper;
@class EnemySystemNode;

@protocol EnemyDelegate
- (void)enemyDied:(id)enemy;
@end


@interface EnemyNode : BodyNodeWithSprite <ActorProtocol, CCTargetedTouchDelegate> 
{
    id <EnemyDelegate> _delegate;
    ActorInfo* _info;
    DeadStateEnum _deadState;
}

@property (nonatomic, assign) id <EnemyDelegate> delegate;
@property (nonatomic, retain) ActorInfo *info;
@property (nonatomic, readonly) bool isDying;
@property (nonatomic, readonly) DeadStateEnum deadState;

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

//-(void)moveWings;
//-(void)moveAntennas;
-(void)squish;


@end
