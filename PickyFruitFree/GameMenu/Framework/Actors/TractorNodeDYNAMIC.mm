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
motorJoint = _motorJoint,
numberOfTrailers = _numberOfTrailers;


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
    
    /*CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    if([info.imageFormat isEqualToString:kImageFormatPvrCcz])
    {
        CCSpriteBatchNode *spritesBgNode = [CCSpriteBatchNode batchNodeWithFile:info.framesFileName];
        [self addChild:spritesBgNode];   
    }
    [frameCache addSpriteFramesWithFile:info.framesFileName];*/
    
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
        _tractorSpeed = 0;
        
        _screenWidth = [DevicePositionHelper screenRect].size.width;
        
        // need to slightly increase left side offset
        // so that is not considered offscreen when just simply touching the left border
        self.offsetX1ForOutsideScreen = -0.1f;
        
        //_trailerNodes = [[NSMutableArray arrayWithCapacity:5] retain];
        
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
        wheelY = _initialPosition.y + (_spriteSizeInMeters.y * 0.50f) - offset -0.05f;
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
    CCSprite *trailerSprite = [CCSprite spriteWithSpriteFrameName:@"Trailer"];
    b2Vec2 trailerSpriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:trailerSprite.boundingBox.size];
    
    ActorInfo* trailerInfo = [self getInfoForTrailer:trailerTag];
    
    // Trailer (position behind tractor)
    float factor = 0.93f;
    float xpos = (_initialPosition.x-(trailerSpriteSizeInMeters.x*trailerTag*factor));
    b2Vec2 trailerPosition = b2Vec2(xpos, _initialPosition.y*1.05f);
    TrailerNode *trailerNode = [TrailerNode createWithLayer:_layer
                                                       info:trailerInfo
                                            initialPosition:trailerPosition];
    //_trailerNode.sprite.opacity = 0;
    [self addChild:trailerNode z:trailerInfo.z tag:trailerInfo.tag];
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
    //CCLOG(@"TractorNode dealloc");
    
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    
    [_info release];
    
    _driverNode = nil;
    _wheelBackNode = nil;
    _wheelFrontNode = nil;
    
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
        _wheelFrontNode.sprite.opacity = 255;
    }
}

-(void)syncSize
{
    
}

-(void)onEnter
{
    _sprite.opacity = 255;
    [super onEnter];
    
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
    motorJointDef.motorSpeed = 0;
    motorJointDef.maxMotorTorque = 400;
    
    b2Vec2 wheelcenter = _wheelBackNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    motorJointDef.Initialize(self.body, _wheelBackNode.body, wheelcenter);
    b2Joint *joint = _world->CreateJoint(&motorJointDef);
    _motorJoint = (b2RevoluteJoint*)joint;
    
    b2RevoluteJointDef jointDef;
    
    // attach front wheel
    wheelcenter = _wheelFrontNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y);
    jointDef.Initialize(self.body, _wheelFrontNode.body, wheelcenter);
    _world->CreateJoint(&jointDef);
    
    // attach driver
    b2WeldJointDef weldJoint;
    b2Vec2 driverCenter = _driverNode.body->GetWorldCenter();
    weldJoint.Initialize(self.body, _driverNode.body, driverCenter);
    _world->CreateJoint(&weldJoint);
    
    // attach trailers
    float factor = 0.95f;
    //b2DistanceJointDef distanceJointDef;
    b2RevoluteJointDef distanceJointDef;
    b2Vec2 prevTrailerAnchor = b2Vec2(0,0);
    b2Vec2 tractorAnchor = self.body->GetWorldCenter();
    for (int bnt = (TractorTagTrailer1); bnt <= TractorTagTrailer5; bnt++) 
    {
        BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
        if(node)
        {
            TrailerNode *trailerNode = (TrailerNode*)node;
            b2Vec2 trailerAnchor = trailerNode.body->GetWorldCenter();
            if(bnt > 1)
            {
                tractorAnchor = prevTrailerAnchor;
            }
            float trailerWidth = [DevicePositionHelper b2Vec2FromSize:trailerNode.sprite.boundingBox.size].x;
            trailerAnchor = b2Vec2(trailerAnchor.x+(trailerWidth/2*factor), trailerAnchor.y);
            //distanceJointDef.Initialize(self.body, trailerNode.body, tractorAnchor, trailerAnchor);
            distanceJointDef.Initialize(self.body, trailerNode.body, tractorAnchor);
            _world->CreateJoint(&distanceJointDef);
            
            //float xpos = [DevicePositionHelper b2Vec2FromPoint:trailerNode.sprite.boundingBox.origin].x;
            prevTrailerAnchor = trailerAnchor; //b2Vec2(xpos*0.990, trailerAnchor.y*0.995);
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
    
    //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
    //                                                 priority:0 
    //                                          swallowsTouches:NO];
}

-(void)onExit
{
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
                retVal = trailerNode.tag;
                break;
            }
        }
    }
    
    return retVal;
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

// receive message
-(void)receiveMessage:(NSString *)m
           floatValue:(float)fv
          stringValue:(NSString *)sv
{
    bool reduceSpeed = [m isEqualToString:@"reduceMotorSpeed"];
    //bool increaseSpeed = [m isEqualToString:@"increaseMotorSpeed"];
    
    int direction = -1;
    if(reduceSpeed)
    {
        direction = 1;
    }
    
    // make value relative to screen resolution
    fv *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
    //fv = fv * _screenWidth / 100;
    
    _tractorSpeed += (fv * direction);
    
    if(_tractorSpeed > 4)
    {
        _tractorSpeed = 4;
    }
    else if(_tractorSpeed < -4)
    {
        _tractorSpeed = -4;
    }
    [self updateMotorSpeed:_tractorSpeed];
    
    /*
    b2Vec2 position = self.body->GetPosition();
    float px = position.x;
    float py = position.y;
    float pixelsToMove = fv * [DevicePositionHelper pixelsToMove];
    b2Vec2 desiredLocation = b2Vec2(px + (direction * pixelsToMove), py);
    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                      desiredLocation.y - py);
    directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
    self.body->SetLinearVelocity(directionToTravel);
    */
}

@end
