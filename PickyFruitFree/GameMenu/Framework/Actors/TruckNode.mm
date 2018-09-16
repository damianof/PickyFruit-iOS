//
//  TruckNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TruckNode.h"
#import "WorldHelper.h"
#import "CollisionTypeEnum.h"
#import "ChainNode.h"
#import "TruckWheelNode.h"


typedef enum{
    TruckTagINVALID = 0,
    TruckTagWheelBack,
    //TruckTagWheelMiddle,
    TruckTagWheelFront,
    TruckTagChain,
    TruckTagMAX
} TruckTags;


@implementation TruckNode


@synthesize 
info = _info,
motorJoint = _motorJoint;
//truckBedRect = _truckBedRect;

-(CGRect)truckBedRect
{
    CGRect box = [_sprite boundingBox];
    return CGRectMake(box.origin.x+10, box.origin.y+(box.size.height*.4)+10, box.size.width*.4, box.size.height*.5);
}

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
    self.info = info;
    _currentMouseJoint = NULL;
    
    // set anchor point
    _initialAnchorPoint = info.anchorPoint;
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits; 
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    s.opacity = 0;
        
    // Truck node
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
        _truckSpeed = 0;
        // need to slightly increase left side offset
        // so that is not considered offscreen when just simply touching the left border
        self.offsetX1ForOutsideScreen = -0.1f;
        
        // attach back wheel
        uint16 wheelMaskBits = CollisionTypeALL
            & ~CollisionTypeTruck;
        
        _wheelBackNode = [TruckWheelNode createWithLayer:layer
                                                position:_initialPosition 
                                                     tag:TruckTagWheelBack 
                                                    name:@"TruckWheel"
                                           collisionType:self.collisionType
                                       collidesWithTypes:self.collidesWithTypes
                                                maskBits:wheelMaskBits];
        _wheelBackNode.sprite.opacity = 0;
        float offset = _wheelBackNode.spriteSizeInMeters.x/2;
        float wheelY = _initialPosition.y + (_spriteSizeInMeters.y * 0.339f) - offset
            -0.03f;

        b2Vec2 wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.185f) + offset, wheelY);
        [_wheelBackNode setInitialPosition:wheelPosition];
        [self addChild:_wheelBackNode z:(info.z + 1) tag:TruckTagWheelBack];
        
        //// attach middle wheel
        //_wheelMiddleNode = [TruckWheelNode createWithWorld:self.world
        //                                        groundBody:self.groundBody
        //                                         position:_initialPosition 
        //                                               tag:TruckTagWheelMiddle 
        //                                              name:@"TruckWheel"
        //                                     collisionType:self.collisionType
        //                                 collidesWithTypes:self.collidesWithTypes
        //                                          maskBits:wheelMaskBits];
        //_wheelMiddleNode.sprite.opacity = 0;
        //wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.3292719f) + offset, wheelY);
        //[_wheelMiddleNode setInitialPosition:wheelPosition];
        //[self addChild:_wheelMiddleNode z:(info.z + 1) tag:TruckTagWheelMiddle];
        
        // attach front wheel
        _wheelFrontNode = [TruckWheelNode createWithLayer:layer
                                                 position:wheelPosition 
                                                      tag:TruckTagWheelFront 
                                                     name:@"TruckWheel"
                                            collisionType:self.collisionType
                                        collidesWithTypes:self.collidesWithTypes
                                                 maskBits:wheelMaskBits];
        _wheelFrontNode.sprite.opacity = 0;
        wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.665f) + offset, wheelY);
        [_wheelFrontNode setInitialPosition:wheelPosition];
        [self addChild:_wheelFrontNode z:(info.z + 1) tag:TruckTagWheelFront];
        

        // attach a chain to truck, with a position 
        // slightly hight than half the size of the sprite (0.75)
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ChainRingB-16"];
        b2Vec2 chainRingSize = [DevicePositionHelper b2Vec2FromSize:frame.rect.size];
        offset = chainRingSize.x/2;
        b2Vec2 chainPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0) + offset, 
                                      _initialPosition.y + (_spriteSizeInMeters.y * 0.9) - offset);
        //b2Vec2 chainPosition = self.initialPosition + b2Vec2(0.5f,self.spriteSizeInMeters.y*0.75f);
        // x 0.546610169491525
        b2Vec2 endRingPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.52) + offset, 
                                      _initialPosition.y + (_spriteSizeInMeters.y * 0.9) - offset);
        //b2Vec2 endRingPosition = self.initialPosition + b2Vec2(5.5f,self.spriteSizeInMeters.y*0.75f);
        
        ActorInfo* chainInfo = [self getInfoForChain];
        _truckChain = [ChainNode createWithLayer:layer
                                            info:chainInfo
                                 initialPosition:chainPosition];
        // chain needs additional parameters to be set:
        [_truckChain setNumberOfRings:7 isLoose:true endRingPosition:endRingPosition];
        [self addChild:_truckChain z:chainInfo.z tag:TruckTagChain];

        // run update only once to make wheels visible
        [self scheduleUpdate];
    }
    return self;
}

/*-(void)draw
{
    // draw a ine to show where the truck bed is
    glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1f); 
    
    CGRect test = self.truckBedRect; //CGRectMake(0.0, 40.0, 192.0, 112.0);
    CGPoint p1 = test.origin; //_truckBedRect.origin;
    CGSize sz = test.size; //_truckBedRect.size;
    
    //[super draw];
    
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);
    
    //CCLOG(@"Truck Draw: %f %f %f %f", p1.x, p1.y, sz.width, sz.height);
}*/

-(ActorInfo*)getInfoForChain
{
    uint16 collidesWithTypes = CollisionTypeALL
        & ~CollisionTypeTruck
        & ~CollisionTypeFruit;
    uint16 maskBits = CollisionTypeALL // collides with everyone but
        & ~CollisionTypeTruck // not with truck
        & ~CollisionTypeFruit; // and not with fruit
    
    CGPoint ap = cgcenter;
    UnitsPoint up = UnitsPointMake(0,0); //13, 15+_unitsYOffset);
    UnitsBounds ub = UnitsBoundsMake(0,0); //UnitsBoundsFromString(ubStr);
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:@"ChainNode"
                                                     tag:TruckTagChain
                                                       z:(self.info.z + 1)
                                          framesFileName:@"Chain16.plist"
                                             imageFormat:kImageFormatPng
                                               frameName:@"ChainRingB-16" 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:false
                                                   angle:0
                                             unitsBounds:ub];
    
    //actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = false;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = self.collisionType;
    actorInfo.collidesWithTypes = collidesWithTypes;
    actorInfo.maskBits = maskBits;
    
    return actorInfo; 
}

-(void)removeBodies
{
    for (int bnt = (TruckTagINVALID + 1); bnt < TruckTagMAX; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        [node destroyFixture];
        [node destroyBody];
        [node removeFromParentAndCleanup:YES];
    }
}

-(void)dealloc
{
    //CCLOG(@"TruckNode dealloc");
    
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    
    [_info release];
    _info = nil;
    
    [super dealloc];
}

-(void)update:(ccTime)delta
{
    // unschedule so that Update is called only once
    [self unscheduleAllSelectors];
    self.body->SetAwake(false);
    
    if(_wheelBackNode.sprite.opacity != 255)
    {
        _wheelBackNode.sprite.opacity = 255;
        //_wheelMiddleNode.sprite.opacity = 255;
        _wheelFrontNode.sprite.opacity = 255;
    }
}

-(void)onEnter
{
    _sprite.opacity = 255;
    [super onEnter];
    
    self.body->SetAwake(false);
    
    // attach wheel
    b2RevoluteJointDef motorJointDef;
    motorJointDef.enableMotor = true;
    motorJointDef.motorSpeed = 0;
    motorJointDef.maxMotorTorque = 400;
    
    b2Vec2 wheelcenter = _wheelBackNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    motorJointDef.Initialize(self.body, _wheelBackNode.body, wheelcenter);
    b2Joint *joint = _world->CreateJoint(&motorJointDef);
    _motorJoint = (b2RevoluteJoint*)joint;
    
    b2RevoluteJointDef jointDef;
    
    //// attach middle wheel
    //wheelcenter = _wheelMiddleNode.body->GetWorldCenter();
    //wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    //jointDef.Initialize(self.body, _wheelMiddleNode.body, wheelcenter);
    //_world->CreateJoint(&jointDef);
    
    // attach front wheel
    wheelcenter = _wheelFrontNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    jointDef.Initialize(self.body, _wheelFrontNode.body, wheelcenter);
    _world->CreateJoint(&jointDef);
    
    // attach chain on the back
    jointDef.Initialize(self.body, _truckChain.firstBodyNode.body, _truckChain.firstBodyNode.body->GetWorldCenter());
    _world->CreateJoint(&jointDef);
    // attach chain on the front
    jointDef.Initialize(self.body, _truckChain.lastBodyNode.body, _truckChain.lastBodyNode.body->GetWorldCenter());
    _world->CreateJoint(&jointDef);
    
    anchorPoint_ = _initialAnchorPoint;
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"TruckVertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:@"Truck"
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

-(void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)updateMotorSpeed:(float)s
{
    self.body->SetAwake(false);
    _motorJoint->SetMotorSpeed(s); 
    
    /*b2Vec2 pos = self.body->GetPosition();
    b2Vec2 desiredLocation = b2Vec2(pos.x + (s*-1), pos.y);
    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - pos.x,
                                      desiredLocation.y - pos.y);
    
    directionToTravel *= 20 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO

    self.body->SetLinearVelocity(directionToTravel);*/
}

// collision
-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
	// check if fruit is touching the truck
	if (bn.collisionType == CollisionTypeFruit) {
		
		//CCLOG(@"TruckNode contains fruit.");
        //if(_sprite)
        //{
        //    _sprite.color = ccBLUE;
        //}
	}
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
    if (bn.collisionType == CollisionTypeFruit) {
        //if(_sprite)
        //{
        //    _sprite.color = ccWHITE;
        //}
    }
}

/*
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
    if(_isStatic == false)
    {
        BodyNode *touchedBodyNode = [self getTouchedBodyNode:touch];
        
        if (touchedBodyNode
            && _currentMouseJoint == NULL)
        {
            b2Body *body = self.body;
            
            if (_groundBody != body) {
                //pick the body
                //CCLOG(@"TruckNode %d: Picking the body and creating mouse joint", self.tag);
                
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
        //CCLOG(@"TruckNode %d: ccTouchCancelled: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}

-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //CCLOG(@"TruckNode %d: ccTouchEnded", self.tag);
    
    if(_isStatic)
    {
        BodyNode *bnt = [self getTouchedBodyNode:touch];
        if(bnt)
        {
            //CCLOG(@"TruckNode %d: ccTouchEnded: makeDynamic", self.tag);
            [self makeDynamic];
        }
    }
    
    // check cached mouse joint. If exists, destroy it.
    if (_currentMouseJoint) 
    {
        //CCLOG(@"TruckNode %d: ccTouchEnded: destroy joint", self.tag);
        [WorldHelper destroyMouseJointByTag:_world tag:self.tag];
        _currentMouseJoint = NULL;
    }
}
*/

// receive message
-(void)receiveMessage:(NSString *)m
           floatValue:(float)fv
          stringValue:(NSString *)sv
{
    bool reduceSpeed = [m isEqualToString:@"reduceMotorSpeed"];
    //bool increaseSpeed = [m isEqualToString:@"increaseMotorSpeed"];
    
    //if(reduceSpeed || increaseSpeed)
    {
        int factor = -1;
        if(reduceSpeed)
        {
            factor = 1;
        }
        
        _truckSpeed += (fv * factor);
        [self updateMotorSpeed:_truckSpeed];
    }
}

@end
