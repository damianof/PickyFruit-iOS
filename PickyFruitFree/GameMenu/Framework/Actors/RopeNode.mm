//
//  RopeNode.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "RopeNode.h"


@implementation RopeNode


+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
            position:(b2Vec2)ip
     spriteFrameName:(NSString *)sfn
               parts:(int)p
                 tag:(int)t
             isLoose:(bool)il
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb
                               position:ip
                        spriteFrameName:sfn
                                  parts:p
                                    tag:t
                                isLoose:il] autorelease];
}

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb
          position:(b2Vec2)ip
   spriteFrameName:(NSString *)sfn
             parts:(int)p
               tag:(int)t
           isLoose:(bool)il
{
    if((self = [super init]))
    {
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"Rope.plist"];
        
        self.tag = t;
        _world = w;
        _groundBody = gb;
        _initialPosition = ip;
        _parts = p;
        _isLoose = il;
        _spriteFrameName = sfn;
        
        // temp sprite to get the dimensions
        CCSprite *temp = [CCSprite spriteWithSpriteFrameName:sfn];
        CGSize sz = [temp boundingBox].size;
        _spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:sz];
    }
    return self;
}

-(void)removeBodies
{
    for (int i = 1; i <= _parts; i++) 
    {
        int bnt = (i + self.tag);
        [self removeChildByTag:bnt cleanup:YES];
    }
    
    if(_isLoose == false)
    {
        int bnt = (1 + _parts + self.tag);
        [self removeChildByTag:bnt cleanup:YES];
    }
}

-(void)dealloc
{
    CCLOG(@"RopeNode dealloc");
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    if(_created == false)
    {
        [self createRopeParts];
    }
}

-(void)onExit
{
    [super onExit];  
}

-(void)createRopeParts
{
    _created = true;
    int i = 1;
    
    b2Body *prevBody = NULL;
    b2Body *firstBody = NULL;
    //RopePartNode *firstPartNode = nil;
    //RopePartNode *prevPartNode = nil;
    //RopePartNode *partNode = nil;
    
    //b2RevoluteJointDef jointDef;
    b2DistanceJointDef jointDef;
    //jointDef.frequencyHz = 0.0f;
    //jointDef.dampingRatio = 0.1f;
    //b2WeldJointDef jointDef;
    jointDef.collideConnected = false;
    //jointDef.frequencyHz = 0.0f;
    //jointDef.dampingRatio = 10.0f;
    
    //_spriteSizeInMeters = [DevicePositionHelper b2Vec2FromUnitsSize:UnitsSizeMake(1, 6)];
    float overlap = _spriteSizeInMeters.y/5;
    
    b2Vec2 pos = _initialPosition - b2Vec2(0, (_spriteSizeInMeters.y/2));
    
    // create the parts
    for (i = 1; i <= _parts; i++) {
        
        if(i > 1)
        {
            pos = pos - b2Vec2(0, (_spriteSizeInMeters.y-overlap));
        }
        
        int bnt = (i + self.tag);
        
        RopePartNode *partNode = [RopePartNode createWithWorld:_world  
                                      groundBody:_groundBody
                                        position:pos
                                             tag:bnt
                                            name:_spriteFrameName];
        
        [self addChild:partNode z:0 tag:bnt];
        [[partNode sprite] runAction:[CCHide action]];
        
        if(i == 1)
        {
            firstBody = partNode.body;
            //partNode.body->SetFixedRotation(true);
        }
        
        if(prevBody != nil)
        {
            // create revolute joints
            b2Body *body = partNode.body;
            
            b2Vec2 anchor1 = prevBody->GetPosition() - b2Vec2(0, (_spriteSizeInMeters.y/2)-(overlap/2));
            b2Vec2 anchor2 = body->GetPosition() + b2Vec2(0, (_spriteSizeInMeters.y/2)-(overlap/2));
            
            jointDef.Initialize(prevBody, body, anchor1, anchor2);
            
            //b2Vec2 anchor = prevBody->GetWorldCenter();
            //jointDef.Initialize(prevBody, body, anchor);
            _world->CreateJoint(&jointDef);
        }
        
        [partNode makeDynamic];
        
        prevBody = partNode.body;
    }
    
    if(_isLoose == false)
    {
        int bnt = (1 + i + self.tag);
        
        // Add static node to which the rope is attached
        // To have a rope that falls down, do not add this node/joint
        BodyNode *staticBodyNode = [BodyNode createWithWorld:_world
                                                  groundBody:_groundBody
                                                         tag:bnt
                                                    bodyType:b2_staticBody 
                                                      active:true 
                                                    position:_initialPosition
                                               fixedRotation:false];
        [self addChild:staticBodyNode z:0 tag:bnt];
        staticBodyNode.body->SetFixedRotation(true);
        
        /*b2FixtureDef *fd = new b2FixtureDef();
        fd->density = 0.1f;
        fd->friction = 0.5f;
        fd->restitution = 0.25f;
        b2PolygonShape *shape = new b2PolygonShape();
        shape->SetAsBox(0.1f, 0.1f);
        fd->shape = shape;
        [staticBodyNode addFixture:fd];*/
        
        prevBody = staticBodyNode.body;
         
        b2Vec2 anchor = prevBody->GetPosition();
        
        b2RevoluteJointDef rjd;
        rjd.Initialize(prevBody, firstBody, anchor);

        _world->CreateJoint(&rjd);
    }
    
    //lastPartNode = partNode;
}


@end

