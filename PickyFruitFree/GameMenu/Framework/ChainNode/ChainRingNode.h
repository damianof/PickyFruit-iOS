//
//  ChainRingNode.h
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "cocos2d.h"
//#import "Box2D.h"
#import "BodyNodeWithSprite.h"

@class WorldHelper;
@class BodyNodeWithSprite;


@interface ChainRingNode : BodyNodeWithSprite <CCTargetedTouchDelegate> 
{
}


+(id)createWithLayer:(CCLayerWithWorld *)layer
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n
       collisionType:(uint16)ct
   collidesWithTypes:(uint16)cwt
            maskBits:(uint16)mb;

-(id)initWithLayer:(CCLayerWithWorld *)layer
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n
     collisionType:(uint16)ct
 collidesWithTypes:(uint16)cwt
          maskBits:(uint16)mb;


@end
