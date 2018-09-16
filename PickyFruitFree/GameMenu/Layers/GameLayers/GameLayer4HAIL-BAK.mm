//
//  GameLayer4.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/17/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameLayer4.h"
#import "UserInterfaceLayer.h"
#import "GameGroup.h"
#import "StaticSpriteInfo.h"
#import "HorizCartNode.h"
#import "VertCartNode.h"
#import "SceneHelper.h"
#import "TreeSystemNode.h"
#import "OutsideScreenEnum.h"
#import "ActorInfo.h"
#import "ScrollingGround.h"
#import "TreeSystemNode.h"
#import "TreeSystemInfo.h"

@implementation GameLayer4

+(id)scene
{
    CCScene *scene = [CCScene node];
    GameLayer4 *layer = [GameLayer4 node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
	if((self=[super init])) 
    {
        [self setDebugDraw:true];
        //_drawUnitsGrid = true;
        
        // for now let's start with world debug enabled so that i can see the ground scrolling
        //[AppDelegate sharedDelegate].debugDrawEnabled = true;
        
        _groundAndTruckSpeed = _treeSystem.treeSpeed;
        UnitsPoint up = UnitsPointMake(0, 5.1);
        _scrollingGround = [ScrollingGround createWithLayer:self
                                              unitsPosition:UnitsPointMake(0, 5.0)
                                                      speed:_groundAndTruckSpeed];
        _scrollingGround.position = [DevicePositionHelper pointFromUnitsPoint:up];
        [self addChild:_scrollingGround z:-101];
        
                    //[self runAction:[CCOrbitCamera actionWithDuration:3 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:0]];
        
        _timeBeforeHail = [GameManager currentGameGroup].timeBeforeHail;
        
        // save reference to truck actor for convenience
        //_truckNode = (TruckNode *)[self getChildByTag:kActorTagTruck];
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        // using units
        //CGPoint position;
        b2Vec2 b2Vec2Position;
        int t = kActorTagFruit;
        t++; 
        float heightRatio = [DevicePositionHelper deviceHeightRatio];
        //CCLOG(@"Device height ratio is %f", heightRatio);
        // position lightining system half way vertically withiin the clouds
        b2Vec2Position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(1, [GameManager currentGameGroup].skyRegion.origin.y + [GameManager currentGameGroup].skyRegion.size.height / 2)];
        _hailSystem1 = [ParticleSystemWithBox2D createWithLayer:self
                                                       position:b2Vec2Position
                                                spriteFrameName:@"Hail" 
                                                      particles:10
                                                   particleLife:(2.0f * heightRatio)
                                                     startScale:1.0f
                                                       endScale:1.0f
                                                   emissionRate:4.0f
                                                            tag:t];
        // it will be considered outside screen when has passed the screen width by 8 units
        _hailSystem1.offsetX2ForOutsideScreen = [DevicePositionHelper unitInBox2D]*8;
        
        _hailSystem2 = [ParticleSystemWithBox2D createWithLayer:self
                                                       position:b2Vec2Position + b2Vec2(0.75f,0.12f)
                                                spriteFrameName:@"Hail" 
                                                      particles:10
                                                   particleLife:(2.0f * heightRatio)
                                                     startScale:0.8f
                                                       endScale:0.8f
                                                   emissionRate:2.0f
                                                            tag:t];
        _hailSystem2.offsetX2ForOutsideScreen = _hailSystem1.offsetX2ForOutsideScreen;
        
        _hailSystem3 = [ParticleSystemWithBox2D createWithLayer:self
                                                       position:b2Vec2Position + b2Vec2(1.5f,-0.12f)
                                                spriteFrameName:@"Hail" 
                                                      particles:10
                                                   particleLife:(2.0f * heightRatio)
                                                     startScale:0.7f
                                                       endScale:0.7f
                                                   emissionRate:3.0f
                                                            tag:t];
        _hailSystem3.offsetX2ForOutsideScreen = _hailSystem1.offsetX2ForOutsideScreen;
        
        [self addChild:_hailSystem1 z:2 tag:kActorTagParticleRain];
        [self addChild:_hailSystem2 z:3 tag:kActorTagParticleRain];
        [self addChild:_hailSystem3 z:4 tag:kActorTagParticleRain];
        
        // test CCNodeScroller
        /*CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		[self addChild:batch z:0 tag:543543543];
        int idx = (CCRANDOM_0_1() > .5 ? 0:1);
        int idy = (CCRANDOM_0_1() > .5 ? 0:1);
        CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
        [batch addChild:sprite];*/

                
        // schedule update
        [self schedule:@selector(performStepInWorld:)];
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"GameLayer2 dealloc");
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"GameLayer2 onEnter");
    [super onEnter];
       
    // Start the truck moving forward
    //[_truckNode receiveMessage:@"increaseMotorSpeed"
    //                floatValue:(_groundAndTruckSpeed*1.5f)
    //               stringValue:nil];
    
    [_tractorNode receiveMessage:@"increaseMotorSpeed"
                      floatValue:(_groundAndTruckSpeed*1.3f)
                     stringValue:nil];
}

-(void)onExit
{
    //CCLOG(@"GameLayer2 onExit");
    
    [super onExit];
}

- (void)updateTerrain:(ccTime)dt 
{
    /*float PIXELS_PER_SECOND = 30;
    static float offset = 0;
    offset += PIXELS_PER_SECOND * dt;
    
    //CGSize textureSize = _background.textureRect.size;
    //[_background setTextureRect:CGRectMake(offset*0.7, 0, textureSize.width, textureSize.height)];
    
    [_scrollingGround update:offset];*/
}

-(void)performStepInWorld:(ccTime)dt
{
    [super performStepInWorld:dt];
    
    float timeElapsed = [GameManager sharedGameManager].timeElapsedFromStart;
    
    //[self updateTerrain:dt];
    
    if (timeElapsed > _timeBeforeHail
        && _hailSystem1 
        && _hailSystem1.isActive == false) 
    {
        [self activateHailSystem:true];
    }
    
    if (timeElapsed > _timeBeforeHail)
    {
        /*if (![self updateHailSystemPosition:_hailSystem1 delta:dt]) {
            _hailSystem1 = NULL;
        }
        if (![self updateHailSystemPosition:_hailSystem2 delta:dt]) {
            _hailSystem2 = NULL;
        }
        if (![self updateHailSystemPosition:_hailSystem3 delta:dt]) {
            _hailSystem3 = NULL;
        }*/
    }
    
    /*if(_truckNode)
    {
        //CCLOG(@"TruckNode outsideScreenalue %d", _truckNode.outsideScreenValue);
        if(_truckNode.outsideScreenValue == OutsideRight)
        {
            [self countFruitSaved];
        }
    }*/
    
    
    /*if ( 
        (timeElapsed > 3.98f && timeElapsed < 3.99f)
        || (timeElapsed > 8.98f && timeElapsed < 8.99f)
        || (timeElapsed > 9.95f && timeElapsed < 10.0f)
        || (timeElapsed > 11.95f && timeElapsed < 12.0f)
        || (timeElapsed > 14.90f && timeElapsed < 15.0f)
        )
    {
        // add some lightining
        //CCLOG(@"_cloudsRegion %.f %.f %.f %.f", _cloudsRegion.origin.x, _cloudsRegion.origin.y, _cloudsRegion.size.width, _cloudsRegion.size.height);
        [self addLightiningInRegion:@"LightiningAnimA" tag:444 region:[GameManager currentGameGroup].skyRegion];
    }*/
}

/*-(void)countFruitSaved
{
    int totFruit = 0;
    [self activateHailSystem:false];
    //[self removeAllHailSystemsAndCleanup];
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    //CCNode *node;
    //CCARRAY_FOREACH(self.children, node)
    //{
    //    if ([node isKindOfClass:[FruitNode class]]) {
    //        FruitNode *fruit = (FruitNode *)node;
    //        if([fruit isWithinOtherSprite:[_truckNode sprite]])
    //        {
    //            totFruit++;
    //        }
    //    }
    //}
    //totFruit = _treeSystem.totFruitsSaved;
    
    [_truckNode removeFromParentAndCleanup:YES];
    _truckNode = NULL;
    
    // once truck is offscreen, stop all actions and load next level (or replay)
    if(totFruit > 0)
    {
        // display menu scene with GameMenuLevelPassed layer
        //[_uiLayer sendMessageToLabelWithTag:kTagUILayerLabelLevel
        //                            message:[NSString stringWithFormat:@"You saved %d fruits", totFruit]];
        
        // passed so update score/time and increase both time played/passed:
        [GameManager updateCurrentLevelAsPassedWithFruits:totFruit 
                                                  andTime:_timeElapsedFromStart];
        
        // display Level Passed screen
        TargetLayerEnum targetLayer = TargetLayerMenuLevelPassed;
        [SceneHelper menuSceneWithTargetLayer:targetLayer];
    }
    else
    {
        // reload current level for replay
        //[_uiLayer sendMessageToLabelWithTag:kTagUILayerLabelLevel
        //                            message:@"Game over!"];
        
        // failed, so increase only Times Played
        [GameManager updateCurrentLevelAsFailed];
        
        // refresh total display
        [_uiLayer refreshTotScoreLabel];

        // reload same lavel for replay
        TargetLayerEnum targetLayer = [GameManager targetLayerSelected];
        [SceneHelper multiLayerSceneWithTargetLayer:targetLayer];
    }
}*/

-(void)activateHailSystem:(bool)active
{
    if (_hailSystem1 
        && _hailSystem1.isActive == !active) 
    {
        _hailSystem1.isActive = active;
    }
    if (_hailSystem2 
        && _hailSystem2.isActive == !active) 
    {
        _hailSystem2.isActive = active;
    }
    if (_hailSystem3 
        && _hailSystem3.isActive == !active) 
    {
        _hailSystem3.isActive = active;
    }
}

-(bool)updateHailSystemPosition:(ParticleSystemWithBox2D *)ps
                          delta:(ccTime)dt
{
    bool retVal = false;
    if(ps)
    {
        if(ps.isOutsideScreen)
        {
            ps.isActive = false;
            [ps removeFromParentAndCleanup:YES];
            ps = NULL;
            retVal = false;
        }
        else if(ps.isActive)
        {
            float offset = (_unitInBox2D * dt) * 8;
            //int random = 1;//[MathHelper randomNumberBetween:1 andMax:2];
            //_lastParticleXPosition += (0.25f*random);
            b2Vec2 newPos = b2Vec2(ps.b2Vec2Position.x + offset, ps.b2Vec2Position.y);
            [ps setB2Vec2Position:newPos];
            retVal = true;
        }
    }
    return retVal;
}

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

-(void)createActorsInWorld
{
    [super createActorsInWorld];
    
    /*UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
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
                                unitsPosition:up];*/
}

-(LightiningAnimationNode *)addLightiningInRegion:(NSString *)n 
                                              tag:(int)t 
                                           region:(UnitsRect)ur
{
    // get a random position within the region
    CGPoint position = [DevicePositionHelper pointRandomWithinUnitsRect:ur];
    //CCLOG(@"Lightining position is: %f %f", position.x, position.y);
    LightiningAnimationNode *lightining = [LightiningAnimationNode createWithPosition:position  
                                                                               tag:t 
                                                                              name:n];
    [self addChild:lightining z:5 tag:t];
    return lightining;
}

/*-(void)draw
{
    glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1f); 
    
    CGRect rect = [DevicePositionHelper rectFromUnitsRect:[GameManager currentGameGroup].skyRegion];
    CGPoint p1 = rect.origin; 
    CGSize sz = rect.size;
    p1.x -= 0.1;
    p1.y -= 0.1;
    sz.width += 0.1;
    sz.height += 0.1;
    
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);
}*/

/*
-(void)ensureFruitsAreNotInteresectingInRegion:(UnitsRect)ur
                                         fruit:(FruitNode *)fruit
{
    CCNode *child;
    CCARRAY_FOREACH([self children], child)
    {
        if([child isKindOfClass:[FruitNode class]] && child.tag != fruit.tag)
        {
            CCSprite *sprite = ((FruitNode *)child).sprite;
            CGRect rect1 = [sprite boundingBox];
            CGRect rect2 = [fruit boundingBox];
            
            if( CGRectIntersectsRect(rect1, rect2))
            {
                CCLOG(@"Two fruits are interesecting");
            }
        }
    }
}
*/

-(void) onOverlapBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2
{
	// check if two boxes have started to overlap
	/*if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits have overlapped. Cool.");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccRED;
            //bn2.sprite.color = ccRED;
        }
	}*/
    
    // check if two boxes have started to overlap
	/*if (bn1.collisionType == CollisionTypeEnemy 
        || 
        bn2.collisionType == CollisionTypeEnemy) {
		
		//CCLOG(@"Two fruits have overlapped. Cool.");
        if(bn1.sprite)
        {
            bn1.sprite.color = ccGREEN;
            bn2.sprite.color = ccRED;
        }
	}*/
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn1 
               andBody:(BodyNodeWithSprite *)bn2
{
	/*// check if two boxes are no longer overlapping
	if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits stopped overlapping. That's okay too.");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccWHITE;
            //bn2.sprite.color = ccWHITE;
        }
	}*/
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn1 
              andBody:(BodyNodeWithSprite *)bn2 
            withForce:(float)f 
    withFrictionForce:(float)ff
{
	/*// check if two boxes have collided in the last update
	if (bn1.collisionType == CollisionTypeFruit 
        && 
        bn2.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"Two fruits have collided, yay!");
        if(bn1.sprite)
        {
            //bn1.sprite.color = ccYELLOW;
            //bn2.sprite.color = ccBLUE;
        }
	}*/
    
    /*// explode fruit on contact with Hail
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
            CCParticleSystemQuad *expl = [CCParticleSystemQuad particleWithFile:kFruitExplodingParticleFile];
            expl.position = bn1.sprite.position;
            expl.autoRemoveOnFinish = true;
            [self addChild:expl z:0 tag:5432];
            
            [self destroyBodyNodeWithSprite:fruitCollided];
            //[fruitCollided.sprite runAction:[CCHide action]];
        }
	}*/
    
    /*// break chain joint on collision with hail
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
            //[self destroyBodyNodeWithJoints:chainCollided];
            //[chainCollided.sprite runAction:[CCHide action]];
        }
	}*/
}



@end
