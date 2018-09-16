//
//  ParallaxSpriteInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevicePositionHelper.h"


@interface ParallaxSpriteInfo : NSObject 
{
    //ParallaxSprite Tag="0" Z="0" FrameName="Clouds" SpeedFactor="0.1f" AnchorPoint="{0,1}"
    NSString *_frameName; // "Clouds" 
    CGPoint _anchorPoint;
    UnitsPoint _unitsPosition;
    bool _positionFromTop; 
    int _z;
    int _tag;
    float _speedFactor;
}

@property (nonatomic, copy) NSString *frameName;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) UnitsPoint unitsPosition;
@property (nonatomic, assign) bool positionFromTop;
@property (nonatomic, assign) int z;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) float speedFactor;


+(id)createWithTag:(int)t
                 z:(int)z
         frameName:(NSString *)fn 
       anchorPoint:(CGPoint)ap 
     unitsPosition:(UnitsPoint)up
   positionFromTop:(bool)pft
       speedFactor:(float)sf;

-(id)initWithTag:(int)t
               z:(int)z
       frameName:(NSString *)fn 
     anchorPoint:(CGPoint)ap 
   unitsPosition:(UnitsPoint)up
 positionFromTop:(bool)pft
     speedFactor:(float)sf;


@end
