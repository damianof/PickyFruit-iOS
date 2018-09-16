//
//  RopePartNode.h
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BodyNodeWithSprite.h"
#import "WorldHelper.h"


@class BodyNodeWithSprite;


@interface RopePartNode : BodyNodeWithSprite <CCTargetedTouchDelegate> 
{
}


+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n;

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n;


@end
