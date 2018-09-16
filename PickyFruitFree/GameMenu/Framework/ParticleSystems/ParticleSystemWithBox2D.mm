//
//  ParticleSystemWithBox2D.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/17/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParticleSystemWithBox2D.h"
#import "CCLayerWithWorld.h"


@implementation ParticleSystemWithBox2D


@synthesize 
    b2Vec2Position = _b2Vec2Position,
    collisionType = _collisionType,
    collidesWithType = _collidesWithType,
    emissionRate = _emissionRate,
    isActive = _isActive,
    offsetX1ForOutsideScreen = _offsetX1ForOutsideScreen,
    offsetY1ForOutsideScreen = _offsetY1ForOutsideScreen,
    offsetX2ForOutsideScreen = _offsetX2ForOutsideScreen,
    offsetY2ForOutsideScreen = _offsetY2ForOutsideScreen;

-(void)setB2Vec2Position:(b2Vec2)p
{
    _b2Vec2Position = p;
}

-(bool)isOutsideScreen
{
    bool retVal = 
    _b2Vec2Position.x < (0 + _offsetX1ForOutsideScreen)
    || 
    _b2Vec2Position.y < (0 + _offsetY1ForOutsideScreen);
    
    if(retVal == false)
    {
        retVal = 
        _b2Vec2Position.x > (_screenB2Vec2Size.x + _offsetX2ForOutsideScreen)
        || 
        _b2Vec2Position.y > (_screenB2Vec2Size.y + _offsetY2ForOutsideScreen);
    }
    return retVal;
}

+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)ip
     spriteFrameName:(NSString *)sfn
           particles:(int)p
        particleLife:(float)pl
          startScale:(float)ss
            endScale:(float)es
        emissionRate:(float)er
                 tag:(int)t
{
    return [[[self alloc] initWithLayer:layer
                               position:ip
                        spriteFrameName:sfn
                              particles:p
                           particleLife:pl
                             startScale:ss
                               endScale:es
                           emissionRate:er
                                    tag:t] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)ip
   spriteFrameName:(NSString *)sfn
         particles:(int)p
      particleLife:(float)pl
        startScale:(float)ss
          endScale:(float)es
      emissionRate:(float)er
               tag:(int)t
{
    if((self = [super init]))
    {
        _layer = layer;

        self.tag = t;
        _world = layer.world;
        _groundBody = layer.groundBody;
        _b2Vec2Position = ip;
        _spriteFrameName = sfn;
        _totalParticles = p;
        _particleIdx = 0;
        _particleCount = 0;
        
        _particleLife = pl;
        _startScale = ss;
        _endScale = es;
        
        // particles per second
        _emissionRate = er;
        _isActive = false;
        
        _screenB2Vec2Size = [DevicePositionHelper screenB2Vec2Size];
        //_emissionRate = _totalParticles/_particleLife;
        
        // temp sprite to get the dimensions
        // ...
        CGSize sz = CGSizeMake(16,16);
        _particleSizeInMeters = [DevicePositionHelper b2Vec2FromSize:sz];
        
        [self scheduleUpdate];
        
    }
    return self;
}

-(void)removeBodies
{
    //[self removeChild:[self getChildByTag:kTagMenuLevels] cleanup:YES];
    /*ChainRingNode *ringNode;
     CCARRAY_FOREACH(_ringNodes, ringNode) 
     {
     if(ringNode != NULL)
     {
     [ringNode release];
     //_world->DestroyBody(ringNode.bodyNode.body);
     }
     }*/
    
    for (int i = 1; i <= _totalParticles; i++) 
    {
        int bnt = (i + self.tag);
        [self removeChildByTag:bnt cleanup:YES];
    }
}

-(void)dealloc
{
    //CCLOG(@"ParticleSystemWithBox2D %d dealloc", self.tag);
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    //if(_created == false)
    //{
    //    [self createParticles];
    //}
}

-(void)onExit
{
    [super onExit];  
}

-(void)createParticles
{
    int i = 0;
    while(++i <= _totalParticles)
    {
        int bnt = (i + self.tag);
        ParticleNode *particleNode = [ParticleNode createWithLayer:_layer
                                                          position:_b2Vec2Position
                                                               tag:bnt
                                                              name:_spriteFrameName
                                                              life:_particleLife
                                                        startScale:_startScale
                                                          endScale:_endScale];
        
        [self addChild:particleNode z:0 tag:bnt];
        [particleNode makeDynamic];
    }
    _created = true;
}

-(void) update: (ccTime) dt
{
    if( _isActive && _emissionRate > 0) 
    {
		float rate = 1.0f / _emissionRate;
		_emitCounter += dt;
		while( _particleCount < _totalParticles && _emitCounter > rate ) 
        {
			[self addParticle];
			_emitCounter -= rate;
		}
		
		_elapsed += dt;
		//if(duration != -1 && duration < elapsed)
        //{
		//	[self stopSystem];
        //}
	}
    
    _particleIdx = 0;
 
    while( _particleIdx < _particleCount )
	{
		//tCCParticle *p = &particles[particleIdx];
        CCNode *node = [self getChildByTag:(_particleIdx + 1 + self.tag)];
        if(node)
        {
            _particleIdx++;
        }
        else
        {
            _particleCount--;
        }
        
		// life
		//p.timeToLive -= dt;
        
        /*bool isAlive = [p decreaseTimeToLive:dt];
        
        if( isAlive ) 
        {
            _particleIdx++;
        }
        else
        {
            _particleCount--;
        }*/

		/*if( p.timeToLive > 0 ) 
        {
			// update particle counter
			_particleIdx++;
		} 
        else 
        {
			// life < 0
			//if( _particleIdx != _particleCount-1 )
            {
				//particles[particleIdx] = particles[particleCount-1];
                [p removeFromParentAndCleanup:YES];
            }
			_particleCount--;
			
			//if( _particleCount == 0 && autoRemoveOnFinish_ ) {
			//	[self unscheduleUpdate];
			//	[parent_ removeChild:self cleanup:YES];
			//	return;
			//}
		}*/
	}
}

-(bool) addParticle
{
	if( _particleCount == _totalParticles)
    {
        //CCLOG(@"addParticle: particle count equal to total, return false");
		return false;
    }
	
	//tCCParticle * particle = &particles[ particleCount ];
    
	ParticleNode *particleNode = [self initParticle];
    [self addChild:particleNode z:0 tag:particleNode.tag];
    [particleNode makeDynamic];
    _particleCount++;

	return true;
}

-(ParticleNode *)initParticle
{
    int bnt = (_particleCount + 1 + self.tag);
    ParticleNode *particleNode = [ParticleNode createWithLayer:_layer
                                                      position:self.b2Vec2Position
                                                           tag:bnt
                                                          name:_spriteFrameName
                                                          life:_particleLife
                                                    startScale:_startScale
                                                      endScale:_endScale];
    return particleNode;
}

@end
