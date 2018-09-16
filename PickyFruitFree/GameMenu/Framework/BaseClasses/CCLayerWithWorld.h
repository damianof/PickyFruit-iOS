//
//  CCLayerWithWorld.h
//
//  Created by Damiano Fusco on 4/4/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GB2ShapeCache.h"

#import "WorldSetup.h"
#import "DevicePositionHelper.h"

#import "ContactListenizer.h"
#import "ContactConduit.h"

#import "ParticleRain.h"

@class WorldHelper;
@class BodyNode;
@class BodyNodyWithSprite;
//@class UserInterfaceLayer;
@class GameGroup;
@class GameLevel;
@class ParallaxInfo;
@class StaticSpriteInfo;
@class ActorInfo;
@class JointInfo;
@class ParallaxNode;
@class FruitNode;
@class ChainNode;
//@class TruckNode;
@class TractorNode;
@class TreeSystemNode;
@class EnemySystemNode;
@class HorizCartNode;
@class VertCartNode;
@class ParallaxNode;


@interface CCLayerWithWorld : CCLayer <ContactListenizer>
{
	b2World* _world;
    b2Body* _groundBody;
    WorldSetup *_worldSetup;
    
    int32 _b2WorldVelocityIterations;
	int32 _b2WorldPositionIterations;    
    int32 _b2WorldSubsteps;
    uint _substepLoopCounter;
    
	GLESDebugDraw *_debugDraw;
    ContactConduit *_conduit;
    
    //NSMutableDictionary *_dictMouseJoints;
    UnitsSize _screenUnitsSize;
    float _unitInPoint;
    float _unitInBox2D;
    
    float _unitsYOffset; 
    float _unitsFromEdge;
    bool _drawUnitsGrid;
    
    std::vector<BodyNodeWithSprite*>_bodyNodesWithSpriteToDestroy;
    //std::vector<BodyNodeWithSprite*>_bodyNodesWithJointsToDestroy;

    // not sure this should be part of this base class
    float _timeBeforeHail;
    
    ParallaxNode *_parallaxNode;
    TreeSystemNode *_treeSystem;
    EnemySystemNode *_enemySystem;
    TractorNode *_tractorNode;
}

@property (nonatomic, readonly) b2World *world;
@property (nonatomic, readonly) b2Body *groundBody;

@property (nonatomic, readonly) ParallaxNode *parallaxNode;
@property (nonatomic, readonly) TreeSystemNode *treeSystem;
@property (nonatomic, readonly) EnemySystemNode *enemySystem;
@property (nonatomic, readonly) TractorNode *tractorNode;

-(void)stopEverything;

//-(void)setUILayer:(UserInterfaceLayer *)layer;
-(void)setDebugDraw:(bool)enabled;
-(void)createParallaxInWorld;
-(void)createTreeSystemInWorld;
-(void)createEnemySystemInWorld;
//-(void)createStaticSpritesInWorld;
-(void)createActorsInWorld;
-(void)createActorInWorld:(GameGroup *)gameGroup 
                actorInfo:(ActorInfo *)ai
          screenUnitsSize:(UnitsSize)sus;

-(void)performStepInWorld:(ccTime)dt;
-(UnitsPoint)unitsPointsRelativeToEdges:(UnitsPoint)up;
-(b2Vec2)b2Vec2RelativeToEdges:(UnitsPoint)up;

// to communicate actions to players through UI Layer
-(void)sendMessageToActorWithTag:(int)t 
                         message:(NSString *)m
                      floatValue:(float)fv
                     stringValue:(NSString *)sv;

// contact
-(void) onOverlapBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2;
-(void) onSeparateBody:(BodyNodeWithSprite *)bn1 
               andBody:(BodyNodeWithSprite *)bn2;
-(void) onCollideBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2 
            withForce:(float)f 
    withFrictionForce:(float)ff;

-(void)destroyBodyNodeWithSprite:(BodyNodeWithSprite *)bn;

@end
