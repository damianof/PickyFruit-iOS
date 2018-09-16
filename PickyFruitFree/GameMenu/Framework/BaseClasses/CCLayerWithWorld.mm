//
//  CCLayerWithWorld.mm
//
//  Created by Damiano Fusco on 4/4/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "CCLayerWIthWorld.h"
#import "b2Joint.h"
#import "AppDelegate.h"

#import "WorldHelper.h"

#import "BodyNode.h"
#import "BodyNodeWithSprite.h"
//#import "UserInterfaceLayer.h"

#import "GameGroup.h"
#import "GameLevel.h"
#import "GameManager.h"

#import "ParallaxInfo.h"
#import "StaticSpriteInfo.h"
#import "ActorInfo.h"
#import "JointInfo.h"
#import "TreeSystemInfo.h"
#import "TreeInfo.h"
#import "EnemySystemInfo.h"

#import "FruitNode.h"
#import "ChainNode.h"
//#import "TruckNode.h"
#import "TractorNode.h"
#import "HorizCartNode.h"
#import "VertCartNode.h"
#import "RotatingCartNode.h"
#import "ParallaxNode.h"
#import "TreeSystemNode.h"
#import "EnemySystemNode.h"
//#import "EnemyNode.h"


typedef enum{
    LayerWithWorldTagINVALID = 987654321,
    LayerWithWorldTagParallax,
    LayerWithWorldTagTreeSystem,
    LayerWithWorldTagEnemySystem,
    LayerWithWorldTagMAX
} LayerWithWorldTags;


@implementation CCLayerWithWorld


@synthesize 
world = _world, 
groundBody = _groundBody;


-(ParallaxNode *)parallaxNode
{
    return _parallaxNode;
}

-(TreeSystemNode *)treeSystem
{
    return _treeSystem;
}

-(EnemySystemNode *)enemySystem
{
    return _enemySystem;
}

-(TractorNode *)tractorNode
{
    return _tractorNode;
}

/*-(void)preloadSpriteBatchNodes
{   
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileTractor]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileFruit32]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileSplash32]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileStarScore64]];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileTractor];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileFruit32];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileSplash32];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileStarScore64];
}*/

-(id)init
{
	if((self=[super init])) 
    {
        _world = NULL;
        _groundBody = NULL;
                
        _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        _unitInPoint = [DevicePositionHelper unitInPoints];
        _unitInBox2D = [DevicePositionHelper unitInBox2D];
       
        GameGroup *group = [GameManager currentGameGroup];
        _unitsFromEdge  = group.unitsFromEdge; 
        _unitsYOffset   = group.unitsYOffset;
        
        _b2WorldVelocityIterations = kB2BoxWorldVelocityIterations;
        _b2WorldPositionIterations = kB2BoxWorldPositionIterations;    
        _b2WorldSubsteps = kB2BoxWorldSubsteps;
        _substepLoopCounter = 0;
        
        //float pointsToMeterRatio = [DevicePositionHelper pointsToMeterRatio];
        //CCLOG(@"CCLayerWithWorld init: pixelsToMeterRatio %f", pixelsToMeterRatio);
        
        // enable touches
		self.isTouchEnabled = YES;
        
        // Define the gravity vector.
		b2Vec2 gravity = b2Vec2(0.0f, -20.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		_world = new b2World(gravity, doSleep);
		_world->SetContinuousPhysics(kB2BoxWorldContinuousPhysics);
        
        // add Contact Listener
        _conduit = new ContactConduit(self);
		_world->SetContactListener(_conduit);
        
        // initialize dictionary of Mouse Joints
        [WorldHelper initializeMouseJointsDictionary];
        
        // make sure you set the _groundBody on the super class
        _worldSetup = [WorldSetup setupWorldWithWorld:_world 
                                         unitsYOffset:_unitsYOffset 
                                        unitsFromEdge:_unitsFromEdge]; 
        
        _groundBody = _worldSetup.groundBody;
        
        // preload sprite batch nodes
        //[self preloadSpriteBatchNodes];
        
        // create static sprites and actors:
        [self createParallaxInWorld];
        ////[self createStaticSpritesInWorld];
        [self createTreeSystemInWorld];
        [self createActorsInWorld];
        [self createEnemySystemInWorld];
        
        // initialize animations
        [[GameManager sharedInstance] initializeAnimations];
    }
    return self;
}

-(void)setDebugDraw:(bool)enabled
{
    #if COCOS2D_DEBUG == 1
    if(enabled && _debugDraw == false)
    {
        // Debug Draw functions
		_debugDraw = new GLESDebugDraw( [DevicePositionHelper pixelsToMeterRatio] );
        _world->SetDebugDraw(_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        //flags += b2Draw::e_aabbBit;
        //flags += b2Draw::e_pairBit;
        //flags += b2Draw::e_centerOfMassBit;
        _debugDraw->SetFlags(flags);
    }
    else if(enabled == false && _debugDraw)
    {
        _world->SetDebugDraw(NULL);
        delete _debugDraw;
        _debugDraw = NULL;
    }
    #endif
}

-(void) draw
{
    #if COCOS2D_DEBUG == 1
    if([AppDelegate sharedDelegate].debugDrawEnabled && _debugDraw)
    {
        // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
        // Needed states:  GL_VERTEX_ARRAY, 
        // Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        _world->DrawDebugData();
        
        // draw units grid
        //glEnable(GL_LINE_SMOOTH);
        /*if(_drawUnitsGrid)
        {
            glLineWidth(0.1f);
            // draw units grid in UI Layer for positioning UI Layer buttons etc.
            glColor4f(0.2, 0.2, 0.2, 0.1);  
            for (int i = 1; i < _screenUnitsSize.width; i++) {
                CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(i,_unitsYOffset)];
                CGPoint p2 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(i,_screenUnitsSize.height-_unitsFromEdge)];
                ccDrawLine( p1, p2 );
            }
            
            for (int i = _unitsYOffset; i < _screenUnitsSize.height; i++) {
                CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(1,i)];
                CGPoint p2 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(_screenUnitsSize.width-1,i)];
                ccDrawLine( p1, p2 );
            }
        }*/
        
        // restore default GL states
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    #endif   
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc
{
	CCLOG(@"CCLayerWithWorld dealloc"); 
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    // textures with retain count 1 will be removed
    // you can add this line in your scene#dealloc method
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    if(_conduit)
    {
        //CCLOG(@"CCLayerWithWorld dealloc: delete conduit");
        delete _conduit;
        _conduit = NULL;
    }
    
    if(_world && _debugDraw)
    {
        //CCLOG(@"CCLayerWithWorld dealloc: delete debugDraw");
        _world->SetDebugDraw(NULL);
        delete _debugDraw;
        _debugDraw = NULL;
    }
    
    if(_world && _groundBody)
    {
        //CCLOG(@"CCLayerWithWorld dealloc: delete groundBody");
        _world->DestroyBody(_groundBody);
        _groundBody = NULL;
    }
    
	if(_world)
    {
        //CCLOG(@"CCLayerWithWorld dealloc: delete world");
        delete _world;
        _world = NULL;
    }

    [self removeAllChildrenWithCleanup:YES];
    
    [_parallaxNode release];
    _parallaxNode = nil;
    
    [_treeSystem release];
     _treeSystem = nil;
    
    [_enemySystem release];
    _enemySystem = nil;
     
    _tractorNode = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"CCLayerWithWorld: onEnter");
    [super onEnter];
}

-(void)onExit
{
    CCLOG(@"CCLayerWithWorld: onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [WorldHelper destroyMouseJointsDictionary];
    [[CCDirector sharedDirector] purgeCachedData];
    
    [super onExit];
}

-(void)stopEverything
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self.parallaxNode stopAllActions];
    [self.parallaxNode unscheduleAllSelectors];
    
    [self.tractorNode stopAllActions];
    [self.tractorNode unscheduleAllSelectors];
    
    [self.treeSystem stopAllActions];
    [self.treeSystem unscheduleAllSelectors];
    
    [self.enemySystem stopAllActions];
    [self.enemySystem unscheduleAllSelectors];
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
}

-(UnitsPoint)unitsPointsRelativeToEdges:(UnitsPoint)up
{
    return UnitsPointMake(_unitsFromEdge+up.x, _unitsYOffset+up.y);
}

-(b2Vec2)b2Vec2RelativeToEdges:(UnitsPoint)up
{
    return [DevicePositionHelper b2Vec2FromUnitsPoint:[self unitsPointsRelativeToEdges:up]];
}

-(void)createParallaxInWorld
{
    GameGroup *group = [GameManager currentGameGroup];

    // If Parallax is active
    if(group.parallaxInfo.active)
    {
        _parallaxNode = [[ParallaxNode alloc] initWithInfo:group.parallaxInfo];
        [self addChild:_parallaxNode z:-90 tag:LayerWithWorldTagParallax]; 
    }
}

/*-(void)createStaticSpritesInWorld
{
    GameGroup *group = [GameManager currentGameGroup];
    UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    
    // get static sprites that do not have a body
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    for (StaticSpriteInfo *spriteInfo in group.staticSpritesInfo) 
    {
        if ([spriteInfo.imageFormat isEqualToString:kImageFormatPvrCcz]) 
        {
            //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            CCSpriteBatchNode *spritesBgNode = [CCSpriteBatchNode batchNodeWithFile:spriteInfo.framesFileName];
            [self addChild:spritesBgNode];    
            [frameCache addSpriteFramesWithFile:spriteInfo.framesFileName];
        }
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteInfo.frameName];
        sprite.anchorPoint = spriteInfo.anchorPoint;
        
        UnitsPoint unitsPosition = spriteInfo.unitsPosition;
        if(spriteInfo.positionFromTop)
        {
            unitsPosition = UnitsPointMake(unitsPosition.x + _unitsFromEdge, 
                                           screenUnitsSize.height-unitsPosition.y-_unitsFromEdge);
        }
        else
        {
            unitsPosition = UnitsPointMake(unitsPosition.x + _unitsFromEdge, 
                                           unitsPosition.y + _unitsYOffset);
        }
        
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        sprite.position = position;
        [self addChild:sprite z:spriteInfo.z tag:spriteInfo.tag];
    }
    
    // set fruits region
    //_fruitRegion = UnitsRectMake(group.fruitRegion.origin.x + _unitsFromEdge, 
    //                             group.fruitRegion.origin.y + _unitsYOffset,
     //                            group.fruitRegion.size.width,
     //                            group.fruitRegion.size.height);
    
    // TODO: for now have to loop again to find GrayClouds and set the cloudsRegion
    // later, I might find a way to do this from the xml config as well
    //for (StaticSpriteInfo *spriteInfo in group.staticSpritesInfo) 
    //{
    //    if([spriteInfo.frameName isEqualToString:@"GrayClouds"])
    //    {
     //       // set clouds region
     //       CCSprite *sprite = (CCSprite *)[self getChildByTag:spriteInfo.tag];
    //        UnitsRect skyRegion = [DevicePositionHelper unitsRectFromRect:[sprite boundingBox]];
    //        CCLOG(@"SkyRegion: %f %f %f %f", skyRegion.origin.x, skyRegion.origin.y, skyRegion.size.width, skyRegion.size.height);
    //    }
    //}
}*/

-(void)createTreeSystemInWorld
{
    GameGroup *group = [GameManager currentGameGroup];
    //UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    
    // If Tree System is active
    if(group.treeSystemInfo.active)
    {
        _treeSystem = [[TreeSystemNode alloc] initWithLayer:self 
                                             treeSystemInfo:group.treeSystemInfo];
        [self addChild:_treeSystem z:kInt1 tag:LayerWithWorldTagTreeSystem];
        [group setTreeSystem:_treeSystem];
    }
}

-(void)createEnemySystemInWorld
{
    GameGroup *group = [GameManager currentGameGroup];
    //UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    
    // If Enemey System is active
    if(group.enemySystemInfo.active)
    {
        _enemySystem = [[EnemySystemNode alloc] initWithLayer:self 
                                              enemySystemInfo:group.enemySystemInfo];
        [self addChild:_enemySystem z:kInt5 tag:LayerWithWorldTagEnemySystem];
    }
}

-(void)createActorsInWorld
{
    UnitsSize sus = [DevicePositionHelper screenUnitsRect].size;
    
    // add Group actors
    GameGroup *gameGroup = [GameManager currentGameGroup];
    for (ActorInfo *ai in gameGroup.actorsInfo) 
    {
        [self createActorInWorld:gameGroup 
                       actorInfo:ai
                 screenUnitsSize:sus];
    }
    /*
    // add Level actors
    GameLevel *gameLevel = [GameManager currentGameLevel];
    for (ActorInfo *ai in gameLevel.actorsInfo) 
    {
        [self createActorInWorld:gameGroup 
                       actorInfo:ai
                 screenUnitsSize:sus];
    }*/
     
    /*
    b2Vec2 pointA = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(3,5+_unitsYOffset)];
    b2Vec2 pointB = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(us.width - 11,5+_unitsYOffset)];
    b2Vec2 pointC = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(us.width - 11,6+_unitsYOffset)];
    b2Vec2 pointD = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(3,6+_unitsYOffset)];
    
    // create horiz shape
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
                                unitsPosition:up];*/
}

-(void)createActorInWorld:(GameGroup *)gameGroup 
                actorInfo:(ActorInfo *)ai
          screenUnitsSize:(UnitsSize)sus
{
    CCLOG(@"createActorInWorld: framesFileName %@ retainCount %d (before batchNodeWithFile)", ai.framesFileName, ai.framesFileName.retainCount);
    if ([ai.imageFormat isEqualToString:kImageFormatPvrCcz]) 
    {
        //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:ai.framesFileName]];    
    }
    CCLOG(@"createActorInWorld: framesFileName %@ retainCount %d", ai.framesFileName, ai.framesFileName.retainCount);
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:ai.framesFileName];
    CCLOG(@"createActorInWorld: framesFileName %@ retainCount %d (after adding to cache)", ai.framesFileName, ai.framesFileName.retainCount);

    // create BodyNodeWithSprite
    b2Vec2 ip = [DevicePositionHelper actorb2Vec2Position:ai.unitsPosition
                                                  fromTop:ai.positionFromTop
                                            unitsFromEdge:_unitsFromEdge
                                             unitsYOffset:_unitsYOffset];
    
    BodyNodeWithSprite *bodyNode = nil;
    /*if([ai.typeName isEqualToString:@"GenericNode"])
    {
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:ai.verticesFile
                                                       size:[s boundingBox].size
                                                     anchor:ai.anchorPoint];
        [s setAnchorPoint:ai.anchorPoint];
        
        bodyNode = [BodyNodeWithSprite createWithLayer:self
                                           anchorPoint:ai.anchorPoint
                                              position:ip 
                                                sprite:s 
                                                     z:ai.z  
                                       spriteFrameName:ai.frameName
                                                   tag:ai.tag
                                            fixtureDef:nil
                                                 shape:nil];
        bodyNode.collisionType = ai.collisionType;
        bodyNode.collidesWithTypes = ai.collidesWithTypes;
        bodyNode.maskBits = ai.maskBits;
        
        //CCLOG(@"Generic node %@ collisionType: %d maskBits: %d", ai.frameName, ai.collisionType, ai.maskBits);
        
        // add fixtures to body
        [bodyNode createBody];
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:bodyNode.body 
                                               forShapeName:ai.frameName
                                       overrideCategoryBits:bodyNode.collisionType 
                                           overrideMaskBits:bodyNode.maskBits];
        
        if(ai.angle != 0)
        {
            bodyNode.body->SetTransform(ip, ai.angle);
        }
        
        [self addChild:bodyNode z:ai.z tag:ai.tag];
        
        if(ai.makeKinematic)
        {
            [bodyNode makeKinematic];
        }
        else if(ai.makeDynamic)
        {
            [bodyNode makeDynamic];
        }
    }
    else if([ai.typeName isEqualToString:@"HorizCartNode"])
    {
        // HorizCartNode
        HorizCartNode *horizCartNode = [HorizCartNode createWithLayer:self
                                                                 info:ai  
                                                      initialPosition:ip];
        
        [horizCartNode createBody];
        [self addChild:horizCartNode z:ai.z tag:ai.tag];
        bodyNode = horizCartNode;
    }
    else if([ai.typeName isEqualToString:@"VertCartNode"])
    {
        // VertCartNode        
        VertCartNode *vertCartNode = [VertCartNode createWithLayer:self
                                                              info:ai
                                                   initialPosition:ip];
        [vertCartNode createBody];
        [self addChild:vertCartNode z:ai.z tag:ai.tag];
        bodyNode = vertCartNode;
    }
    else if([ai.typeName isEqualToString:@"RotatingCartNode"])
    {
        // RotatingCartNode
        RotatingCartNode *rotatingCartNode = [RotatingCartNode createWithLayer:self
                                                                          info:ai
                                                               initialPosition:ip];
        
        [rotatingCartNode createBody];
        [self addChild:rotatingCartNode z:ai.z tag:ai.tag];
        bodyNode = rotatingCartNode;
    }
    else if([ai.typeName isEqualToString:@"FruitNode"])
    {
        // get a random position within the region
        b2Vec2 randomPos = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:_fruitRegion];
        FruitNode *fruitNode = [self addFruit:ai position:randomPos];
        bodyNode = fruitNode;
     }*/
    /*else if([ai.typeName isEqualToString:@"BugAnimationNode"])
    {
        // BugAnimationNode        
        BugAnimationNode *bugAnimationNode = [BugAnimationNode createWithLayer:self
                                                                      info:ai
                                                           initialPosition:ip];
        //[bugAnimationNode createBody];
        [self addChild:bugAnimationNode z:ai.z tag:ai.tag];
        bodyNode = bugAnimationNode;
    }
    else if([ai.typeName isEqualToString:@"ChainNode"])
    {
        ChainNode *chainNode = [self addChain:ai position:ip];
        bodyNode = chainNode;
    }
    else if([ai.typeName isEqualToString:@"TruckNode"])
    {       
        _truckNode = [TruckNode createWithLayer:self
                                           info:ai
                                initialPosition:ip];
        
        //CCLOG(@"Truck node %@ collisionType: %d maskBits: %d", ai.frameName, ai.collisionType, ai.maskBits);
        
        [_truckNode createBody]; // need to call this before creating joints and/or making dynamic            
        
        // joints
        for (JointInfo *jointInfo in ai.joints) 
        {
            if([jointInfo.typeName isEqualToString:@"Prismatic"])
            {
                b2PrismaticJointDef pjd;
                //b2Vec2 worldAxis(1.0f, 0.0f);
                ////b2Vec2 offset = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(-20, 0)];
                b2Body *with = NULL;
                if([jointInfo.joinWith isEqualToString:@"Ground"])
                {
                    with = _groundBody;
                }
                pjd.Initialize(_truckNode.body, with, _truckNode.body->GetWorldCenter(), jointInfo.worldAxis);
                _world->CreateJoint(&pjd);
            }
        }
        
        [self addChild:_truckNode z:ai.z tag:ai.tag];
        bodyNode = _truckNode;
    }*/
    if([ai.typeName isEqualToString:@"TractorNode"])
    { 
        _tractorNode = [TractorNode createWithLayer:self
                                           info:ai
                                initialPosition:ip];
        
        [_tractorNode setNumberOfTrailers:gameGroup.numberOfTrailers];
        
        //CCLOG(@"Tractor node %@ collisionType: %d maskBits: %d", ai.frameName, ai.collisionType, ai.maskBits);
        
        [_tractorNode createBody]; // need to call this before creating joints and/or making dynamic            
        
        /*// joints
        for (JointInfo *jointInfo in ai.joints) 
        {
            if([jointInfo.typeName isEqualToString:@"Prismatic"])
            {
                b2PrismaticJointDef pjd;
                //b2Vec2 worldAxis(1.0f, 0.0f);
                ////b2Vec2 offset = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(-20, 0)];
                b2Body *with = NULL;
                if([jointInfo.joinWith isEqualToString:@"Ground"])
                {
                    with = _groundBody;
                }
                pjd.Initialize(_tractorNode.body, with, _tractorNode.body->GetWorldCenter(), jointInfo.worldAxis);
                _world->CreateJoint(&pjd);
            }
        }*/
        
        [self addChild:_tractorNode z:ai.z tag:ai.tag];        
        bodyNode = _tractorNode;
    }
    
    [bodyNode setTypeName:ai.typeName];
    
    // set body type
    if(ai.makeKinematic)
    {
        [bodyNode makeKinematic];
    }
    else if(ai.makeDynamic)
    {
        [bodyNode makeDynamic];
    }
    
    bodyNode = nil;
}

-(void)performStepInWorld:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        [GameManager increaseTimeElapsedFromStart:dt];
        
        //It is recommended that a fixed time step is used with Box2D for stability
        //of the simulation, however, we are using a variable time step here.
        //You need to make an informed choice, the following URL is useful
        //http://gafferongames.com/game-physics/fix-your-timestep/
        
        // perform several steps in the world on each call to this method
        float32 subdt = dt / _b2WorldSubsteps;
        _substepLoopCounter = 0;
        for (_substepLoopCounter = 0; _substepLoopCounter < _b2WorldSubsteps; _substepLoopCounter++) 
        {
            _world->Step(subdt, _b2WorldVelocityIterations, _b2WorldPositionIterations);
        }
        
        // Iterate over the bodies in the physics world
        for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
        {
            if (b->GetUserData() != NULL && [((id)b->GetUserData()) isKindOfClass:[BodyNodeWithSprite class]]) 
            {
                BodyNodeWithSprite *bn = (BodyNodeWithSprite *)b->GetUserData();
                
                // if needs joints destroyed:
                if(bn.needsJointsDestroyed
                   && bn.jointsDestroyed == false 
                   && bn.body)
                {
                    b2JointEdge *testJoint = bn.body->GetJointList();
                    if(bn.body->GetUserData() != NULL && testJoint)
                    {
                        //CCLOG(@"CCLayerWithWorld: performStepInWorld: destroying joints");
                        b2JointEdge *nextJoint = NULL;
                        for (b2JointEdge *joint = bn.body->GetJointList(); joint; joint = nextJoint)
                        {
                            // get the next joint ahead of time to avoid a bad pointer when joint is destroyed
                            nextJoint = joint->next;
                            
                            if(joint->joint->GetType() != e_mouseJoint)
                            {
                                _world->DestroyJoint(joint->joint);
                                joint->joint = NULL;
                                bn.jointsDestroyed = true;
                                break;
                            }
                        }
                        nextJoint = NULL;
                    }
                    testJoint = NULL;
                    
                    bn.needsJointsDestroyed = false;
                }
                
                // Synchronize the sprite position/rotation/size with the corresponding body
                [bn syncWithBody];
                bn = nil;
            }	
        }
        
        // following works for chain
        /*
         std::vector<b2Body *>toDestroy;
         std::vector<MyContact>::iterator pos;
         for(pos = _contactListener->_contacts.begin(); 
         pos != _contactListener->_contacts.end(); ++pos) {
         MyContact contact = *pos;
         
         //if ((contact.fixtureA == _bottomFixture && contact.fixtureB == _ballFixture) ||
         //    (contact.fixtureA == _ballFixture && contact.fixtureB == _bottomFixture)) {
         //dealloc"Scene *dealloc"Scene = [dealloc"Scene node];
         //[dealloc"Scene.layer.label setString:@"You Lose :["];
         //[[CCDirector sharedDirector] replaceScene:dealloc"Scene];
         //} 
         
         b2Body *bodyA = contact.fixtureA->GetBody();
         b2Body *bodyB = contact.fixtureB->GetBody();
         if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) 
         {
         //CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
         //CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
         BodyNodeWithSprite* bodyNodeA = (BodyNodeWithSprite*)bodyA->GetUserData();
         BodyNodeWithSprite* bodyNodeB = (BodyNodeWithSprite*)bodyB->GetUserData();
         
         // Sprite A = ball, Sprite B = Block
         //if (spriteA.tag == 1 && spriteB.tag == 2) {
         //    if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) 
         //        == toDestroy.end()) {
         //        toDestroy.push_back(bodyB);
         //    }
         //}
         // Sprite B = block, Sprite A = ball
         //else if (spriteA.tag == 2 && spriteB.tag == 1) {
         //    if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) 
         //        == toDestroy.end()) {
         //        toDestroy.push_back(bodyA);
         //    }
         //}
         
         if([bodyNodeA isKindOfClass:[ChainRingNode class]]
         && [bodyNodeB isKindOfClass:[ChainRingNode class]] == false)
         {
         //CCLOG(@"ChainRingNode contacted with other node");
         if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) 
         == toDestroy.end()) 
         {
         toDestroy.push_back(bodyA);
         }
         }
         else if([bodyNodeB isKindOfClass:[ChainRingNode class]]
         && [bodyNodeA isKindOfClass:[ChainRingNode class]] == false)
         {
         //CCLOG(@"ChainRingNode contacted with other node");
         if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) 
         == toDestroy.end()) 
         {
         toDestroy.push_back(bodyB);
         }
         }
         }                 
         }
         
         std::vector<b2Body *>::iterator pos2;
         for(pos2 = _toDestroy.begin(); pos2 != _toDestroy.end(); ++pos2) {
         b2Body *body = *pos2;     
         if (body->GetUserData() != NULL) {
         //CCSprite *sprite = (CCSprite *) body->GetUserData();
         //[self removeChild:sprite cleanup:YES];
         //BodyNodeWithSprite* bodyNode = (BodyNodeWithSprite*)body->GetUserData();
         
         b2JointEdge *nextJoint;
         for (b2JointEdge *joint = body->GetJointList(); joint; joint = nextJoint)
         {
         CCLOG(@"BodyNode destroying joints: retain count = %d", [self retainCount]);
         
         // get the next joint ahead of time to avoid a bad pointer when joint is destroyed
         nextJoint = joint->next;
         
         if(joint->joint->GetType() != e_mouseJoint)
         {
         _world->DestroyJoint(joint->joint);
         break;
         }
         }
         
         //following will destroy the node
         //[bodyNode removeFromParentAndCleanup:YES];
         //_world->DestroyBody(body);
         }
         //_world->DestroyBody(body);
         }*/
        
        //std::vector<BodyNodeWithSprite *>::iterator bodiesToDestroyIterator;
        for(std::vector<BodyNodeWithSprite *>::iterator bodiesToDestroyIterator = _bodyNodesWithSpriteToDestroy.begin(); 
            bodiesToDestroyIterator != _bodyNodesWithSpriteToDestroy.end(); 
            ++bodiesToDestroyIterator) 
        {
            BodyNodeWithSprite *bnws = *bodiesToDestroyIterator;     
            if (bnws && bnws.sprite) 
            {
                //CCLOG(@"CCLayerWithWorld: performStepInWorld: destroying bodies");
                
                _bodyNodesWithSpriteToDestroy.erase(bodiesToDestroyIterator);
                [bnws removeFromParentAndCleanup:YES];
                bnws = nil;
                break;
            }
            bnws = nil;
        }
        
        /*std::vector<BodyNodeWithSprite *>::iterator joinsToDestroyIterator;
         for(joinsToDestroyIterator = _bodyNodesWithJointsToDestroy.begin(); 
         joinsToDestroyIterator != _bodyNodesWithJointsToDestroy.end(); 
         ++joinsToDestroyIterator) 
         {
         BodyNodeWithSprite *bnws = *joinsToDestroyIterator;  
         b2JointEdge *test = bnws.body->GetJointList();
         
         if (bnws.body->GetUserData() != NULL && test) 
         {
         CCLOG(@"CCLayerWithWorld: performStepInWorld: destroying joints");
         
         //CCSprite *sprite = (CCSprite *) body->GetUserData();
         //[self removeChild:sprite cleanup:YES];
         //BodyNodeWithSprite* bodyNode = (BodyNodeWithSprite*)body->GetUserData();
         
         b2JointEdge *nextJoint = NULL;
         for (b2JointEdge *joint = bnws.body->GetJointList(); joint; joint = nextJoint)
         {
         // get the next joint ahead of time to avoid a bad pointer when joint is destroyed
         nextJoint = joint->next;
         
         if(joint->joint->GetType() != e_mouseJoint)
         {
         _world->DestroyJoint(joint->joint);
         joint->joint = NULL;
         //_bodyNodesWithJointsToDestroy.erase(joinsToDestroyIterator);
         break;
         }
         }
         
         //following will destroy the node
         //[bodyNode removeFromParentAndCleanup:YES];
         //_world->DestroyBody(body);
         }
         //_world->DestroyBody(body);
         }*/
        
        //////////////////////
        //////////// moving this in main loop (sync with body) higher
        /*for(BodyNodeWithSprite *bn in _bodyNodesWithJointsToDestroy)
         {
         if(bn && bn.jointsDestroyed == false && bn.body)
         {
         b2JointEdge *test = bn.body->GetJointList();
         if(bn.body->GetUserData() != NULL && test)
         {
         CCLOG(@"CCLayerWithWorld: performStepInWorld: destroying joints");
         b2JointEdge *nextJoint = NULL;
         for (b2JointEdge *joint = bn.body->GetJointList(); joint; joint = nextJoint)
         {
         // get the next joint ahead of time to avoid a bad pointer when joint is destroyed
         nextJoint = joint->next;
         
         if(joint->joint->GetType() != e_mouseJoint)
         {
         _world->DestroyJoint(joint->joint);
         joint->joint = NULL;
         bn.jointsDestroyed = true;
         //_bodyNodesWithJointsToDestroy.erase(joinsToDestroyIterator);
         break;
         }
         }
         }
         }
         }*/
        
        /////// to rethink
        /*
         for(BodyNodeWithSprite *bn in _bodyNodesWithFixturesToDestroy)
         {
         if(bn && bn.body && bn.fixturesReplaced == false)
         {
         for (b2Fixture* f = bn.body->GetFixtureList(); f; f = f->GetNext())
         {
         bn.body->DestroyFixture(f);
         }
         //[bn destroyFixture];
         
         [bn replaceFixture];
         }
         }
         
         for(BodyNodeWithSprite *bn in _bodyNodesWithFixturesToCreate)
         {
         if(bn && bn.body && bn.fixturesCreated == false)
         {
         [bn createFixture];
         }
         }
         
         for(BodyNodeWithSprite *bn in _bodyNodesWithFixturesToReplace)
         {
         if(bn && bn.body && bn.fixturesReplaced == false)
         {
         //for (b2Fixture* f = bn.body->GetFixtureList(); f; f = f->GetNext())
         //{
         //    bn.body->DestroyFixture(f);
         //}
         [bn destroyFixture];
         [bn replaceFixture];
         }
         }
         */
        
        /*CCNode *appleNode = [self getChildByTag:kAppleNodeTag];
         CCNode *rainNode = [self getChildByTag:kParticleRainTag];
         if(rainNode && appleNode)
         {
         BodyNodyWithSprite *apple = (BodyNodyWithSprite *)appleNode;
         //b2Body *body = [apple body];
         //CCLOG(@"apple x y position %f %f %f %f ", [apple box].origin.x, [apple box].origin.y, body->GetPosition().x, body->GetPosition().y);
         ParticleRain *em = (ParticleRain *)rainNode;
         int pindex = 0;
         while ( pindex < em.particleCount )
         {
         tCCParticle *part = [em getParticleAtIndex:pindex];
         CGPoint partLocation = part->pos;
         partLocation = CGPointMake(partLocation.x + em.position.x, partLocation.y + em.position.y);
         //CCLOG(@"part x y position %f %f", partLocation.x, partLocation.y);
         if ( CGRectContainsPoint( [apple box], partLocation ) )
         {
         CCLOG(@"ParticleRain collided with apple %f %f %f %f %f %f", [apple box].origin.x, [apple box].origin.y,  [apple box].size.width, [apple box].size.height, partLocation.x, partLocation.y);
         //sl.highscore++;
         }
         pindex++;
         }
         }*/
    }
}

-(void)destroyBodyNodeWithSprite:(BodyNodeWithSprite *)bn
{
    if([GameManager sharedInstance].running)
    {
        if (std::find(_bodyNodesWithSpriteToDestroy.begin(), _bodyNodesWithSpriteToDestroy.end(), bn) == _bodyNodesWithSpriteToDestroy.end()) 
        {
            _bodyNodesWithSpriteToDestroy.push_back(bn);
        }
    }
}

/*
-(void)destroyBodyNodeJoints:(BodyNodeWithSprite *)bn
{
    if (std::find(_bodyNodesWithJointsToDestroy.begin(), _bodyNodesWithJointsToDestroy.end(), bn) == _bodyNodesWithJointsToDestroy.end()) 
    {
        bodyNodesWithJointsToDestroy.push_back(bn);
    }
}*/

/*
-(void)destroyBodyNodeFixtures:(BodyNodeWithSprite *)bn
{
 if (std::find(_bodyNodesWithFixturesToDestroy.begin(), _bodyNodesWithFixturesToDestroy.end(), bn) == _bodyNodesWithFixturesToDestroy.end()) 
 {
    _bodyNodesWithFixturesToDestroy.push_back(bn);
 }
}

-(void)createBodyNodeFixtures:(BodyNodeWithSprite *)bn
{
    if(_bodyNodesWithFixturesToCreate == nil)
    {
        _bodyNodesWithFixturesToCreate = [[NSMutableArray arrayWithCapacity:10] retain];
    }
    else
    {
        // remove body nodes that already had joints destroyed
        NSMutableArray *discardedItems = [NSMutableArray arrayWithCapacity:5];
        BodyNodeWithSprite *item;
        for (item in _bodyNodesWithFixturesToCreate) {
            if (item.fixturesCreated)
            {
                [discardedItems addObject:item];
            }
        }
        [_bodyNodesWithFixturesToCreate removeObjectsInArray:discardedItems];
    }
    
    [_bodyNodesWithFixturesToCreate addObject:bn];
}

-(void)replaceBodyNodeFixtures:(BodyNodeWithSprite *)bn
{
    if(_bodyNodesWithFixturesToReplace == nil)
    {
        _bodyNodesWithFixturesToReplace = [[NSMutableArray arrayWithCapacity:10] retain];
    }
    else
    {
        // remove body nodes that already had joints destroyed
        NSMutableArray *discardedItems = [NSMutableArray arrayWithCapacity:5];
        BodyNodeWithSprite *item;
        for (item in _bodyNodesWithFixturesToReplace) {
            if (item.fixturesReplaced)
            {
                [discardedItems addObject:item];
            }
        }
        [_bodyNodesWithFixturesToReplace removeObjectsInArray:discardedItems];
    }
    
    [_bodyNodesWithFixturesToReplace addObject:bn];
}
*/

-(void)sendMessageToActorWithTag:(int)t 
                         message:(NSString *)m
                      floatValue:(float)fv
                     stringValue:(NSString *)sv
{
    if([GameManager sharedInstance].running)
    {
        // must override if needed in subclass   
        BodyNode *actor = (BodyNode *)[self getChildByTag:t];
        [actor receiveMessage:m
                   floatValue:fv
                  stringValue:sv];
    }
}

// contact
-(void) onOverlapBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2
{
    
}
 
-(void) onSeparateBody:(BodyNodeWithSprite *)bn1 
               andBody:(BodyNodeWithSprite *)bn2
{
    
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2 
            withForce:(float)f 
    withFrictionForce:(float)ff
{
    
}


@end
