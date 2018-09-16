//
//  ParticleNode.h
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BodyNodeWithSprite.h"

@class WorldHelper;


@interface ParticleNode : BodyNodeWithSprite 
{
    // for particles
    float _life;
    float _fadeinTime;
    float _fadeoutTime;
    
    float _startScale;
    float _endScale;
    float _scaleStep;
    float _scaleFactor;
    
    CCAction *_fadeOutAction;
}

// time to live
@property (nonatomic, readonly) float life;

+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n
                life:(float)l
          startScale:(float)ss
            endScale:(float)es;

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n
              life:(float)l
        startScale:(float)ss
          endScale:(float)es;

-(bool)decreaseLife:(float)dt;


@end
