//
//  TreeInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevicePositionHelper.h"


@interface TreeInfo : NSObject
{ 
    NSString *_frameName; 
    CGPoint _anchorPoint;
    int _z;
    int _tag;
    NSArray *_actorsInfo;
    UnitsRect _fruitRegion;
}

@property (nonatomic, retain) NSArray *actorsInfo;
@property (nonatomic, copy) NSString *frameName;

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) int z;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) UnitsRect fruitRegion;


+(id)createWithTag:(int)t
                 z:(int)z
         frameName:(NSString *)fn 
       anchorPoint:(CGPoint)ap 
       fruitRegion:(UnitsRect)fr
        actorsInfo:(NSArray *)ai;

-(id)initWithTag:(int)t
               z:(int)z 
       frameName:(NSString *)fn 
     anchorPoint:(CGPoint)ap 
     fruitRegion:(UnitsRect)fr
      actorsInfo:(NSArray *)ai;

@end
