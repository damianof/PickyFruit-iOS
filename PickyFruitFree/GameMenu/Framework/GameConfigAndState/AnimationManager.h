//
//  AnimationManager.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/19/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimationManager : NSObject
{
    
}

+(AnimationManager *)sharedAnimationManager;
+(CCSequence *)tractorDriverHitSequence;
+(id)create;
+(void)cleanup;
-(void)setupAnimations;

@end