//
//  ParallaxNode.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/21/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ParallaxInfo;


@interface ParallaxNode : CCNode 
{
    ParallaxInfo *_info;
    NSString *_framesFileName;
    
    float _speed;
    
    CGRect _screenRect;
    CGPoint _screenCenter;
}

+(id)createWithInfo:(ParallaxInfo*)pi;
-(id)initWithInfo:(ParallaxInfo*)pi;


@end
