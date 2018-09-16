//
//  FruitSlotInfo.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/23/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
#import "FruitSlotInfo.h"

@implementation FruitSlotInfo

@synthesize filled = _filled;

-(b2Vec2)position
{
    return _position;
}

-(void)setNewPosition:(b2Vec2)p
{
    _position = p;;
}

+(id)createWithPosition:(b2Vec2)position
{
    return [[[self alloc] initWithPosition:position] autorelease];
}

-(id)initWithPosition:(b2Vec2)position
{
    if ((self = [super init])) 
    {
        _position = position,
        _filled = false;
    }  
    
    return self;
}

-(void)dealloc
{
    //CCLOG(@"FruitSlotInfo: dealloc");
    [super dealloc];
}

@end
