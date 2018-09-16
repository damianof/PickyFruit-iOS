//
//  VertCartNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "VertCartNode.h"
#import "CollisionTypeEnum.h"
#import "ActorInfo.h"


@implementation VertCartNode

//@synthesize 
    //unitsBounds = _unitsBounds;

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
    
    // set anchor point
    _initialAnchorPoint = info.anchorPoint;
    
    //_unitsBounds = ub;
    //_bounds = [DevicePositionHelper b2Vec2FromUnitsBounds:_unitsBounds];
    // this actor also needs a UnitsBound parameter:
    // in this case, need to take in account unitsYOffset
    int upperBound = info.unitsPosition.y + info.unitsBounds.upper;
    int lowerBound = info.unitsPosition.y + info.unitsBounds.lower;
    UnitsBounds ub = UnitsBoundsMake(upperBound, lowerBound);
    [self setUnitsBounds:ub];
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    //[s setAnchorPoint:ap];
    s.tag = info.tag;
    
    // 
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
        _finalAngle = CC_DEGREES_TO_RADIANS(-55);
        
        float screenHeight = [DevicePositionHelper screenRect].size.height;
        _angleIncrement = (screenHeight / 24000.0f) * [DevicePositionHelper scaleFactor]; //0.005f;
        _revertIncrement = (screenHeight / 6000.0f) * [DevicePositionHelper scaleFactor]; //0.02f;
        
        [self scheduleUpdate];
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
    _elapsed += dt;
    [self updatePosition];
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

-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
	if (bn.collisionType == CollisionTypeFruit) {
        _hasFruit = true;
        //_fruitTouchElapsed += 0.1f;
		//CCLOG(@"VertCartNode is being touched by fruit.");
        
        float top = self.body->GetPosition().y - self.spriteSizeInMeters.y;
        float bntop = bn.body->GetPosition().y - bn.spriteSizeInMeters.y;
        
        if (bntop >= top)
        //if(!_flipping && !_reverting)
        { 
            _touchcount++;
            CCLOG(@"VertCartNode touched tops: %f %f ", top, bntop);
            CCLOG(@"-");
            _direction = 1; // send towards top
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
    float px = position.x;
    float py = position.y;
    
    //CCLOG(@"VertCartNode: direc %d py: %.2f; top: %.2f bottom: %.2f; flip: %d; revert: %d", _direction, py, _upperBounds, _lowerBounds, _flipping, _reverting);
    if(py <= _bounds.lower())
    {
        _reverting = false;
        _flipping = false;
        py  = _bounds.lower();
        _direction = 1;
    }
    else if(py >= _bounds.upper()) 
    {
        py  = _bounds.upper();
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
    
    if(!_flipping && !_reverting)
    {
        //CCLOG(@"VertCartNode: direction %d, _pixelsToMove %f", _direction, _pixelsToMove);
        
        b2Vec2 desiredLocation = b2Vec2(px, py + (_direction * _pixelsToMove));
        b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                          desiredLocation.y - py);
        
        directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
        
        //CCLOG(@"UpdatePosition %f %f; %f %f", _leftBounds, _rightBounds, position.x, directionToTravel.x);
        _lastPositionY = py;
        self.body->SetLinearVelocity(directionToTravel);
    }
}

-(void)performFlip
{
    _flipping = true;
    
    b2Vec2 p = self.body->GetPosition();
    p = b2Vec2(p.x, _bounds.upper());
    
    if(!_reverting && _currentAngle >= _finalAngle)
    {
        //CCLOG(@"perform flipping step");
        _currentAngle -= _angleIncrement;
        self.body->SetTransform(p, _currentAngle);
    }
    else
    {
        //CCLOG(@"end flipping");
        //_direction = -1;
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
