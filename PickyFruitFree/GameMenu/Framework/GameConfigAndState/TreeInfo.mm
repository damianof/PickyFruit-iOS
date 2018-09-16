//
//  TreeInfo.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TreeInfo.h"


@implementation TreeInfo

@synthesize 
tag = _tag,
z = _z,
frameName =_frameName,
anchorPoint = _anchorPoint,
actorsInfo = _actorsInfo,
fruitRegion = _fruitRegion;

+(id)createWithTag:(int)t
                 z:(int)z
         frameName:(NSString *)fn
       anchorPoint:(CGPoint)ap 
       fruitRegion:(UnitsRect)fr
        actorsInfo:(NSArray *)ai
{
    return [[[self alloc] initWithTag:t
                                    z:z
                            frameName:fn
                          anchorPoint:ap 
                          fruitRegion:fr
                           actorsInfo:ai] autorelease];
}

-(id)initWithTag:(int)t
               z:(int)z
       frameName:(NSString *)fn
     anchorPoint:(CGPoint)ap 
     fruitRegion:(UnitsRect)fr
      actorsInfo:(NSArray *)ai
{
    if ((self = [super init])) 
    {
        self.actorsInfo = ai,
        self.frameName = fn,
        
        self.fruitRegion = fr,
        self.anchorPoint = ap,
        self.tag = t,
        self.z = z;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object 
    //NSAssert(_framesFileName.retainCount == 1, @"TreeInfo: dealloc: _framesFileName retain count != 1");
    CCLOG(@"TreeInfo dealloc: _frameName Retain Count %d", _frameName.retainCount);
    
    [_actorsInfo release];
    _actorsInfo = nil;
    
    [_frameName release];
    _frameName = nil;
    
    
    [super dealloc];
}

@end
