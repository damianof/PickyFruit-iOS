//
//  StaticSpriteInfo.m
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "StaticSpriteInfo.h"


@implementation StaticSpriteInfo


@synthesize 
    tag = _tag,
    z = _z,
    framesFileName = _framesFileName,
    imageFormat = _imageFormat,
    frameName = _frameName,
    anchorPoint = _anchorPoint,
    unitsPosition = _unitsPosition,
    positionFromTop = _positionFromTop;


+(id)createWithTag:(int)t
                 z:(int)z
    framesFileName:(NSString *)ffn
       imageFormat:(NSString *)format  
         frameName:(NSString *)fn 
       anchorPoint:(CGPoint)ap 
     unitsPosition:(UnitsPoint)up
   positionFromTop:(bool)pft
{
    return [[[self alloc] initWithTag:t
                                    z:z
                       framesFileName:ffn
                          imageFormat:format
                            frameName:fn 
                          anchorPoint:ap 
                        unitsPosition:up
                      positionFromTop:pft] autorelease];
}

-(id)initWithTag:(int)t
               z:(int)z
  framesFileName:(NSString *)ffn
     imageFormat:(NSString *)format 
       frameName:(NSString *)fn 
     anchorPoint:(CGPoint)ap 
   unitsPosition:(UnitsPoint)up
 positionFromTop:(bool)pft
{
    if ((self = [super init])) 
    {
        self.framesFileName = ffn,
        self.imageFormat = format,
        self.frameName = fn,
        
        self.tag = t,
        self.z = z,
        self.anchorPoint = ap,
        self.unitsPosition = up,
        self.positionFromTop = pft;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object   
    [_framesFileName release];
    [_imageFormat release];
    [_frameName release];
    
    _framesFileName = nil;
    _imageFormat = nil;
    _frameName = nil;
    
    [super dealloc];
}


@end
