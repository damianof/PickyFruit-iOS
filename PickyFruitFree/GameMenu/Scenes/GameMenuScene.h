//
//  GameMenuScene.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TargetLayerEnum.h"


@interface GameMenuScene : CCScene 
{
    CCLayer *_menuLayer;
}

+(id)sceneWithTargetLayer:(TargetLayerEnum)tl;
-(id)initWithTargetLayer:(TargetLayerEnum)tl;


@end
