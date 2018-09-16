//
//  HorizCartNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "HorizCartNode.h"
#import "CollisionTypeEnum.h"
#import "ActorInfo.h"


@implementation HorizCartNode

//@synthesize 
//    unitsBounds = _unitsBounds,
//    bounds = _bounds;

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
    
    // anchor point to be used for both sprite and Box2d
    _initialAnchorPoint = info.anchorPoint;
    
    //_unitsBounds = ub;
    //_bounds = [DevicePositionHelper b2Vec2FromUnitsBounds:_unitsBounds];
    // this actor also needs a UnitsBound parameter:
    [self setUnitsBounds:info.unitsBounds];
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    
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
        _direction = -1;
        
        _pixelsToMove = [DevicePositionHelper pixelsToMove];
        
        // flipping properties
        _flipping = false;
        _currentAngle = 0.0f;
        _finalAngle = CC_DEGREES_TO_RADIANS(-45);
        
        float screenWidth = [DevicePositionHelper screenRect].size.width;
        _angleIncrement = (screenWidth / 24000.0f) * [DevicePositionHelper scaleFactor]; //0.005f;
        _revertIncrement = (screenWidth / 6000.0f) * [DevicePositionHelper scaleFactor]; //0.02f;
        
        //[self scheduleUpdate];
    }
    
    return self;
}

-(void)setUnitsBounds:(UnitsBounds)ub
{
    _unitsBounds = ub;
    _bounds = [DevicePositionHelper b2Vec2FromUnitsBounds:_unitsBounds];
}

-(void)update:(float)dt
{
    //_elapsed += dt;
    //[self updatePosition];
}

-(void)dealloc
{
    [self stopAllActions];
	[self unscheduleAllSelectors];
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    CCLOG(@"Anchor %f %f", self.anchorPoint.x, self.anchorPoint.y);
    
    anchorPoint_ = _initialAnchorPoint;
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"ObstaclesVertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:_spriteFrameName
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

-(void)onExit
{
    //[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)receiveMessage:(NSString *)m
           floatValue:(float)fv
          stringValue:(NSString *)sv
{
    //bool reduceSpeed = [m isEqualToString:@"reduceMotorSpeed"];
    //bool increaseSpeed = [m isEqualToString:@"increaseMotorSpeed"];
    
    /*int direction = -1;
    if(reduceSpeed)
    {
        direction = 1;
    }*/
    
    [self updatePosition];
    
    /*// make value relative to screen resolution
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
     [self updateMotorSpeed:_tractorSpeed];*/
}


-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
    //CCLOG(@"HorizCartNode overlapped by type %@ %i %i.", bn.typeName, bn.tag, bn.collisionType);
	if (bn.collisionType == CollisionTypeFruit) {
        _hasFruit = true;
        //_fruitTouchElapsed += 0.1f;
		//CCLOG(@"HorizCartNode is being touched by fruit.");
        
        float top = self.body->GetPosition().y - self.spriteSizeInMeters.y;
        float bntop = bn.body->GetPosition().y - bn.spriteSizeInMeters.y;
        
        if (bntop >= top)
            //if(!_flipping && !_reverting)
        { 
            _touchcount++;
            CCLOG(@"HorizCartNode touched tops: %f %f ", top, bntop);
            CCLOG(@"-");
            _direction = 1; // send towards truck
            _flipping = false;
            _reverting = false;
        }
	}
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
    if (bn.collisionType == CollisionTypeFruit) {
        //CCLOG(@"HorizCartNode is being separated from fruit.");
        _hasFruit = false;
    }
}

-(void)updatePosition
{
    b2Vec2 position = self.body->GetPosition();
    //b2Vec2 position = _anchorBody->GetPosition();
    float px = position.x;
    float py = position.y;
    
    //CCLOG(@"px: %.2f; upperBounds: %.2f lowerBounds: %.2f; flipping: %d; reverting: %d", px, _upperBounds, _lowerBounds, _flipping, _reverting);
    if(px >= _bounds.lower()) 
    {
        px  = _bounds.lower();
        //if(_fruitTouchElapsed > 1)
        {
            [self performFlip];
        }
        //else
        //{
        //    self.body->SetTransform(position, 0);
        //    _flipping = false;
        //    _reverting = false;
        //}
        _direction = -1;
    }
    else if(px <= _bounds.upper()) 
    {
        _reverting = false;
        _flipping = false;
        px  = _bounds.upper();
        _direction = 1;
    }
    
    if(!_flipping && !_reverting)
    {
        //CCLOG(@"direction %d, _pixelsToMove %f", _direction, _pixelsToMove);
        
        b2Vec2 desiredLocation = b2Vec2(px + (_direction * _pixelsToMove), py);
        b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                          desiredLocation.y - py);
        
        directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
        
        //CCLOG(@"SetupOscillation %f %f; %f %f", _upperBounds, _lowerBounds, position.x, directionToTravel.x);
        _lastPositionX = px;
        self.body->SetLinearVelocity(directionToTravel);
        //_anchorBody->SetLinearVelocity(directionToTravel);
    }
}

-(void)performFlip
{
    _flipping = true;
    
    b2Vec2 p = self.body->GetPosition();
    p = b2Vec2(_bounds.lower(), p.y);
    
    if(!_reverting && _currentAngle >= _finalAngle)
    {
        //CCLOG(@"perform flipping step");
        _currentAngle -= _angleIncrement;
        self.body->SetTransform(p, _currentAngle);
    }
    else
    {
        //CCLOG(@"end flipping");
        _flipping = false;
        [self revertFlip:p];
    }
}

-(void)revertFlip:(b2Vec2)p
{
    _reverting = true;
    _flipping = false;
    
    if(_currentAngle < 0)
    {
        //CCLOG(@"perform revert step");
        _currentAngle += _revertIncrement;
        if(_currentAngle > 0)
        {
            _currentAngle = 0;
        }
        //self.body->SetAngularVelocity(_currentAngle);
        self.body->SetTransform(p, _currentAngle);
    }
    else
    {
        //CCLOG(@"end revert");
        _currentAngle = 0;
        self.body->SetTransform(p, _currentAngle);
        _reverting = false;
    }
}


@end
