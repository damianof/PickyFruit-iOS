//
//  GameConfigAndState.m
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameConfigAndState.h"
#import "GameGroup.h"
#import "GameLevel.h"
#import "GameStateXmlHelper.h"


@implementation GameConfigAndState


@synthesize 
groups = _groups,
levels = _levels,
achieve10GreenApples = _achieve10GreenApples,
achieve10RedApples = _achieve10RedApples,
achieve10Bananas = _achieve10Bananas,
achieve1GoldenApple = _achieve1GoldenApple,
achieve3GoldenApple = _achieve3GoldenApple,
achieve7GoldenApple = _achieve7GoldenApple,
achieve10GoldenApple = _achieve10GoldenApple,
achieveLevel18With3Stars = _achieveLevel18With3Stars,
achieveLevel33With3Stars = _achieveLevel33With3Stars;

-(bool)didAchieveAtLeastOneGoldenApple
{
    return self.achieve1GoldenApple == 1
    || self.achieve1GoldenApple == 3
    || self.achieve1GoldenApple == 7
    || self.achieve1GoldenApple == 10;
}

/*-(NSArray*)groups
{
    return _groups;
}

-(NSArray*)levels
{
    return _levels;
}*/

+(void)deleteGameState
{
    [GameStateXmlHelper deleteGameState];
}

-(int)numberOfGroups
{
    return _numberOfGroups;
}

-(int)levelsPerGroup
{
    return _levelsPerGroup;
}

-(int)levelsPerRow
{
    return _levelsPerRow;
}

+(id)createWithNumberOfGroups:(int)nog
               levelsPerGroup:(int)lpg
                 levelsPerRow:(int)lpr
                       groups:(NSArray*)grps
                       levels:(NSArray*)lvls
{
    return [[[self alloc] initWithNumberOfGroups:nog
                                  levelsPerGroup:lpg
                                    levelsPerRow:lpr
                                          groups:grps
                                          levels:lvls] autorelease];
}

- (id)initWithNumberOfGroups:(int)nog
              levelsPerGroup:(int)lpg
                levelsPerRow:(int)lpr 
                      groups:(NSArray*)grps
                      levels:(NSArray*)lvls
{
    
    if ((self = [super init])) 
    {
        self.groups = grps; //[[NSMutableArray alloc] init];
        self.levels = lvls; //[[NSMutableArray alloc] init];
        _numberOfGroups = nog;
        _levelsPerGroup = lpg;
        _levelsPerRow = lpr;
        
        // achievements
        _achieve10GreenApples = 0;
        _achieve10RedApples = 0;
        _achieve10Bananas = 0;
        _achieve1GoldenApple = 0;
        _achieve3GoldenApple = 0;
        _achieve7GoldenApple = 0;
        _achieve10GoldenApple = 0;
        
        _achieveLevel18With3Stars = 0;
        _achieveLevel33With3Stars = 0;
    }
    return self;
    
}

- (void) dealloc 
{
    CCLOG(@"GameConfigAndState: dealloc: groups retainCount %d", _groups.retainCount);
    CCLOG(@"GameConfigAndState: dealloc: levels retainCount %d", _levels.retainCount);
    
    [_groups release];
    _groups = nil;  
    
    [_levels release];
    _levels = nil; 
    
    [super dealloc];
}

-(int)totalScore
{
    int tot = 0;
    
    for (GameLevel *level in self.levels) 
    {
        tot += level.stateScore;
    }
    
    return tot;
}

-(int)totalStars
{
    int tot = 0;
    
    for (GameLevel *level in self.levels) 
    {
        tot += level.stateStars;
    }
    
    return tot;
}

-(int)totalTimesPlayed
{
    int tot = 0;
    
    for (GameLevel *level in self.levels) 
    {
        tot += level.timesPlayed;
    }
    
    return tot;
}

-(GameGroup *)getGroupByNumber:(int)gn
{
    GameGroup *retVal = nil;
    for (retVal in self.groups) 
    {
        if(retVal.number == gn)
        {
            break;
        }
    }
    return retVal;
}

-(GameLevel *)getGameLevel:(int)ln
{   
    GameLevel *level = nil;
    for (level in self.levels) 
    {
        /*CCLOG(@"Level: %d: Score: %d; Stars: %d; TimeScore: %.4f; PrevScore: %d; PrevStarScore: %d; PrevTime: %.4f;", 
              level.number, 
              level.score,
              level.stars, 
              level.time,
              level.prevScore,
              level.prevStarScore, 
              level.prevTime);*/
        
        if(level.number == ln)
        {
            break;
        }
    }

    return level;
}

-(void)levelPassedWith3Stars:(int)levelNumber
{
    if(levelNumber == 18)
    {
        self.achieveLevel18With3Stars = kInt1;
    }
    else if (levelNumber == 33)
    {
        self.achieveLevel33With3Stars = kInt1;
    }
}

-(void)achieveIncrease:(NSString *)fruitName
{
    if(self.achieve10GreenApples < 10 
       || self.achieve10RedApples < 10
       || self.achieve10Bananas < 10
       || self.achieve1GoldenApple < 1
       || self.achieve3GoldenApple < 3
       || self.achieve7GoldenApple < 7
       || self.achieve10GoldenApple < 10)
    {
        if([fruitName isEqualToString:kSpriteFrameNameAppleGreen])
        {
            if(self.achieve10GreenApples < 10)
            {
                self.achieve10GreenApples++;
            }
        }
        else if([fruitName isEqualToString:kSpriteFrameNameAppleRed])
        {
            if(self.achieve10RedApples < 10)
            {
                self.achieve10RedApples++;
            }
        }
        else if([fruitName isEqualToString:kSpriteFrameNameBanana])
        {
            if(self.achieve10Bananas < 10)
            {
                self.achieve10Bananas++;
            }
        }
        else if([fruitName isEqualToString:kSpriteFrameNameAppleGolden])
        {
            if(self.achieve1GoldenApple < 1)
            {
                self.achieve1GoldenApple++;
            }
            if(self.achieve3GoldenApple < 3)
            {
                self.achieve3GoldenApple++;
            }
            if(self.achieve7GoldenApple < 7)
            {
                self.achieve7GoldenApple++;
            }
            if(self.achieve10GoldenApple < 10)
            {
                self.achieve10GoldenApple++;
            }
        }
    }
}

@end
