//
//  WorldSetup.h
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "DevicePositionHelper.h"


@interface WorldSetup : CCNode 
{
    b2World *_world;
    b2Body *_groundBody;
    
    int _unitsYOffset; 
    int _unitsFromEdge;
}

@property (nonatomic, readonly) b2Body *groundBody;

+(id)setupWorldWithWorld:(b2World *)w
            unitsYOffset:(int)uyo 
           unitsFromEdge:(int)ufe;

-(id)initWorldWithWorld:(b2World *)w
           unitsYOffset:(int)uyo 
          unitsFromEdge:(int)ufe;

-(void)createStaticBodies;

-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
                            numVertices:(int)nv
                          pointPosition:(CGPoint)p;

-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
                            numVertices:(int)nv
                         b2Vec2Position:(b2Vec2)p;

-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
                            numVertices:(int)nv
                          unitsPosition:(UnitsPoint)up;

@end
