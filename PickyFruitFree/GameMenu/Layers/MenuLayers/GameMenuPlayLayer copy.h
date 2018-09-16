//
//  GameMenuPlayLayer.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"

@class SceneHelper;
@class DevicePositionHelper;


@interface GameMenuPlayLayer : CCLayer 
{
    CCLabelTTF *_labelTotScore;
    CCLabelTTF *_labelTotStars;
    CCLabelTTF *_labelTotTimesPlayed;
}

-(void)loadGroupLevels:(id)sender;


@end
