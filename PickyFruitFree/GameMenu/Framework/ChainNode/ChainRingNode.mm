//
//  ChainRingNode.mm
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ChainRingNode.h"
#import "CollisionTypeEnum.h"
#import "WorldHelper.h"
#import "DevicePositionHelper.h"


@implementation ChainRingNode


+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n
       collisionType:(uint16)ct
    collidesWithTypes:(uint16)cwt
            maskBits:(uint16)mb
{
    return [[[self alloc] initWithLayer:layer
                               position:p 
                                    tag:t
                                   name:n
                          collisionType:ct
                       collidesWithTypes:cwt
                               maskBits:mb] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n
     collisionType:(uint16)ct
  collidesWithTypes:(uint16)cwt
          maskBits:(uint16)mb
{
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:n];
    s.tag = t;
    
    // hard coded anchor point
    _initialAnchorPoint = cgcenter;
    
    self.collisionType = ct;
    self.collidesWithTypes = cwt;
    self.maskBits = mb;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.5f;
    fd->friction = 0.0f;
    fd->restitution = 0.4f;
    fd->filter.categoryBits = self.collisionType;
    fd->filter.maskBits = mb;
    
    b2CircleShape *shape = new b2CircleShape();
    shape->m_radius = spriteSizeInMeters.x * 0.5f;
    //fd.shape = &shape;
    
    // chain ring node has density=2, friction=0, restitution=0.0
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:p 
                             sprite:s 
                                  z:100
                    spriteFrameName:n
                                tag:t
                         fixtureDef:fd
                              shape:shape]))
    {
        [super onEnter];
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"ChainRingNode dealloc");
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 
                                              swallowsTouches:NO];
}

-(void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    int bt = self.tag;
    
    // If this body has a current active mouse joint return
    if (_currentMouseJoint) 
    {
        return NO;
    }
    
    BOOL retVal = NO;
    if(self.bodyType != b2_staticBody)
    {
        BodyNode *touchedBodyNode = [self getTouchedBodyNode:touch];
        
        if (touchedBodyNode
            && _currentMouseJoint == NULL)
        {
            b2Body *body = self.body;
            
            if (_groundBody != body) {
                //pick the body
                CCLOG(@"ChainRingNode %d: Picking the body and creating mouse joint", self.tag);
                
                b2Vec2 locationWorld = [DevicePositionHelper locationInWorldFromTouch:touch];
                retVal = YES;
                b2MouseJointDef mjd;
                mjd.bodyA = _groundBody;
                mjd.bodyB = body;
                mjd.target = locationWorld;
                mjd.collideConnected = true;
                
                float bodyMass = body->GetMass();
                float maxForce = 500.0f * bodyMass;
                mjd.maxForce = maxForce;
                
                // create the mouse joint and cache the value locally for improved 
                // performance when later checking its value in the ccTouchMoved and ccTouchEnded events
                _currentMouseJoint = [WorldHelper createMouseJoint:_world
                                                     mouseJointDef:mjd 
                                                           bodyTag:bt];
                if(_currentMouseJoint)
                {
                    body->SetAwake(true);
                }
            }
        }
    }
    else
    {
        // handle touch, is currently isStatic == false
        return YES;
    }
    
    return retVal;
}

-(void)ccTouchMoved:(UITouch *)touch 
          withEvent:(UIEvent *)event 
{
    //CCLOG(@"ccTouchMoved");
    
    // check cached mouse joint. If not null, return.
    if (_currentMouseJoint == NULL) 
    {
        return;
    }
    
    b2Vec2 locationWorld = [DevicePositionHelper locationInWorldFromTouch:touch];
    _currentMouseJoint->SetTarget(locationWorld);
}

-(void)ccTouchCancelled:(UITouch *)touch 
              withEvent:(UIEvent *)event 
{
    //CCLOG(@"ccTouchCancelled");
    
    // check cached mouse joint. If exists, destroy it.
    if (_currentMouseJoint) 
    {
        CCLOG(@"ChainRingNode %d: ccTouchCancelled: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}

-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //CCLOG(@"ChainRingNode %d: ccTouchEnded", self.tag);
    
    if(self.bodyType == b2_staticBody)
    {
        BodyNode *bnt = [self getTouchedBodyNode:touch];
        if(bnt)
        {
            CCLOG(@"ChainRingNode %d: ccTouchEnded: makeDynamic", self.tag);
            [self makeDynamic];
        }
    }
    
    // check cached mouse joint. If exists, destroy it.
    if (_currentMouseJoint) 
    {
        CCLOG(@"ChainRingNode %d: ccTouchEnded: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}

@end
