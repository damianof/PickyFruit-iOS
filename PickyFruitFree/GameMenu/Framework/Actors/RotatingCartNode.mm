//
//  RotatingCartNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "RotatingCartNode.h"
#import "CollisionTypeEnum.h"
#import "ActorInfo.h"

@implementation RotatingCartNode


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
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];

    /*
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.5f;
    fd->friction = 500.0f;
    fd->restitution = 0.25f;
    fd->filter.categoryBits = CollisionTypeFruit;
    b2PolygonShape *shape = new b2PolygonShape();
	//shape->m_radius = spriteSizeInMeters.x * 0.5f;
    float x = self.initialPosition.x-(spriteSizeInMeters.x*0.5f);
    float y = self.initialPosition.y;
    b2Vec2 center = b2Vec2(x, y);
    shape->SetAsBox(spriteSizeInMeters.x*0.5f, spriteSizeInMeters.y*0.5f, center, 0);
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
        _direction = -1;
        
        _pixelsToMove = [DevicePositionHelper pixelsToMove];
        
        _currentAngle = 0.0f;
        _finalAngle = CC_DEGREES_TO_RADIANS(-45);
        float screenWidth = [DevicePositionHelper screenRect].size.width;
        _angleIncrement = (screenWidth / 24000.0f) * [DevicePositionHelper scaleFactor]; //0.005f;
        
        [self scheduleUpdate];
    }
    
    return self;
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
    
    //CCLOG(@"Anchor %f %f", self.anchorPoint.x, self.anchorPoint.y);
    
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
	/*if (bn.collisionType == CollisionTypeFruit) {
        _hasFruit = true;
        //_fruitTouchElapsed += 0.1f;
		//CCLOG(@"RotatingCartNode is being touched by fruit.");
        
        //if(!_flipping && !_reverting)
        { 
            _touchcount++;
            //CCLOG(@"RotatingCartNode is being touched by fruit: direct toward truck %d", _touchcount);
            //CCLOG(@"-");
        }
	}*/
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
    if (bn.collisionType == CollisionTypeFruit) {
        //CCLOG(@"RotatingCartNode is being separated from fruit.");
        _hasFruit = false;
    }
}

-(void)updatePosition
{
    b2Vec2 p = self.body->GetPosition();
    
    //if(_currentAngle >= _finalAngle)
    {
        //CCLOG(@"perform flipping step");
        _currentAngle -= _angleIncrement;
        self.body->SetTransform(p, _currentAngle);
    }
    //else
    //{
    //    //CCLOG(@"end flipping");
    ////    _currentAngle += _angleIncrement;
    //    self.body->SetTransform(p, _currentAngle);
    //}
}


@end
