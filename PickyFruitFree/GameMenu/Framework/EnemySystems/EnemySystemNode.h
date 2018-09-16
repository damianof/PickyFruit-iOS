//
//  EnemySystemNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/26/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "EnemyNode.h"

@class CCLayerWithWorld;
@class EnemySystemInfo;


@interface EnemySystemNode : CCNode <EnemyDelegate>
{
    CCLayerWithWorld *_layer;
    EnemySystemInfo *_info;
    
    CCRepeatForever *_repeatForever;
    
    b2Vec2 _screenB2Vec2Size;
    b2Vec2 _screenB2Vec2Center;
    
    bool _modifyingPool;
    
    int _emittedCount;
    int _poolLoopIndex;
}

@property (nonatomic, retain) EnemySystemInfo *info;
@property (nonatomic, readonly) bool canEmit;

+(id)createWithLayer:(CCLayerWithWorld*)layer
     enemySystemInfo:(EnemySystemInfo*)esi;

-(id)initWithLayer:(CCLayerWithWorld*)layer
   enemySystemInfo:(EnemySystemInfo*)esi;

-(void)emitEnemies; //:(ccTime)dt;
-(void)updateEnemyPosition:(ccTime)dt;
-(void)startRepeatForever;

@end
