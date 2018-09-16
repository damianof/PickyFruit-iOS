//
//  ParallaxSpriteInfo.m
//  GameMenu
//
//  Created by Damiano Fusco on 12/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParallaxSpriteInfo.h"


@implementation ParallaxSpriteInfo


@synthesize 
    tag = _tag,
    z = _z,
    frameName = _frameName,
    anchorPoint = _anchorPoint,
    unitsPosition = _unitsPosition,
    positionFromTop = _positionFromTop,
    speedFactor = _speedFactor;

+(id)createWithTag:(int)t
                 z:(int)z
         frameName:(NSString *)fn 
       anchorPoint:(CGPoint)ap 
     unitsPosition:(UnitsPoint)up 
   positionFromTop:(bool)pft
       speedFactor:(float)sf
{
    return [[[self alloc] initWithTag:t
                                    z:z
                            frameName:fn 
                          anchorPoint:ap 
                        unitsPosition:up
                      positionFromTop:pft
                          speedFactor:sf] autorelease];
}

-(id)initWithTag:(int)t
               z:(int)z
       frameName:(NSString *)fn
     anchorPoint:(CGPoint)ap
   unitsPosition:(UnitsPoint)up 
 positionFromTop:(bool)pft
     speedFactor:(float)sf 
{
    if ((self = [super init])) 
    {
        self.tag = t,
        self.z = z,
        self.frameName = fn,
        self.anchorPoint = ap,
        self.unitsPosition = up,
        self.positionFromTop = pft,
        self.speedFactor = sf;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    [_frameName release];
    _frameName = nil;
    
    [super dealloc];
}


@end
