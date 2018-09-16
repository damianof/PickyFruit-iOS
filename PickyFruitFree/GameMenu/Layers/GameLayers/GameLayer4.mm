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
#import "ScrollingHills.h"

#import "TreeSystemNode.h"
#import "TreeSystemInfo.h"

@implementation GameLayer4

/*
+(id)scene
{
    CCScene *scene = [CCScene node];
    GameLayer4 *layer = [GameLayer4 node];
    [scene addChild:layer];
    return scene;
}*/

-(id) init
{
	if((self=[super init])) 
    {        
        // for now let's start with world debug enabled so that i can see the ground scrolling
        //[AppDelegate sharedDelegate].debugDrawEnabled = true;
        //[self setDebugDraw:true];
        //_drawUnitsGrid = true;
        
        _groundAndTruckSpeed = _treeSystem.treeSpeed;
        UnitsPoint up = UnitsPointMake(0, 4.6f);
        _scrollingGround = [ScrollingHills createWithLayer:self
                                             unitsPosition:UnitsPointMake(0, 4.5f)
                                                     speed:_groundAndTruckSpeed];
        _scrollingGround.position = [DevicePositionHelper pointFromUnitsPoint:up];
        //[self addChild:_scrollingGround z:-101];
        [self addChild:_scrollingGround z:1101];
        
                    //[self runAction:[CCOrbitCamera actionWithDuration:3 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:0]];
        
        _timeBeforeHail = [GameManager currentGameGroup].timeBeforeHail;
        
        /*
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
        */
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
    [self stopAllActions];
    [self unscheduleAllSelectors];
	
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"GameLayer2 onEnter");
    [super onEnter];
    
    /*float initialSpeed = -2.0f; // (_groundAndTruckSpeed);// * kTwoInverted;
    [_tractorNode receiveMessage:@"fwd"
                      floatValue:initialSpeed
                     stringValue:nil];*/
}

-(void)onExit
{
    CCLOG(@"GameLayer4 onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)performStepInWorld:(ccTime)dt
{
    [super performStepInWorld:dt];
}

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
}*/

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

@end
