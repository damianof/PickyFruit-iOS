//
//  ActorsCache.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/19/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
/*
#import "ActorsCache.h"
#import "BodyNodeWithSprite.h"

static ActorsCache *_sharedActorsCache;


@implementation ActorsCache

@synthesize actorsDictionary = _actorsDictionary;

-(NSMutableDictionary*)actorsDictionary
{
    return _actorsDictionary;
}

// static
+(ActorsCache *)sharedInstance
{
    if(!_sharedActorsCache)
    {
        _sharedActorsCache = [[ActorsCache create] retain];
    }
    return _sharedActorsCache;
}

+(id)create
{
    return [[[self alloc] init] autorelease];
}

+(void)cleanup
{   
    // Cleanup method is called by the GameManager dealloc method
    [_sharedActorsCache release];
    _sharedActorsCache = nil;
}

+(bool)containsKey:(NSString*)key
{
    NSMutableDictionary *dict = [ActorsCache sharedInstance].actorsDictionary;
    return [[dict allKeys] containsObject:key];
}

+(void)setActor:(BodyNodeWithSprite*)actor
         forKey:(NSString*)key
{
    NSMutableDictionary *dict = [ActorsCache sharedInstance].actorsDictionary;
    [dict setValue:actor forKey:key];
}

+(BodyNodeWithSprite*)actorForKey:(NSString*)key
{
    if([ActorsCache containsKey:key])
    {
        NSMutableDictionary *dict = [ActorsCache sharedInstance].actorsDictionary;
        return (BodyNodeWithSprite*)[dict valueForKey:key];
    }
    NSAssert(true, @"ActorsCache: actorForKey: does not contain key");
    return nil;
}

-(id)init
{
    if((self = [super init]))
    {  
        _actorsDictionary = [[[NSMutableDictionary alloc ]initWithCapacity:100] retain];
    }
    return self;
}

-(void)dealloc
{
    [_actorsDictionary release];
    _actorsDictionary = nil;
    
    [super dealloc];
}

@end*/
