//
//  ParticleSystemWithBox2D.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/17/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "DevicePositionHelper.h"
#import "ParticleNode.h"
#import "MathHelper.h"

@class CCLayerWithWorld;


@interface ParticleSystemWithBox2D : CCNode 
{
    CCLayerWithWorld *_layer;
    b2World *_world;
    b2Body *_groundBody;
    
    b2Vec2 _b2Vec2Position;
    
    b2Vec2 _particleSizeInMeters;
    NSString *_spriteFrameName;
    bool _created;
    
    uint16 _collisionType, _collidesWithType; 
    
    // Total particles
	int _totalParticles;
    // Count of active particles
	int _particleCount;
    //  particle idx
	int _particleIdx;
    
    // is the particle system active ?
	bool _isActive;
    // time elapsed since the start of the system (in seconds)
	float _elapsed;
    
    float _particleLife;
    float _startScale;
    float _endScale;
    
    b2Vec2 _screenB2Vec2Size;
    float _offsetX1ForOutsideScreen;
    float _offsetY1ForOutsideScreen;
    float _offsetX2ForOutsideScreen;
    float _offsetY2ForOutsideScreen;
    
    // How many particles can be emitted per second
	float _emissionRate;
    float _emitCounter;
}

@property (nonatomic, readwrite) uint16 collisionType;
@property (nonatomic, readwrite) uint16 collidesWithType;
@property (nonatomic, readwrite) float emissionRate;
@property (nonatomic, readwrite) bool isActive;
@property (nonatomic, readwrite) float offsetX1ForOutsideScreen;
@property (nonatomic, readwrite) float offsetY1ForOutsideScreen;
@property (nonatomic, readwrite) float offsetX2ForOutsideScreen;
@property (nonatomic, readwrite) float offsetY2ForOutsideScreen;

@property (nonatomic, readonly) b2Vec2 b2Vec2Position;
@property (nonatomic, readonly) bool isOutsideScreen;

-(void)setB2Vec2Position:(b2Vec2)p;

+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)ip
     spriteFrameName:(NSString *)sfn
           particles:(int)p
        particleLife:(float)pl
          startScale:(float)ss
            endScale:(float)es
        emissionRate:(float)er
                 tag:(int)t;

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)ip
   spriteFrameName:(NSString *)sfn
         particles:(int)p
      particleLife:(float)pl
        startScale:(float)ss
          endScale:(float)es
      emissionRate:(float)er
               tag:(int)t;

-(void)createParticles;

-(bool)addParticle;

-(ParticleNode *)initParticle;



@end
