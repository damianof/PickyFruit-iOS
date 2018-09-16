//
//  LightiningAnimationNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h" // here we inherit from CCSprite so we need this


@interface LightiningAnimationNode : CCSprite 
{
}

+(id)createWithPosition:(CGPoint)p
                    tag:(int)t 
                   name:(NSString *)n;

-(id)initWithPosition:(CGPoint)p 
                  tag:(int)t 
                 name:(NSString *)n;

-(void)animateOnce;


@end
