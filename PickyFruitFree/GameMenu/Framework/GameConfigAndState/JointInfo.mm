//
//  JointInfo.m
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "JointInfo.h"


@implementation JointInfo

@synthesize 
    typeName = _typeName,
    joinWith = _joinWith,
    worldAxis = _worldAxis;


+(id)createWithTypeName:(NSString *)tn
{
    return [[[self alloc] initWithTypeName:tn] autorelease];
}

-(id)initWithTypeName:(NSString *)tn
{
    if ((self = [super init])) 
    {
        self.typeName = tn;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    [_typeName release];
    [_joinWith release];
    
    _typeName = nil;
    _joinWith = nil;
    
    [super dealloc];
}


@end
