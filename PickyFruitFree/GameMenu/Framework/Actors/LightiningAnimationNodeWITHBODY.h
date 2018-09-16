//
//  LightiningAnimationNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BodyNodeWithSprite.h"
#import "CCAnimationHelper.h"
#import "WorldHelper.h"


/*
@interface LightiningAnimationNode : CCSprite 
{
    bool _animationRunning;
}

+(id)bugAnimation;
-(id)initWithBugAnimationImage;
*/

@interface LightiningAnimationNode : BodyNodeWithSprite 
{
    bool _animationRunning;
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

-(void)animateOnce;


@end
