//
//  ParticleNode.mm
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParticleNode.h"
#import "WorldHelper.h"
#import "CollisionTypeEnum.h"
#import "DevicePositionHelper.h"


@implementation ParticleNode

@synthesize
    life = _life;

+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n
                life:(float)l
          startScale:(float)ss
            endScale:(float)es
{
    return [[[self alloc] initWithLayer:layer
                               position:p 
                                    tag:t
                                   name:n
                                   life:l
                             startScale:ss
                               endScale:es] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n
              life:(float)l
        startScale:(float)ss
          endScale:(float)es
{
    // hard coded anchor point
    _initialAnchorPoint = cgcenter;
    
    self.collisionType = CollisionTypeHail;
    self.collidesWithTypes = CollisionTypeALL;
    self.maskBits = CollisionTypeALL;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:n];
    s.tag = t;
    s.scale = ss;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.5f;
    fd->friction = 0.1f;
    fd->restitution = 0.1f;
    fd->filter.categoryBits = self.collisionType;
    fd->filter.maskBits = self.maskBits;
    
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
        NSAssert1(_life < 0.5f, @"Life must be at least 0.5", _life);
        
        _fadeinTime = 0.25f;
        _fadeoutTime = 0.25f;
        _startScale = ss;
        _endScale = es;
        // time to live
        _life = l-_fadeinTime-_fadeoutTime;
        _sprite.opacity = 0;
        
        if(_endScale != _startScale)
        {
            _scaleStep = ((_endScale - _startScale) / _life);
        }
        _scaleFactor = (1+_scaleStep/10);
        
        self.collisionType = CollisionTypeHail;
        self.collidesWithTypes = (CollisionTypeFruit | CollisionTypeChain);
        
        [self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"ParticleNode dealloc");
    [self stopAllActions];
	[self unscheduleUpdate];
    
    if(_fadeOutAction)
    {
        [_fadeOutAction release];
        _fadeOutAction = NULL;
    }
    
    [self removeSprite];
    [self destroyFixture];
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    [_sprite runAction:[CCFadeIn actionWithDuration:_fadeinTime]];
}

-(void)onExit
{
    //CCLOG(@"ParticleNode onExit");
    [super onExit];
}

-(void)syncSize
{
    if(_scaleStep != 0)
    {
        _sprite.scale *= _scaleFactor;
    }
}

-(bool)decreaseLife:(float)dt
{
    bool retVal = true;
    _life -= dt;
    
    if(_scaleStep != 0)
    {
        // update shape scale
        b2Fixture *circF = _body->GetFixtureList();
        b2CircleShape *circ = (b2CircleShape *)circF->GetShape();
        circ->m_radius = (circ->m_radius * _scaleFactor);
    }
    
    if(!_fadeOutAction && _life <= 0)
    {
        retVal = false;
        _fadeOutAction = [[_sprite runAction:[CCFadeOut actionWithDuration:_fadeoutTime]] retain];
    }
    return retVal;
}

-(void) update: (ccTime) dt
{
    if([self decreaseLife:dt] && _fadeOutAction)
    {
        if(_fadeOutAction.isDone)
        {
            [self unscheduleUpdate];
            [_fadeOutAction release];
            _fadeOutAction = NULL;
            [self removeFromParentAndCleanup:YES];
        }
    }
}


@end
