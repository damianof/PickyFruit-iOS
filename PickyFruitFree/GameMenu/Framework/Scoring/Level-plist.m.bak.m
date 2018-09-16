//
//  Level.m
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "Level.h"


@implementation Level


@synthesize 
    number = _number, 
    score = _score;


-(id)initWithNumber:(int)n 
           andScore:(int)s
{
    if((self = [super init]))
    {
        _number = [NSNumber numberWithInteger:n];
        _score = [NSNumber numberWithInteger:s];
    }
         
    return self;
}

@end
