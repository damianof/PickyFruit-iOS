//
//  SceneHelper.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetLayerEnum.h"


@interface SceneHelper : NSObject 
{
}

+(void)menuSceneWithTargetLayer:(TargetLayerEnum)tl
                  useTransition:(bool)useTransition;

+(void)multiLayerSceneWithTargetLayer:(TargetLayerEnum)tl;

+(void)levelLoadingSceneWithTargetLayer:(TargetLayerEnum)tl
                          useTransition:(bool)useTransition;

@end
