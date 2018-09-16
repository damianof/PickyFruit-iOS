//
//  ScrollingClouds.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/30/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DevicePositionHelper.h"

//@class CCLayerWithWorld;

#define kMaxHillKeyPoints 1000
#define kHillSegmentWidth 1
#define kMaxHillVertices 4000
#define kMaxBorderVertices 100 

@interface ScrollingClouds : CCNode
{
    CCSprite * _spriteClouds;
    CCSprite * _spriteMountains;
    
    UnitsSize _screenUnitsSize;
    float _speed;
    int _direction;
    
    int _cloudsUnitsHeight;
    int _mountainsUnitsHeight;
    
    CGRect _cloudsBox;
}

+(id)createWithSpeed:(float)speed
           direction:(int)direction;

-(id)initWithSpeed:(float)speed
         direction:(int)direction;

-(void)generateSprites;
-(void)generateCloudsSprite;
-(void)generateMountainsSprite;

@end
