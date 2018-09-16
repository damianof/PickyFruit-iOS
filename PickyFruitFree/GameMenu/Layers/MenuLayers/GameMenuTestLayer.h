//
//  GameMenuTestLayer.h
//
//  Created by Damiano Fusco on 1/21/12.
//  Copyright 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"

@class SceneHelper;
@class DevicePositionHelper;


@interface GameMenuTestLayer : CCLayer 
{
    CGSize _screenSize;
    CGPoint _screenCenter;
    
    CCLabelTTF *_labelDebug;
}

-(void)backToMain;
//-(void)performTest:(id)menuItem;

@end
