//
//  LevelGoal.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/7/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "LevelGoal.h"


@implementation LevelGoal

@synthesize  
fruitName = _fruitName,
currentCount = _currentCount;

-(int)tag
{
    return _tag;
}

-(int)target
{
    return _target;
}

-(int)stateCount
{
    return _stateCount;
}

-(int)prevCount
{
    return _prevCount;
}

-(bool)reached
{
    return self.currentCount >= self.target;
}

-(int)stillNeeded
{
    int retVal = self.target - self.currentCount;
    retVal = retVal > kInt0 ? retVal : kInt0;
    return retVal;
}

+(id)createWithTag:(int)tag
         fruitName:(NSString*)fn 
            target:(int)t
        stateCount:(int)sc
         prevCount:(int)pc
{
    return [[[self alloc] initWithTag:tag
                            fruitName:fn 
                               target:t
                           stateCount:sc
                            prevCount:pc] autorelease];
}

-(id)initWithTag:(int)tag
       fruitName:(NSString*)fn 
          target:(int)t
      stateCount:(int)sc
       prevCount:(int)pc
{
    if ((self = [super init])) 
    {
        self.fruitName = fn,
        _tag = tag;
        _target = t;
        _stateCount = sc;
        _prevCount = pc;
        
        _currentCount = 0;
    }    
    return self;
}

-(void)dealloc
{  
    [_fruitName release];
    _fruitName = nil;
    
    [super dealloc];
}

-(void)prepareForSaving
{
    // save previous into old
    _oldCount = _prevCount;
    
    // save state into previous
    _prevCount = _stateCount; 
    
    // save current into state
    _stateCount = self.currentCount; 
    
    // reset current
    self.currentCount = 0;
}

-(void)restorePreviousScores
{
    // restore state into current
    self.currentCount = _stateCount;
    
    // restore previous into state
    _stateCount = _prevCount; 
    
    // restore old into previous
    _prevCount = _oldCount;
    
    // optional, set old to zero
    _oldCount = 0;
}

-(void)resetGoal
{    
    // reset current
    self.currentCount = 0;
}

@end
