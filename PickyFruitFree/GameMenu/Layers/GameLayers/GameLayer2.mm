//
//  GameLayer2.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameLayer2.h"


@implementation GameLayer2


-(id) init
{
	if( (self=[super init])) 
    {
        /*[self setDebugDraw:true];
        _drawUnitsGrid = false;
                
        // add the fixture definitions to the body
        //[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"MountainsVertices.plist"];
        //[[GB2ShapeCache sharedShapeCache] addFixturesToBody:_groundBody forShapeName:@"Mountains"];
        //[spriteMountains setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Mountains"]];
        
        // using units
        UnitsPoint up;
        int t = kActorTagFruit;
        UnitsRect fruitRegion = UnitsRectMake(6, 6, 50, 32);
        // add fruits:
        [self addFruitInRegion:@"AppleGreen-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"AppleRed-32" tag:t region:fruitRegion];
        [self addFruitInRegion:@"Banana-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"BugFlyingRed-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"Cherries-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"FlowerGreen-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"FlowerRed-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"GrapeGreen-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"Kiwi-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"LadyBug-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"LadyBugSide-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"Melon-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"OrangeHalf-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"Pineapple-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"Raspberry-32" tag:t++ region:fruitRegion];
        [self addFruitInRegion:@"Strawberry-32" tag:t++ region:fruitRegion];
        //[self addFruitInRegion:@"Watermelon-32" tag:t++ region:fruitRegion];
        
        // add chains:
        up = UnitsPointMake(11, 22);
        [self addChain:@"ChainRingB-32" rings:3 tag:t++ location:up isLoose:false];
        //up = UnitsPointMake(28, 35);
        //[self addChain:@"ChainRingB-32" rings:4 tag:t++ location:up isLoose:false];
        //up = UnitsPointMake(35, 30);
        //[self addChain:@"ChainRingB-32" rings:5 tag:t++ location:up isLoose:true];
        
        //up = UnitsPointMake(30, 30);
        //[self addChain:@"ChainRingB-16" rings:7 tag:t++ location:up isLoose:false];
        
        */
        
        // add ropes:
        //up = UnitsPointMake(32.5, 38);
        //[self addRope:@"RopePart2" parts:10 tag:t++ location:up isLoose:false];
        
        /*// add bucket
         up = UnitsPointMake(25, 30);
         [self addBucket:@"BucketTestB" tag:131 location:up];
         
         // add bulldozer
         up = UnitsPointMake(35, 10);
         [self addBulldozer:131 location:up];*/
        
        
        /*up = UnitsPointMake(22, 22);
        b2Vec2 position = [DevicePositionHelper b2Vec2FromUnitsPoint:up];
        BugAnimationNode *bugAnim = [BugAnimationNode createWithWorld:self.world
                                                           groundBody:self.groundBody
                                                             position:position  
                                                                  tag:t++ 
                                                                 name:@"BugAnimation"];
        [self addChild:bugAnim z:1 tag:t++];*/
        
        /*up = UnitsPointMake(20, 30);
        ParticleRain *system = [ParticleRain node];
        system.emitterMode = kCCParticleModeGravity;
        system.sourcePosition = CGPointMake(0,0);
        system.posVar = CGPointMake(0,0);
        system.gravity = CGPointMake(0,-5);
        system.speed = 10;
		system.speedVar = 0;
        
        system.totalParticles = 1;
        system.life = 7;
        system.lifeVar = 0;
        system.startSize = 16;
        system.startSizeVar = 0;
        system.endSize = 16;
        system.endSizeVar = 0;
        system.emissionRate = 30;
        system.position = [DevicePositionHelper pointFromUnitsPoint:up];
        [self addChild:system z:0 tag:kParticleRainTag];*/
        
        //ParticleRain *system = [ParticleRain createWithWorld:_world groundBody:_groundBody];
        //system.position = [DevicePositionHelper pointFromUnitsPoint:up];
        
        /*b2Vec2 position = [DevicePositionHelper b2Vec2FromUnitsPoint:up];
        ParticleSystemWithBox2D *system = [ParticleSystemWithBox2D createWithLayer:self
                                                                          position:position
                                                                   spriteFrameName:@"Hail" 
                                                                         particles:10
                                                                      particleLife:2.0f
                                                                        startScale:1
                                                                          endScale:1
                                                                      emissionRate:4
                                                                               tag:t];
        [self addChild:system z:0 tag:kActorTagParticleRain];
         
        
        [self schedule: @selector(performStepInWorld:)];*/
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"GameLayer2 dealloc");
    [super dealloc];
}
/*
-(void)onEnter
{
    //CCLOG(@"GameLayer2 onEnter");
    
    [super onEnter];
}

-(void)onExit
{
    //CCLOG(@"GameLayer2 onExit");
    
    [super onExit];
}

-(void)createStaticSpritesInWorld
{
    [super createStaticSpritesInWorld];
}

-(void)createActorsInWorld
{
    [super createActorsInWorld];
    
    // another shape:
    UnitsSize us = [DevicePositionHelper screenUnitsRect].size;
    
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
                                unitsPosition:up];
    
}
*/
/*
-(void)addFruitInRegion:(NSString *)n 
                    tag:(int)t 
                 region:(UnitsRect)ur
{
    CGPoint screenCenter = [DevicePositionHelper screenCenter];
    
    // convert Units Rect back to points
    CGRect r = [DevicePositionHelper rectFromUnitsRect:ur];
    int startx = screenCenter.x - r.size.width/2;
    int endx = screenCenter.x + r.size.width/2;
    int starty = screenCenter.y - r.size.height/2; // trying to get top part of tree
    int endy = screenCenter.y; // trying to get top part of tree
    
    int x = [MathHelper randomNumberBetween:startx andMax:endx];
    int y = [MathHelper randomNumberBetween:starty andMax:endy];
    
    b2Vec2 position = [DevicePositionHelper locationInWorld:CGPointMake(x,y)];
    
    //b2Vec2 position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(20,17)];
    FruitNode *fruit = [FruitNode createWithLayer:self
                                         position:position  
                                              tag:t 
                                             name:n];
    
    fruit.collisionType = CollisionTypeFruit;
	fruit.collidesWithTypes = (CollisionTypeFruit | CollisionTypeChain);
    
    [self addChild:fruit z:0 tag:t];
}*/


/*-(void)addChainWithFrameName:(NSString *)fn
            spriteFramesFile:(NSString *)sff
                         tag:(int)t 
                       rings:(int)r
                    location:(UnitsPoint)up
                     isLoose:(bool)il
{
    CGPoint ap = cgcenter;
    UnitsBounds ub = UnitsBoundsMake(0,0); //UnitsBoundsFromString(ubStr);
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:@"ChainNode"
                                                     tag:t
                                                       z:0
                                        spriteFramesFile:sff //@"Chain16.plist"
                                               frameName:fn //@"ChainRingB-16" 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:false
                                                   angle:0
                                             unitsBounds:ub];
    
    //actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = false;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = CollisionTypeChain;
    actorInfo.collidesWithTypes = CollisionTypeFruit;
    actorInfo.maskBits = CollisionTypeZERO;
    
    b2Vec2 ip = [DevicePositionHelper b2Vec2FromUnitsPoint:up];
    ChainNode *chain = [ChainNode createWithLayer:self
                                             info:actorInfo
                                  initialPosition:ip];
    // chain needs additional parameters to be set:
    [chain setNumberOfRings:r isLoose:il endRingPosition:b2Vec2(0,0)];
    [self addChild:chain];
}*/
/*
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
            bn1.sprite.color = ccRED;
            bn2.sprite.color = ccRED;
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
            bn1.sprite.color = ccWHITE;
            bn2.sprite.color = ccWHITE;
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
            bn1.sprite.color = ccYELLOW;
            bn2.sprite.color = ccBLUE;
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
		CCLOG(@"Hail has collided with a fruit!");
        if(fruitCollided.sprite)
        {
            CCParticleSystemQuad *expl = [CCParticleSystemQuad particleWithFile:kFruitExplodingParticleFile];
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
            CCLOG(@"Hail has collided with a chain!");
            //[self destroyBodyNodeWithJoints:chainCollided];
            chainCollided.needsJointsDestroyed = true;
            //[chainCollided.sprite runAction:[CCHide action]];
        }
	}
}

*/

@end
