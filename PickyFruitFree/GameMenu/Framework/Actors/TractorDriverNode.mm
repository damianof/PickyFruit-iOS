//
//  TractorDriverNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/16/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "TractorDriverNode.h"
#import "AnimationManager.h"
#import "DevicePositionHelper.h"
#import "CollisionTypeEnum.h"
#import "CCAnimationHelper.h"


@implementation TractorDriverNode


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
    _currentMouseJoint = NULL;
    
    // hard coded anchor point
    _initialAnchorPoint = cgcenter;
    
    self.collisionType = ct;
    self.collidesWithTypes = cwt;
    self.maskBits = mb;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:n];
    s.tag = t;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = kFloat0;
    fd->friction = kFloat0;
    fd->restitution = kFloat0Point25;
    
    fd->filter.categoryBits = self.collisionType;
    fd->filter.maskBits = mb;
    
    b2CircleShape *shape = new b2CircleShape();
	shape->m_radius = spriteSizeInMeters.x * 0.5f;
    //fd.shape = &shape;
    
    // fruit node has density=2, friction=0.2, restitution=0.2
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:p 
                             sprite:s
                                  z:102
                    spriteFrameName:n  
                                tag:t
                         fixtureDef:fd
                              shape:shape]))
    {
    }
    return self;
}

-(void)dealloc
{   
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    [self makeDynamic];
}

-(void)onExit
{
    [super onExit];
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn 
                 fixt:(b2Fixture*)fixt
            withForce:(float)f 
    withFrictionForce:(float)ff
{
    if (bn.collisionType == CollisionTypeHail
        || bn.collisionType == CollisionTypeFruit)
    {
		[self runDriverHitAnimation];
	}
}

-(void)setAnimationRunningToFalse
{
    _animationRunning = false;
}

-(void)runDriverHitAnimation
{
    //if(_animationRunning == false)
    {
        //_animationRunning = true;
        [_sprite stopAllActions];
        id seq = [AnimationManager tractorDriverHitSequence];
        [_sprite runAction:seq];
        seq = nil;
    }
}

@end
