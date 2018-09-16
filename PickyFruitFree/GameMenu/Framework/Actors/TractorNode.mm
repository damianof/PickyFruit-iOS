//
//  TractorNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/1/2012.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TractorNode.h"
#import "WorldHelper.h"
#import "CollisionTypeEnum.h"
#import "TractorDriverNode.h"
#import "ChainNode.h"
#import "TractorWheelNode.h"
#import "TrailerNode.h"
#import "GameManager.h"


typedef enum{
    TractorTagINVALID = 0,
    TractorTagTrailer1,
    TractorTagTrailer2,
    TractorTagTrailer3,
    TractorTagTrailer4,
    TractorTagTrailer5,
    TractorTagWheelRear,
    TractorTagWheelFront,
    TractorTagDriver,
    TractorTagMAX
} TractorTags;


@implementation TractorNode


@synthesize 
info = _info,
motorJoint = _motorJoint;

-(int)numberOfTrailers
{
    return _numberOfTrailers;
}

-(void)setNumberOfTrailers:(int)number
{
    _numberOfTrailers = number;
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
    
    // Tractor node
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
        _tractorSpeed = kFloat3 * [DevicePositionHelper scaleFactor]; // this is multiplied later by pixels to move
        //_scaleFactor = [DevicePositionHelper scaleFactor];
        _screenWidth = [DevicePositionHelper screenRect].size.width;
        
        CCSpriteFrame *tractorFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tractor"];
        _tractorSpriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:tractorFrame.rect.size];
        tractorFrame = nil;
        
        CCSpriteFrame *trailerFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Trailer"];
        _trailerSpriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:trailerFrame.rect.size];
        trailerFrame = nil;
        
        _pixelsToMove = [DevicePositionHelper pixelsToMove];
        
        // need to slightly increase left side offset
        // so that is not considered offscreen when just simply touching the left border
        self.offsetX1ForOutsideScreen = -0.1f;
        
        // attach back wheel
        uint16 wheelMaskBits = CollisionTypeALL
        & ~CollisionTypeTruck;
        
        _wheelBackNode = [TractorWheelNode createWithLayer:layer
                                                  position:_initialPosition 
                                                       tag:TractorTagWheelRear 
                                                      name:@"TractorRearWheel"
                                             collisionType:self.collisionType
                                         collidesWithTypes:self.collidesWithTypes
                                                  maskBits:wheelMaskBits];
        _wheelBackNode.sprite.opacity = 0;
        float offset = _wheelBackNode.spriteSizeInMeters.x/2;
        float wheelY = _initialPosition.y + (_spriteSizeInMeters.y * 0.63f) - offset -0.04f;
        
        b2Vec2 wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.05f) + offset, wheelY);
        [_wheelBackNode setInitialPosition:wheelPosition];
        [self addChild:_wheelBackNode z:(info.z + 1) tag:TractorTagWheelRear];
        
        // attach front wheel
        wheelY = _initialPosition.y + (_spriteSizeInMeters.y * 0.50f) - offset -0.04f;
        _wheelFrontNode = [TractorWheelNode createWithLayer:layer
                                                   position:wheelPosition 
                                                        tag:TractorTagWheelFront 
                                                       name:@"TractorFrontWheel"
                                              collisionType:self.collisionType
                                          collidesWithTypes:self.collidesWithTypes
                                                   maskBits:wheelMaskBits];
        _wheelFrontNode.sprite.opacity = 0;
        wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.665f) + offset, wheelY);
        [_wheelFrontNode setInitialPosition:wheelPosition];
        [self addChild:_wheelFrontNode z:(info.z + 1) tag:TractorTagWheelFront];
        
        
        // driver
        b2Vec2 driverPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x*0.4f), (_initialPosition.y + _spriteSizeInMeters.y)*1.02);
        _driverNode = [TractorDriverNode createWithLayer:layer
                                                position:driverPosition 
                                                     tag:TractorTagDriver 
                                                    name:@"TractorDriver0"
                                           collisionType:CollisionTypeTruckDriver
                                       collidesWithTypes:self.collidesWithTypes
                                                maskBits:wheelMaskBits];
        [_driverNode setInitialPosition:driverPosition];
        [self addChild:_driverNode z:(info.z + 1) tag:TractorTagDriver];
        
        // run update only once to make wheels visible
        [self scheduleUpdate];
    }
    return self;
}

-(ActorInfo*)getInfoForTrailer:(int)trailerTag
{
    uint16 collidesWithTypes = CollisionTypeALL
    & ~CollisionTypeTruck;
    uint16 maskBits = CollisionTypeALL // collides with everyone but
    & ~CollisionTypeTruck; // not with truck
    
    CGPoint ap = CGPointMake(0.0f, 0.0f);
    UnitsPoint up = self.info.unitsPosition;
    UnitsBounds ub = UnitsBoundsMake(0,0);
    
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:@"TrailerNode"
                                                     tag:trailerTag
                                                       z:(self.info.z + trailerTag)
                                          framesFileName:self.info.framesFileName
                                             imageFormat:self.info.imageFormat
                                               frameName:@"Trailer" 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:false
                                                   angle:0
                                             unitsBounds:ub];
    
    //actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = true;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = self.collisionType;
    actorInfo.collidesWithTypes = collidesWithTypes;
    actorInfo.maskBits = maskBits;
    
    return actorInfo; 
}

-(void)addTrailerWithTag:(int)trailerTag
{
    ActorInfo* trailerInfo = [self getInfoForTrailer:trailerTag];
    
    // Trailer (position behind tractor)
    float factor = 0.93f;
    float xpos = (_initialPosition.x-(_trailerSpriteSizeInMeters.x*trailerTag*factor));
    b2Vec2 trailerPosition = b2Vec2(xpos, _initialPosition.y*1.08f); //1.12f);
    TrailerNode *trailerNode = [[TrailerNode alloc] initWithLayer:_layer
                                                             info:trailerInfo
                                                  initialPosition:trailerPosition];
    // CCLOG(@"TractorNode: addTrailerWithTag: _layer retain count %d", _layer.retainCount);
    [trailerNode setTractorNode:self]; // weak reference
    //_trailerNode.sprite.opacity = 0;
    [self addChild:trailerNode z:trailerInfo.z tag:trailerInfo.tag];
    [trailerNode release];
    trailerNode = nil;
}

-(void)removeBodies
{
    for (int bnt = (TractorTagINVALID + 1); bnt < TractorTagMAX; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        if(node)
        {
            [node destroyFixture];
            [node destroyBody];
            [node removeFromParentAndCleanup:YES];
        }
    }
}

-(void)dealloc
{
    CCLOG(@"TractorNode dealloc");
    
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [_info release];
    _info = nil;
    
    _driverNode = nil;
    _wheelBackNode = nil;
    _wheelFrontNode = nil;
    
    [super dealloc];
}

-(void)update:(ccTime)delta
{
    if([GameManager sharedInstance].running)
    {
        // unschedule so that Update is called only once
        [self unscheduleAllSelectors];
        self.body->SetAwake(false);
        
        if(_wheelBackNode.sprite.opacity != 255)
        {
            _wheelBackNode.sprite.opacity = 255;
            _wheelFrontNode.sprite.opacity = 255;
        }
    }
}

-(void)onEnter
{
    _sprite.opacity = 255;
    [super onEnter];
    
    // set b2Vec2 bounds (nned to do here as number of trailers is zero during the init phase)
    float upperBound = (_trailerSpriteSizeInMeters.x * self.numberOfTrailers) * 1.01f;
    float lowerBound = _screenB2Vec2Size.x - (_tractorSpriteSizeInMeters.x * 1.02f);
    _bounds = b2Vec2(upperBound, lowerBound);
    //CCLOG(@"TractorNode numberOfTrailers %d upperBounds: %.2f lowerBounds: %.2f", self.numberOfTrailers, _bounds.upper(), _bounds.lower());
    
    // Trailer (position behind tractor)
    if(self.numberOfTrailers > 0)
    {
        [self addTrailerWithTag:TractorTagTrailer1];
    }
    if(self.numberOfTrailers > 1)
    {
        [self addTrailerWithTag:TractorTagTrailer2];
    }
    if(self.numberOfTrailers > 2)
    {
        [self addTrailerWithTag:TractorTagTrailer3];
    }
    
    for (int bnt = (TractorTagTrailer1); bnt <= TractorTagTrailer5; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        if(node)
        {
            [node makeDynamic];
        }
    }
    
    self.body->SetAwake(false);
    
    // attach wheel
    b2RevoluteJointDef motorJointDef;
    motorJointDef.enableMotor = true;
    motorJointDef.motorSpeed = -1.0f;
    motorJointDef.maxMotorTorque = 400;
    
    b2Vec2 wheelcenter = _wheelBackNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    motorJointDef.Initialize(self.body, _wheelBackNode.body, wheelcenter);
    b2Joint *joint = _world->CreateJoint(&motorJointDef);
    _motorJoint = (b2RevoluteJoint*)joint;
    //_wheelBackNode.body->ApplyAngularImpulse(-0.005f);
    
    b2RevoluteJointDef jointDef;
    // attach front wheel
    wheelcenter = _wheelFrontNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y);
    jointDef.Initialize(self.body, _wheelFrontNode.body, wheelcenter);
    _world->CreateJoint(&jointDef);
    _wheelFrontNode.body->ApplyAngularImpulse(-0.005f);
    
    // attach driver
    //b2WeldJointDef weldJoint;
    b2RevoluteJointDef weldJoint;
    b2Vec2 driverCenter = _driverNode.body->GetWorldCenter();
    weldJoint.Initialize(self.body, _driverNode.body, self.body->GetWorldCenter());
    _world->CreateJoint(&weldJoint);
    
    // attach trailers
    float factor = 0.95f;
    float trailerWidth = _trailerSpriteSizeInMeters.x;
    //b2Vec2 prevTrailerAnchor = b2Vec2(0,0);
    b2Vec2 tractorAnchor = self.body->GetWorldCenter();
    TrailerNode *prevTrailerNode = nil;
    for (int bnt = (TractorTagTrailer1); bnt <= TractorTagTrailer5; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        if(node)
        {
            b2RevoluteJointDef jointTrailer;
            jointTrailer.lowerAngle = -0.0625f * b2_pi; // -11.25 degrees
            jointTrailer.upperAngle = 0.0625f * b2_pi; // 11.25 degrees
            jointTrailer.enableLimit = true;
            
            TrailerNode *trailerNode = (TrailerNode*)node;
            b2Vec2 trailerAnchor = trailerNode.body->GetWorldCenter();
            //if(bnt > TractorTagTrailer1)
            //{
            //    tractorAnchor = prevTrailerAnchor;
            //}
            trailerAnchor = b2Vec2(trailerAnchor.x+(trailerWidth/2*factor), trailerAnchor.y); //*1.25f);
            //jointTrailer.Initialize(self.body, trailerNode.body, tractorAnchor, trailerAnchor);
            if(bnt > TractorTagTrailer1)
            {
                jointTrailer.Initialize(prevTrailerNode.body, trailerNode.body, trailerAnchor);
            }
            else
            {
                jointTrailer.Initialize(self.body, trailerNode.body, tractorAnchor);
            }
            _world->CreateJoint(&jointTrailer);
            trailerNode.wheel.body->ApplyAngularImpulse(-0.005f);
            
            //prevTrailerAnchor.x = trailerAnchor.x; //b2Vec2(xpos*0.990, trailerAnchor.y*0.995);
            //prevTrailerAnchor.y = trailerAnchor.y;
            prevTrailerNode = trailerNode;
            trailerNode = nil;
        }
    }
    
    // set initial anchor point and vertices
    anchorPoint_ = _initialAnchorPoint;
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"TractorVertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:@"Tractor"
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

-(void)onExit
{
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(int)checkIfFruitIsInTrailer:(FruitNodeForTree*)fruit
{
    int retVal = -1;
    
    for (int bnt = (TractorTagTrailer1); bnt <= TractorTagTrailer5; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        if(node)
        {
            TrailerNode *trailerNode = (TrailerNode*)node;
            if([fruit isWithinRect:[trailerNode trailerBedRect]])
            {
                [trailerNode increaseFruitCount];
                retVal = trailerNode.tag;
                break;
            }
        }
    }
    
    return retVal;
}

//-(void)updateMotorSpeed:(float)s
//{
//self.body->SetAwake(false);
//_motorJoint->SetMotorSpeed(s); 

/*b2Vec2 pos = self.body->GetPosition();
 b2Vec2 desiredLocation = b2Vec2(pos.x + (s*-1), pos.y);
 b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - pos.x,
 desiredLocation.y - pos.y);
 
 directionToTravel *= 20 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
 
 self.body->SetLinearVelocity(directionToTravel);*/
//}

// receive message
-(void)receiveMessage:(NSString *)m
           floatValue:(float)motorSpeed
          stringValue:(NSString *)sv
{
    if([m isEqualToString:@"initial"])
    {
        _initialSpeed = motorSpeed;
    }
    else
    {
        bool rew = [m isEqualToString:@"rew"];
        bool stop = [m isEqualToString:@"stop"];
        //bool increaseSpeed = [m isEqualToString:@"increaseMotorSpeed"];
        
        _direction = 1;
        if(rew)
        {
            _direction = -1;
        }
        else if(stop)
        {
            _direction = 0;
        }
        
        if (motorSpeed > 5.0f) {
            motorSpeed = 5.0f;
        }
        else if (motorSpeed < -5.0f) {
            motorSpeed = -5.0f;
        }
        
        // scale based on device
        //motorSpeed = (motorSpeed * _scaleFactor);
        
        //[self updatePosition];
        /*float currentSpeed = _motorJoint->GetMotorSpeed();
         float px = self.body->GetPosition().x;
         if(px > _bounds.lower() && _direction == 1) 
         {
         motorSpeed = currentSpeed * -1;
         CCLOG(@"Too right, set motor = %.2f", motorSpeed);
         }
         else if(px < _bounds.upper() && _direction == -1) 
         {
         motorSpeed = currentSpeed * -1;
         CCLOG(@"Too left, set motor = %.2f", motorSpeed);
         }*/
        if (motorSpeed != _prevMotorSpeed) {
            _motorJoint->SetMotorSpeed(motorSpeed);
            _prevMotorSpeed = motorSpeed;
        }
    }
}

-(void)stopMotor
{
    //_motorJoint->SetMotorSpeed(_initialSpeed);
}

-(void)giveImpulseToRight
{
    b2Vec2 position = self.body->GetPosition();
    float px = position.x;
    float py = position.y;
    b2Vec2 desiredLocation = b2Vec2((px+_pixelsToMove), py);
    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                      desiredLocation.y - py);
    directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
    [self stopMotor];
    self.body->SetLinearVelocity(directionToTravel);
    //_tractorNode.body->ApplyLinearImpulse(b2Vec2(2.0f, py), directionToTravel);
}

-(void)updatePosition
{
    b2Vec2 position = self.body->GetPosition();
    float px = position.x;
    float py = position.y;
    
    if(px > _bounds.lower() && _direction == 1) 
    {
        _direction = 0;
    }
    else if(px < _bounds.upper() && _direction == -1) 
    {
        _direction = 0;
    }
    
    if(_prevDirection == _direction)
        return;
    
    b2Vec2 desiredLocation = b2Vec2(px + (_direction * (_pixelsToMove * _tractorSpeed)), py);
    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                      desiredLocation.y - py);
    directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
    
    //CCLOG(@"px: %.2f; upperBounds: %.2f lowerBounds: %.2f direction %d, _pixelsToMove %f directionToTravelx %.2f", px, _bounds.upper(), _bounds.lower(), _direction, _pixelsToMove, directionToTravel.x);
    
    self.body->SetLinearVelocity(directionToTravel);
    _prevDirection = _direction;
}


@end
