//
//  StaticSpriteInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevicePositionHelper.h"


@interface StaticSpriteInfo : NSObject 
{
    NSString *_framesFileName;
    NSString *_imageFormat;
    NSString *_frameName; 
    
    CGPoint _anchorPoint;
    UnitsPoint _unitsPosition;
    bool _positionFromTop; 
    int _z;
    int _tag;
}

@property (nonatomic, copy) NSString *framesFileName;
@property (nonatomic, copy) NSString *imageFormat;
@property (nonatomic, copy) NSString *frameName;

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) UnitsPoint unitsPosition;
@property (nonatomic, assign) bool positionFromTop;
@property (nonatomic, assign) int z;
@property (nonatomic, assign) int tag;


+(id)createWithTag:(int)t
                 z:(int)z
    framesFileName:(NSString *)ffn
       imageFormat:(NSString *)format  
         frameName:(NSString *)fn 
       anchorPoint:(CGPoint)ap 
     unitsPosition:(UnitsPoint)up
   positionFromTop:(bool)pft;

-(id)initWithTag:(int)t
               z:(int)z
  framesFileName:(NSString *)ffn
     imageFormat:(NSString *)format  
       frameName:(NSString *)fn 
     anchorPoint:(CGPoint)ap 
   unitsPosition:(UnitsPoint)up
 positionFromTop:(bool)pft;


@end
