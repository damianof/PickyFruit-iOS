//
//  ChainNode.mm
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ChainNode.h"
#import "ActorInfo.h"
#import "BodyNode.h"
#import "ChainRingNode.h"


@implementation ChainNode


@synthesize 
    firstBodyNode = _firstBodyNode,
    lastBodyNode = _lastBodyNode,
    staticBodyNode = _staticBodyNode;


+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip
{
    return [[[self alloc] initWithLayer:layer
                                   info:info
                        initialPosition:ip] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip
{
    _info = info;
    
    // hard coded anchor point
    _initialAnchorPoint = cgcenter;
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:ip 
                             sprite:s
                                  z:info.z
                    spriteFrameName:info.frameName  
                                tag:info.tag
                         fixtureDef:nil
                              shape:nil]))
    {
        s.opacity = 0;
        
        //_ringNodes = [[CCArray alloc] initWithCapacity:r];
        
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
        //                                                 priority:0 
        //                                          swallowsTouches:NO];
    }
    return self;
}

-(void)setNumberOfRings:(int)r
                isLoose:(bool)il
        endRingPosition:(b2Vec2)erp
{
    _rings = r;
    _isLoose = il;  
    _endRingPosition = erp;
}

-(void)removeBodies
{
    for (int i = 1; i <= _rings; i++) 
    {
        int bnt = (i + self.tag);
        CCNode *node = [self getChildByTag:bnt];
        [node removeFromParentAndCleanup:YES];
    }
    
    if(_isLoose == false)
    {
        int bnt = (1 + _rings + self.tag);
        CCNode *node = [self getChildByTag:bnt];
        [node removeFromParentAndCleanup:YES];
    }
}

-(void)dealloc
{
    CCLOG(@"ChainNode dealloc");
    [self stopAllActions];
	[self unscheduleAllSelectors];
    
    //[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    //[self removeSprite];
    [self removeBodies];
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    if(_created == false)
    {
        [self createChainRings];
    }
}

-(void)onExit
{
    [super onExit];  
}

-(void)createChainRings
{
    _created = true;
    int i = 1;
    
    b2Vec2 pos = _initialPosition;
    //b2Body *prevBody;
    //b2Body *body;
    ChainRingNode *prevRingNode = nil;
    ChainRingNode *ringNode = nil;
    
    b2RevoluteJointDef jointDef;
    //b2WeldJointDef jointDef;
    jointDef.collideConnected = false;
    
    // create the rings
    for (i = 1; i <= _rings; i++) {
        
        if(i==1)
        {
            pos = _initialPosition;
        }
        else if (_endRingPosition.x > 0 && _endRingPosition.y > 0)
        {
            b2Vec2 diff = _endRingPosition - _initialPosition;
            float xinterval = diff.x / _rings;
            float yinterval = diff.y / _rings;
            pos = pos + b2Vec2(xinterval, yinterval);
        }
        else
        {
            pos = pos + b2Vec2(_spriteSizeInMeters.x/2, -(_spriteSizeInMeters.y/2));
        }
        
        int bnt = (i + self.tag);
                
        ringNode = [ChainRingNode createWithLayer:_layer
                                         position:pos
                                              tag:bnt
                                             name:_spriteFrameName
                                    collisionType:self.collisionType
                                collidesWithTypes:self.collidesWithTypes
                                         maskBits:self.maskBits];
        
        ringNode.body->SetBullet(true);
        
        [self addChild:ringNode z:0 tag:bnt];
        
        if(i == _rings)
        {
            _lastBodyNode = ringNode;
            ringNode.body->SetFixedRotation(true);
        }
        else if(i==1)
        {
            _firstBodyNode = ringNode;
        }
        
        if(prevRingNode != nil)
        {
            // create revolute joints
            b2Body *prevBody = prevRingNode.body;
            b2Body *body = ringNode.body;
            
            jointDef.Initialize(prevBody, body, body->GetWorldCenter());
            _world->CreateJoint(&jointDef);
        }
        
        [ringNode makeDynamic];
        prevRingNode = ringNode;
    }
    
    //lastRingNode = ringNode;
    
    if(_isLoose == false)
    {
        int bnt = (1 + _rings + self.tag);
        
        // Add static node to which the chain is attached
        // To have a chain that falls down, do not add this node/joint
        _staticBodyNode = [BodyNode createWithWorld:_world
                                         groundBody:_groundBody
                                                tag:bnt
                                           bodyType:b2_staticBody 
                                             active:true 
                                           position:_initialPosition
                                      fixedRotation:false];
        [self addChild:_staticBodyNode z:0 tag:bnt];
        
        b2Body *prevBody = _staticBodyNode.body;
        b2Body *body = _firstBodyNode.body;
        
        jointDef.Initialize(prevBody, body, body->GetWorldCenter());
        _world->CreateJoint(&jointDef);
    }
}

//-(void)syncPositionAndRotation
//{
//}


@end

