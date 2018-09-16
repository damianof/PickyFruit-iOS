//
//  GameLayer3.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameLayerTest.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "UserInterfaceLayer.h"
#import "GameGroup.h"
#import "StaticSpriteInfo.h"
#import "HorizCartNode.h"
#import "VertCartNode.h"
#import "RotatingCartNode.h"
#import "EnemyNode.h"

#import "DevicePositionHelper.h"
#import "MathHelper.h"
#import "TargetLayerEnum.h"
#import "GameManager.h"
#import "FruitNode.h"
#import "ChainNode.h"
#import "TruckNode.h"

#import "CollisionTypeEnum.h"

#import "GameConfigTests.h" // for testing


@implementation GameLayerTest

-(id) init
{
	if((self=[super init])) 
    {
        /*[self setDebugDraw:true];
        _drawUnitsGrid = true;
        
        _timeBeforeHail = [GameManager currentGameGroup].timeBeforeHail;*/
        
        // save reference to truck actor for convenience
        //_truckNode = (TruckNode *)[self getChildByTag:kActorTagTruck];
        
        /*
         <Actor Type="TruckNode" Tag="59111" Z="2" SpriteFramesFile="xyz.plist" VerticesFile="TruckVertices.plist" FrameName="Truck" AnchorPoint="{0,0}" Position="{29,0}" PositionFromTop="false"  CollisionType="CollisionTypeTruck" MakeDynamic="true">
         <Joint With="Ground" Type="Prismatic" WorldAxis="{1,0}"/>
         <CollidesWith Value="CollisionTypeFruit"/>
         <MaskBits Value="CollisionTypeALL"/>
         <MaskBits Value="~CollisionTypeTruckWheel"/>
         </Actor>
        */
        
        //b2Vec2 b2Vec2Position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(8.5, 5.5)];
        
        //_fruitRegion = UnitsRectMake(_unitsFromEdge+6, _unitsYOffset+16, 18, 12);
        
        /*_truckNode = [TruckNode createWithWorld:_world
                                     groundBody:_groundBody
                                    anchorPoint:CGPointMake(0, 0)
                                       position:b2Vec2Position  
                                            tag:59111
                                           name:@"Truck"
                                  collisionType:CollisionTypeTruck
                               collidesWithType:(CollisionTypeFruit | CollisionTypeHail)
                                       maskBits:(CollisionTypeALL 
                                                 & ~CollisionTypeWorldRight
                                                 & ~CollisionTypeTruck)];
        
        [_truckNode createBody];
        b2PrismaticJointDef pjd;
        b2Vec2 worldAxis(1.0f, 0.0f);
        pjd.Initialize(_truckNode.body, _groundBody, _truckNode.body->GetWorldCenter(), worldAxis);
        [self addChild:_truckNode z:2 tag:59111];
        [_truckNode makeDynamic];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"Obstacles.plist"];
        CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"ObstacleWall"];
        
        // hard coded anchor point
        CGPoint anchorPoint = CGPointMake(0,0);
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"ObstaclesVertices.plist"
                                                       size:[s boundingBox].size
                                                     anchor:anchorPoint];
        [s setAnchorPoint:anchorPoint];

        b2Vec2Position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(3.5, 5.5)];
        BodyNodeWithSprite *bodyNode = [BodyNodeWithSprite createWithWorld:_world
                                                                groundBody:_groundBody
                                                               anchorPoint:anchorPoint
                                                                  position:b2Vec2Position 
                                                                    sprite:s 
                                                           spriteFrameName:@"ObstacleWall"
                                                                       tag:3334
                                                                fixtureDef:nil
                                                                     shape:nil];
        //bodyNode.collisionType = CollisionTypeObstacleWall;
        //bodyNode.collidesWithType = actorInfo.collidesWithType;
        bodyNode.maskBits = CollisionTypeALL;
        
        // add fixtures to body
        [bodyNode onEnter];
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:bodyNode.body 
                                               forShapeName:@"ObstacleWall"
                                       overrideCategoryBits:bodyNode.collisionType 
                                           overrideMaskBits:bodyNode.maskBits];
        
        [self addChild:bodyNode z:1 tag:3334];
        [bodyNode makeDynamic];
*/
        
        //int t = kActorTagFruit;
        // add the fixture definitions to the body
        // add fruits:
        //[self addFruitInRegion:@"AppleGreen-32" tag:t++ region:_fruitRegion];
        //[self addFruitInRegion:@"Banana-32" tag:t++ region:_fruitRegion];
        //[self addFruitInRegion:@"Cherries-32" tag:t++ region:_fruitRegion];
        //[self addFruitInRegion:@"AppleRed-32" tag:t++ region:_fruitRegion];
        
        // add chains:
        /*UnitsPoint up = UnitsPointMake(11, 22);
        [self addChain:@"ChainRingB-32"
                 rings:3
                   tag:t++ 
              location:up
               isLoose:false
                     z:1];*/
        
        // test enemy
        /*_enemiesPool = [[NSMutableArray arrayWithCapacity:30] retain];
        _enemiesLayer = [[CCNode alloc] init];
        [self addChild:_enemiesLayer z:1000 tag:7987001];
        
        ActorInfo *enemyInfo1 = [GameConfigTests enemyNodeInfo:@"BugAnimation0"
                                                framesFileName:@"BugAnimation.plist"
                                                   imageFormat:@"png"];
        ActorInfo *enemyInfo2 = [GameConfigTests enemyNodeInfo:@"BugAnimation0"
                                                framesFileName:@"BugAnimation.plist"
                                                   imageFormat:@"png"];
        //b2Vec2 enemyInitialPosition = [DevicePositionHelper b2Vec2FromUnitsPoint:enemyInfo.unitsPosition];
        b2Vec2 enemyInitialPosition = [DevicePositionHelper screenB2Vec2Center];
        
        EnemyNode *enemy1 = [EnemyNode createWithLayer:self
                                                                info:enemyInfo1
                                                     initialPosition:enemyInitialPosition];
        enemy1.sprite.opacity = 0;
        [_enemiesPool addObject:enemy1];
        
        enemyInitialPosition = b2Vec2(enemyInitialPosition.x+5, enemyInitialPosition.y+5);
        EnemyNode *enemy2 = [EnemyNode createWithLayer:self
                                                                info:enemyInfo2
                                                     initialPosition:enemyInitialPosition];
        enemy2.sprite.opacity = 0;
        [_enemiesPool addObject:enemy2];
        
        //[_enemiesLayer addChild:enemy z:enemy.info.z tag:enemy.info.tag];

        
        [self schedule: @selector(performStepInWorld:)];*/
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"GameLayerTest dealloc");
    [super dealloc];
}
/*
-(void)onEnter
{
    //CCLOG(@"GameLayerTest onEnter");
    [super onEnter];
    
    //ActorInfo *enemyInfo = [GameConfigTests EnemyNodeInfo];
    //EnemyNode *enemy = (EnemyNode*)[_enemiesLayer getChildByTag:enemyInfo.tag];
    //[enemy makeDynamic];
    
    for(EnemyNode *enemy in _enemiesPool)
    {
        [_enemiesLayer addChild:enemy z:enemy.info.z tag:enemy.info.tag];
        [enemy makeKinematic];
        //[enemy makeDynamic];
        
        // show it
        enemy.sprite.opacity = 255;
    }
}

-(void)onExit
{
    //CCLOG(@"GameLayerTest onExit");
    
    [super onExit];
}

-(void)performStepInWorld:(ccTime)dt
{
    [super performStepInWorld:dt];
}
*/
/*
-(void)draw
{
    [super draw];
    
    // draw a ine to show where the fruit region is
    glLineWidth(1.0f);
    glColor4f(1.0, 0, 0, 0.1);  
    CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:_fruitRegion.origin];
    CGSize sz = [DevicePositionHelper sizeFromUnitsSize:_fruitRegion.size];
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
}
*/
/*
-(void)sendMessageToActorWithTag:(int)t 
                         message:(NSString *)m
                      floatValue:(float)fv
                     stringValue:(NSString *)sv
{
    [super sendMessageToActorWithTag:t 
                             message:m 
                          floatValue:fv 
                         stringValue:sv];
    
    //
}
*/
-(void)createActorsInWorld
{
    [super createActorsInWorld];
    
    UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    
    // extend ground bottom on the right so that truck can go away on the right
    b2Vec2 pointA = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(0,0)];
    b2Vec2 pointB = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(screenUnitsSize.width*1.5f,0)];
    b2Vec2 pointC = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(screenUnitsSize.width*1.5f,1)];
    b2Vec2 pointD = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(0,1)];
    
    int numVertices = 4;
    b2Vec2 vertices[] = {
        pointA,
        pointB,
        pointC,
        pointD,
    };
    UnitsPoint up = UnitsPointMake(4,4);
    [_worldSetup createStaticBodyWithVertices:vertices 
                                  numVertices:numVertices 
                                unitsPosition:up];
    
    // HorizCartNode
    /*int px = 13;
    int py = 15;
    UnitsBounds unitsBounds = UnitsBoundsMake(px, 23);
    uint16 maskBits = CollisionTypeALL
        & ~CollisionTypeTruck
        & ~CollisionTypeChain;
    b2Vec2 b2Vec2position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(px, py+_unitsYOffset)]; 
    HorizCartNode *horizCartNode = [HorizCartNode createWithWorld:self.world
                                                       groundBody:self.groundBody
                                                      anchorPoint:CGPointMake(0, 0)
                                                         position:b2Vec2position  
                                                              tag:543 
                                                             name:@"ObstacleCart2"
                                                    collisionType:CollisionTypeObstacleHCart
                                                 collidesWithType:CollisionTypeFruit
                                                         maskBits:maskBits
                                                      unitsBounds:unitsBounds];
    [horizCartNode createBody];
    */
    /*b2PrismaticJointDef hpjd;
    b2Vec2 worldAxis = b2Vec2(1.0f, 0.0f);
    b2Body *with = NULL;
    //if([jointInfo.joinWith isEqualToString:@"Ground"])
    {
        with = _groundBody;
    }
    //hpjd.lowerTranslation = -horizCartNode.bounds.lower();
    //hpjd.upperTranslation = horizCartNode.bounds.upper();
    hpjd.enableLimit = false;
    hpjd.Initialize(horizCartNode.body, with, horizCartNode.body->GetWorldCenter(), worldAxis);
    //pjd.Initialize(cartNode.body, with, b2Vec2(0,0), worldAxis);
    _world->CreateJoint(&hpjd);*/
    /*[self addChild:horizCartNode z:0 tag:543];
    [horizCartNode makeKinematic];
    */
    
    // ObstacleRotating4
    // RotatingCartNode
    /*uint16 maskBits = CollisionTypeALL
    & ~CollisionTypeTruck
    & ~CollisionTypeChain;
    //b2Vec2 b2Vec2position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(px, py+_unitsYOffset)]; 
    
    CGPoint ap = CGPointMake(0.5f, 0.5f);
    up = UnitsPointMake(13, 15+_unitsYOffset);
    UnitsBounds ub = UnitsBoundsMake(0,0); //UnitsBoundsFromString(ubStr);
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:@"RotatingCartNode"
                                                     tag:643
                                                       z:0
                                        spriteFramesFile:@"Obstacles.plist"
                                               frameName:@"ObstacleRotating4" 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:false
                                                   angle:0
                                             unitsBounds:ub];
    
    //actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = false;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = CollisionTypeObstacleHCart;
    actorInfo.collidesWithTypes = CollisionTypeFruit;
    actorInfo.maskBits = maskBits;
    
    b2Vec2 ip = [DevicePositionHelper b2Vec2FromUnitsPoint:up]; 
    RotatingCartNode *rotatingCartNode = [RotatingCartNode createWithLayer:self
                                                                      info:actorInfo
                                                           initialPosition:ip];
    [rotatingCartNode createBody];
    [self addChild:rotatingCartNode z:0 tag:643];
    [rotatingCartNode makeKinematic];*/
    
    /*// VertCartNode
    px = 20;
    py = 12;
    int topBounds = py + _unitsYOffset;
    int bottomBounds = py + _unitsYOffset - 7;
    unitsBounds = UnitsBoundsMake(topBounds, bottomBounds);
    b2Vec2position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(px, py+_unitsYOffset)]; 
    VertCartNode *vertCartNode = [VertCartNode createWithWorld:self.world
                                                    groundBody:self.groundBody
                                                   anchorPoint:CGPointMake(0, 0)
                                                      position:b2Vec2position  
                                                           tag:544 
                                                          name:@"ObstacleCart2"
                                                 collisionType:CollisionTypeObstacleHCart
                                              collidesWithType:CollisionTypeFruit
                                                      maskBits:maskBits
                                                   unitsBounds:unitsBounds];
    
    [vertCartNode createBody];
    [self addChild:vertCartNode z:0 tag:544];
    [vertCartNode makeKinematic];*/
}

-(void) onOverlapBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2
{
	// check if two boxes have started to overlap
	if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits have overlapped. Cool.");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccRED;
            //bn2.sprite.color = ccRED;
        }
	}
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn1 
               andBody:(BodyNodeWithSprite *)bn2
{
	// check if two boxes are no longer overlapping
	if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits stopped overlapping. That's okay too.");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccWHITE;
            //bn2.sprite.color = ccWHITE;
        }
	}
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2 
            withForce:(float)f 
    withFrictionForce:(float)ff
{
	// check if two boxes have collided in the last update
	if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits have collided, yay!");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccYELLOW;
            //bn2.sprite.color = ccBLUE;
        }
	}
    
    // explode fruit on contact with Hail
    BodyNodeWithSprite *fruitCollided = NULL;
    if (bn1.collisionType == CollisionTypeHail 
        && 
        bn2.collisionType == CollisionTypeFruit)
    {
        fruitCollided = bn2;
    }
    else if (bn2.collisionType == CollisionTypeHail 
             && 
             bn1.collisionType == CollisionTypeFruit)
    {
        fruitCollided = bn1;
    }
    
    if (fruitCollided)
    {
		//CCLOG(@"Hail has collided with a fruit!");
        if(fruitCollided.sprite)
        {
            CCParticleSystemQuad *expl = [CCParticleSystemQuad particleWithFile:@"FruitExploding.plist"];
            expl.position = bn1.sprite.position;
            expl.autoRemoveOnFinish = true;
            [self addChild:expl z:0 tag:5432];
            
            [self destroyBodyNodeWithSprite:fruitCollided];
            //[fruitCollided.sprite runAction:[CCHide action]];
        }
	}
    
    // break chain joint on collision with hail
    BodyNodeWithSprite *chainCollided = NULL;
    if (bn1.collisionType == CollisionTypeHail 
        && 
        bn2.collisionType == CollisionTypeChain)
    {
        chainCollided = bn2;
    }
    else if (bn2.collisionType == CollisionTypeHail 
             && 
             bn1.collisionType == CollisionTypeChain)
    {
        chainCollided = bn1;
    }
    
    if (chainCollided)
    {
		if(chainCollided.sprite && chainCollided.body->GetJointList())
        {
            //CCLOG(@"Hail has collided with a chain!");
            chainCollided.needsJointsDestroyed = true;
            //[self destroyBodyNodeWithJoints:chainCollided];
            //[chainCollided.sprite runAction:[CCHide action]];
        }
	}
}



@end
