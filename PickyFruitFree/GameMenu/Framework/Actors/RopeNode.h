//
//  RopeNode.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BodyNode.h"
#import "RopePartNode.h"


@class BodyNode;
@class RopePartNode;


@interface RopeNode : CCNode
{
    b2World *_world;
    b2Body *_groundBody;
    
    b2Vec2 _initialPosition;
    
    b2Vec2 _spriteSizeInMeters;
    NSString *_spriteFrameName;
    int _parts;
    bool _isLoose;
    bool _created;
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
            position:(b2Vec2)ip
     spriteFrameName:(NSString *)sfn
               parts:(int)p
                 tag:(int)t
             isLoose:(bool)il;

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb
          position:(b2Vec2)ip
   spriteFrameName:(NSString *)sfn
             parts:(int)p
               tag:(int)t
           isLoose:(bool)il;

-(void)createRopeParts;

@end

