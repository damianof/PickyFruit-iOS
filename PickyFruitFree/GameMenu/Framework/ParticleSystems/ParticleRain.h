/*//
//  ParticleRain.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"


@interface ParticleRain : CCParticleSystemQuad 
{
    b2World* _world;
    b2Body* _groundBody;
}

@property (nonatomic, readonly) b2World *world;
@property (nonatomic, readonly) b2Body *groundBody;

+(ParticleRain *)createWithWorld:(b2World*)w
                    groundBody:(b2Body*)gb;

-(void)setWorld:(b2World *)w 
  andGroundBody:(b2Body*)gb;

//-(tCCParticle *)getParticleAtIndex:(int)i;


@end*/
