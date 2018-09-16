//
//  Fruit.mm
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "FruitNode.h"
#import "CollisionTypeEnum.h"
#import "ActorInfo.h"
#import "WorldHelper.h"


@implementation FruitNode


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
    _currentMouseJoint = NULL;
    
    // hard-coded b2 anchor point
    _initialAnchorPoint = cgcenter;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    
    /*
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.5f;
    fd->friction = 500.0f;
    fd->restitution = 0.25f;
    fd->filter.categoryBits = xxxx;
    b2CircleShape *shape = new b2CircleShape();
	shape->m_radius = spriteSizeInMeters.x * 0.5f;
    //fd.shape = &shape;
    */
    
    // fruit node has density=2, friction=0.2, restitution=0.2
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
        self.collisionType = info.collisionType; //CollisionTypeFruit;
        self.collidesWithTypes = info.collidesWithTypes; //CollisionTypeObstacleHCart;
        self.maskBits = info.maskBits; //CollisionTypeALL;
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"FruitNode dealloc %@", _spriteFrameName);
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    _body->SetAngularDamping(2.0f);
    
    anchorPoint_ = _initialAnchorPoint;
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"Fruits32Vertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:_spriteFrameName
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    [_sprite setAnchorPoint:_initialAnchorPoint];

    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 
                                              swallowsTouches:NO];
}

-(void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

// collision
-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
	// check if fruit is touching the truck
	if (bn.collisionType == CollisionTypeTruck) {
		//CCLOG(@"FruitNode is overlapping with the truck.");
        //if(_sprite)
        //{
            //_sprite.color = ccRED;
        //}
	}
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
    if (bn.collisionType == CollisionTypeTruck) {
        //if(_sprite)
        //{
            //_sprite.color = ccWHITE;
        //}
    }
}

// touches
-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //int bt = self.tag;
    
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
                //CCLOG(@"FruitNode %d: Picking the body and creating mouse joint", self.tag);
                
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
                                                            bodyTag:self.tag];
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
        CCLOG(@"FruitNode %d: ccTouchCancelled: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}

-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //CCLOG(@"FruitNode %d: ccTouchEnded", self.tag);
    
    if(self.bodyType == b2_staticBody)
    {
        BodyNode *bnt = [self getTouchedBodyNode:touch];
        if(bnt)
        {
            //CCLOG(@"FruitNode %d: ccTouchEnded: makeDynamic", self.tag);
            [self makeDynamic];
        }
    }
    
    // check cached mouse joint. If exists, destroy it.
    if (_currentMouseJoint) 
    {
        CCLOG(@"FruitNode %d: ccTouchEnded: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}

@end
