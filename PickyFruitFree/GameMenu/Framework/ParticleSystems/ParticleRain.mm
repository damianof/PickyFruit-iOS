/*//
//  ParticleRain.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParticleRain.h"
#import "CollisionTypeEnum.h"


@implementation ParticleRain

@synthesize 
    world = _world,
    groundBody = _groundBody;


+(ParticleRain *)createWithWorld:(b2World*)w
                      groundBody:(b2Body*)gb
{
    ParticleRain *system = [ParticleRain particleWithFile:@"Hail.plist"];
    [system setWorld:w andGroundBody:gb];
    system.gravity = CGPointMake(0,-25);
    system.totalParticles = 1;
    return system;
}

-(void)setWorld:(b2World *)w 
  andGroundBody:(b2Body*)gb
{
    _world = w;
    _groundBody = gb;
}*/

/*-(tCCParticle *)getParticleAtIndex:(int)i
{
    return &self.particles[i];
}*/


/*-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
    
    if( (self=[super initWithTotalParticles:numberOfParticles]) ) 
    {
        
    }
    
    return self;
}

-(void) initParticle: (tCCParticle*) particle
{
    [super initParticle:particle];
    
    CGPoint partPos = particle->pos;
    b2Vec2 pos = [DevicePositionHelper b2Vec2FromPoint:partPos];
    
    FruitNode *fruit = [FruitNode createWithWorld:self.world
                                       groundBody:self.groundBody
                                         position:pos  
                                              tag:88888 
                                             name:@"Raspberry-32"];
    
    fruit.collisionType = kFruitCollisionType;
	fruit.collidesWithType = kFruitCollisionType | kChainCollisionType;

    [self.parent addChild:fruit z:5 tag:88888];
    
    particle->userData = fruit;
}

-(void) update: (ccTime) dt
{
    [super update:dt];
    
    int index = -1;
    while(++index < particleCount )
	{
		tCCParticle *part = &particles[particleIdx];
        if( part->timeToLive > 0 ) 
        {
            CGPoint partPos = part->pos;
            b2Vec2 ps = [DevicePositionHelper b2Vec2FromPoint:partPos];
            
            FruitNode *fruit = (FruitNode *)part->userData;
            //b2Vec2 bp = [fruit getBodyPosition];
            fruit.body->SetTransform(ps,0);
            //[fruit syncPositionAndRotation];
        }
        else
        {
            CCLOG(@"Remove from parent");
            //CCNode *node = (CCNode *)part->userData;
            //[node removeFromParentAndCleanup:YES];
        }
    }
}


@end
*/
