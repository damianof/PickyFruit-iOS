//
//  AppDelegate.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright Shallow Waters Group LLC 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "GameConfig.h"
#import "TargetLayerEnum.h"


@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> 
{
	UIWindow			*_window;
	RootViewController	*_viewController;
    
    bool _debugDrawEnabled;
    bool _buttonTruckTapped;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readwrite) bool debugDrawEnabled;
+(AppDelegate *)sharedDelegate;


@end
