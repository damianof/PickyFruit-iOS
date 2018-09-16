//
//  SceneHelper.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "SceneHelper.h"
#import "GameMenuScene.h"
#import "MultiLayerScene.h"
#import "LoadingScene.h"
#import "LevelLoadingScene.h"

@implementation SceneHelper


+(void)menuSceneWithTargetLayer:(TargetLayerEnum)tl
                  useTransition:(bool)useTransition
{
    GameMenuScene *scene = [GameMenuScene sceneWithTargetLayer:tl]; // i.e. TargetLayerMenuGroupLevels
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:1.0f scene:scene]];
    [[CCDirector sharedDirector] replaceScene:scene];
    scene = nil;
}

+(void)multiLayerSceneWithTargetLayer:(TargetLayerEnum)tl
{
    MultiLayerScene *scene = [LoadingScene sceneWithTargetScene:TargetSceneMultiLayer
                                                 andTargetLayer:tl];
    [[CCDirector sharedDirector] replaceScene:scene];
    scene = nil;
}

// following is similar to multiLayerSceneWithTargetLayer
// but used to load levels and display level goal before level play starts
+(void)levelLoadingSceneWithTargetLayer:(TargetLayerEnum)tl
                          useTransition:(bool)useTransition
{
    MultiLayerScene *scene = [LevelLoadingScene sceneWithTargetScene:TargetSceneMultiLayer
                                                      andTargetLayer:tl];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:1.0f scene:scene]];
    [[CCDirector sharedDirector] replaceScene:scene];
    scene = nil;
}


@end
