//
//  LoadingScene.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"
#import "TargetSceneEnum.h"
#import "TargetLayerEnum.h"
#import "DevicePositionHelper.h"

#import "GameMenuScene.h"
#import "MultiLayerScene.h"


// loading scene is derived directly from Scene.
// DOn't need a CCLayer for this scene
@interface LoadingScene : CCScene 
{
    TargetSceneEnum _targetScene;
    TargetLayerEnum _targetLayer;
    float _timeElapsedFromStart;
}

+(id)sceneWithTargetScene:(TargetSceneEnum)targetScene 
           andTargetLayer:(TargetLayerEnum)targetLayer;

-(id)initWithTargetScene:(TargetSceneEnum)targetScene 
          andTargetLayer:(TargetLayerEnum)targetLayer;

-(void)selectScene;

@end
