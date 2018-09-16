//
//  GameMenuPlayLayer.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"

@class GameGroup;
@class GameLevel;


@interface GameMenuLevelsLayer : CCLayerGradient 
{
    int _tagTouched;
    CCSprite *_spriteTouched;
}


-(void)buttonBackTapped;
-(void)buttonLevelTapped:(id)sender;

@end
