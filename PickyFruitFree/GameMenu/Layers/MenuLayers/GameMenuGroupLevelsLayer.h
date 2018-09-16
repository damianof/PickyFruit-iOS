//
//  GameMenuPlayLayer.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class GameGroup;
@class MenuScroll;


@interface GameMenuGroupLevelsLayer : CCLayerGradient 
{
    MenuScroll *_scroller;
    
    int _tagTouched;
    CCSprite *_spriteTouched;
}

-(void)buttonBackTapped;
-(void)buttonLevelGroupTapped:(id)sender;


@end
