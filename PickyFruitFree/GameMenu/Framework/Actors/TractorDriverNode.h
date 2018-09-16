//
//  TractorDriverNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/16/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BodyNodeWithSprite.h"
#import "ActorProtocol.h"


@interface TractorDriverNode : BodyNodeWithSprite 
{
    bool _animationRunning;
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

-(void)runDriverHitAnimation;
-(void)setAnimationRunningToFalse;

@end
