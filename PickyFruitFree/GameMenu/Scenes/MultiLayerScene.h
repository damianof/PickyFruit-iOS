//
//  MultiLayerScene.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"
#import "TargetLayerEnum.h"

@class CCLayerWithWorld;


@interface MultiLayerScene : CCScene 
{
}

+(id)sceneWithTargetLayer:(TargetLayerEnum)tl;
-(id)initWithTargetLayer:(TargetLayerEnum)tl;

-(CCLayerWithWorld*)replaceTargetLayer:(TargetLayerEnum)tl;


@end
