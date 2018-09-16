//
//  GameLevel.m
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
#import <math.h>
#import "GameLevel.h"
#import "LevelGoal.h"
#import "GameManager.h"


@implementation GameLevel


@synthesize
saved = _saved,
groupNumber = _groupNumber,
number = _number,
reqScoreToEnable = _reqScoreToEnable,
reqStarsToEnable = _reqStarsToEnable,

currentTime = _currentTime,

timesPlayed = _timesPlayed,
timesPassed = _timesPassed,
timesFailed = _timesFailed,

winState = _winState, 

actorsInfo = _actorsInfo,
levelGoals = _levelGoals;

// static methods
+(int)calculateStars:(GameLevel*)level
     calculationType:(ScoreCalculationType)calculationType
{
    int totTarget = 0;
    int totCount = 0;
    float numOfGoals = level.levelGoals.count;
    for (LevelGoal *goal in level.levelGoals) 
    {
        totTarget += goal.target;
        if(calculationType == ScoreCalculationTypeCurrent) // current
        {
            totCount += goal.currentCount;
        }
        else if(calculationType == ScoreCalculationTypeState) // state
        {
            totCount += goal.stateCount;
        }
        else if(calculationType == ScoreCalculationTypePrevious) // previous
        {
            totCount += goal.prevCount;
        }
    }
    
    float weightTotTarget = totTarget / numOfGoals;
    float weightTotCount = totCount / numOfGoals;
    
    int retVal = kInt0;
    if(weightTotCount > kInt0 )
    {
        float percent = (weightTotTarget / weightTotCount);
        if(percent > 0.9)
        {
            if(totTarget == totCount)
            {
                retVal = kInt3;   
            }
            else
            {
                retVal = kInt2;   
            }
        }
        else if(percent > 0.8f)
        {
            retVal = kInt2;   
        }
        else if(percent > 0.6f)
        {
            retVal = kInt1;   
        }
        else 
        {
            retVal = kInt0;   
        }
    }
    
    //CCLOG(@"GameLevel stars: %d", retVal);
    return retVal;
}

+(float)calculateTimeScore:(float)t
{
    int retVal = kInt0;
    if(t > kInt0)
    {
        retVal = kTimeScoreBase - (kTimeScoreDecrementerPerSecond * t);
    }
    return retVal < kInt0 ? kInt0 : retVal;
}

// non static

// returns a positive number if the goals contain a goal with the same 
// fruitName indicating the number of fruits still needed to reach that specific goal
-(int)goalUnitsStillNeededForFruitName:(NSString*)fruitName
{
    int retVal = -1; // -1 means this fruit is not in the goals
    for (LevelGoal *goal in self.levelGoals) 
    {
        if([goal.fruitName isEqualToString:fruitName])
        {
            retVal = goal.target - goal.currentCount;
            if(retVal < 0)
            {
                retVal = 0;
            }
        }
    }
    return retVal;
}

-(bool)allGoalsReached
{
    int count = kInt0;
    
    for (LevelGoal *goal in self.levelGoals) 
    {
        count += goal.reached ? kInt1 : kInt0;
    }
    
    return (count == self.levelGoals.count);
}

/*-(bool)goalFruitsDestroyed
{
    bool retVal = false;
    
    // if the same number of fruits in the goal + one are destroyed, level fails
    NSArray *keys = [_destroyedFruits allKeys];
    for(LevelGoal *goal in self.levelGoals)
    {
        if([keys containsObject:goal.fruitName])
        {
            NSNumber *count = (NSNumber*)[_destroyedFruits valueForKey:goal.fruitName];
            if ([count intValue] >= (goal.target+1)) {
                retVal = true;
                break;
            }
        } 
    }
    
    return retVal;
}*/

/*-(bool)maxNumberOfDestroyedFruitsReached
{
    return _destroyedFruits.count == 10;
}*/

-(bool)enabled
{
    bool retVal = false;
 
    // unlocked mode override
    if([GameManager allLevelsUnlocked])
    {
        retVal = true;
    }
    else
    {
        int totScore = [GameManager totalScore];
        int totStars = [GameManager totalStars];
        
        retVal = totScore >= _reqScoreToEnable;
        retVal = retVal || (totStars >= _reqStarsToEnable);
    }
    
    return retVal;
}

-(int)currentTimeScore
{
    int retVal = [GameLevel calculateTimeScore:self.currentTime];
    return retVal;
}

-(int)currentStars
{
    int retVal = [GameLevel calculateStars:self
                           calculationType:ScoreCalculationTypeCurrent];    
    //CCLOG(@"GameLevel stars: %d", retVal);
    return retVal;
}

-(int)currentStarScore
{
    int retVal = self.currentStars * kStarScoreBase;
    
    //CCLOG(@"GameLevel starScore: %d", retVal);
    return retVal;
}

-(int)currentBonus
{
    return _currentBonus;
}

-(int)currentScore
{
    int retVal = (self.currentStarScore + self.currentTimeScore + self.currentBonus);
    //CCLOG(@"GameLevel score: %d", retVal);
    return retVal;
}

// readonly from state
-(int)stateScore
{
    return _stateScore;
}

-(int)stateBonus
{
    return _stateBonus;
}

-(int)stateStarScore
{
    return _stateStarScore;
}

-(float)stateTime
{
    return _stateTime;
}

-(int)stateTimeScore
{
    int retVal = [GameLevel calculateTimeScore:self.stateTime];
    return retVal;
}

-(int)stateStars
{
    int retVal = [GameLevel calculateStars:self
                           calculationType:ScoreCalculationTypeState];    
    //CCLOG(@"GameLevel stars: %d", retVal);
    return retVal;
}

-(int)prevScore
{
    return _prevScore;
}

-(int)prevBonus
{
    return _prevBonus;
}

-(int)prevStarScore
{
    return _prevStarScore;
}

-(float)prevTime
{
    return _prevTime;
}

-(void)decreaseCurrentBonus
{
    int tmp = _currentBonus - kBonusUnitPoints;
    _currentBonus = tmp > kInt0 ? tmp : kInt0;
}

+(id)createWithNumber:(int)n 
          groupNumber:(int)gn
     reqScoreToEnable:(int)rste
     reqStarsToEnable:(int)rstarste 
           stateScore:(int)ss 
           stateBonus:(int)sb
       stateStarScore:(int)sss
            stateTime:(float)st
            prevScore:(int)ps 
            prevBonus:(int)pb 
        prevStarScore:(int)pss 
             prevTime:(float)pt 
          timesPlayed:(int)tplay 
          timesPassed:(int)tpass 
          timesFailed:(int)tfail
           actorsInfo:(NSArray*)actorsInfo
           levelGoals:(NSArray*)levelGoals
{
    return [[[self alloc] initWithNumber:n 
                             groupNumber:gn
                        reqScoreToEnable:rste 
                        reqStarsToEnable:rstarste
                              stateScore:ss
                              stateBonus:sb
                          stateStarScore:sss
                               stateTime:st
                               prevScore:ps  
                               prevBonus:pb
                           prevStarScore:pss 
                                prevTime:pt 
                             timesPlayed:tplay 
                             timesPassed:tpass 
                             timesFailed:tfail
                              actorsInfo:actorsInfo
                              levelGoals:levelGoals] autorelease];
}

-(id)initWithNumber:(int)n 
        groupNumber:(int)gn
   reqScoreToEnable:(int)rste
   reqStarsToEnable:(int)rstarste 
         stateScore:(int)ss 
         stateBonus:(int)sb
     stateStarScore:(int)sss
          stateTime:(float)st
          prevScore:(int)ps 
          prevBonus:(int)pb 
      prevStarScore:(int)pss 
           prevTime:(float)pt 
        timesPlayed:(int)tplay 
        timesPassed:(int)tpass 
        timesFailed:(int)tfail
         actorsInfo:(NSArray*)actorsInfo
         levelGoals:(NSArray*)levelGoals
{
    if ((self = [super init])) 
    {
        self.levelGoals = levelGoals;
        self.actorsInfo = actorsInfo;
        _destroyedFruits = [[NSMutableDictionary alloc] init];
        
        // Configuration
        self.groupNumber = gn,
        self.number = n,
        self.reqScoreToEnable = rste,
        self.reqStarsToEnable = rstarste,
        
        // scores
        _currentBonus = levelGoals.count * kBonusUnitPoints * kInt2, // starts at number of goals * bonusUnitPoints * 2
        _stateScore = ss,
        _stateBonus = sb,
        _stateStarScore = sss,
        _stateTime = st,
        
        _prevScore = ps,
        _prevBonus = ps,
        _prevStarScore = pss,
        _prevTime = pt,
        
        self.timesPlayed = tplay,
        self.timesPassed = tpass,
        self.timesFailed = tfail;
        
        _winState = LevelWinStateINVALID;
        
        _saved = false;
    }    
    return self;
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    [_actorsInfo release];
    _actorsInfo = nil;
    
    [_levelGoals release];
    _levelGoals = nil;
    
    //CCLOG(@"GameLevel: dealloc: _destroyedFruits retain count %d", _destroyedFruits.retainCount);
    
    [_destroyedFruits release];
    _destroyedFruits = nil;
    
    [super dealloc];
}

-(void)setAsPassed
{
    // increase number of times Played
    self.timesPlayed++;
    
    // increase number of times Passed
    self.timesPassed++;
    
    // set win state to Passed
    self.winState = LevelWinStatePassed;
}

-(void)setAsFailed
{
    // increase number of times Played
    self.timesPlayed++;
    
    // increase number of times Failed
    self.timesFailed++;   
    
    // set win state to Failed
    self.winState = LevelWinStateFailed;
}

-(void)resetDestroyedFruitsDict
{
    [_destroyedFruits removeAllObjects];
}

-(void)prepareForSaving
{
    // save previous into old
    _oldTime = _prevTime;
    _oldScore = _prevScore;
    _oldBonus = _prevBonus;
    _oldStarScore = _prevStarScore;
    
    // save state scores into previous
    _prevTime = _stateTime;
    _prevScore = _stateScore;
    _prevBonus = _stateBonus;
    _prevStarScore = _stateStarScore;
    
    // save current scores into state
    _stateTime = self.currentTime;
    _stateScore = self.currentScore;
    _stateBonus = self.currentBonus;
    _stateStarScore = self.currentStarScore;
    
    // reset current values
    self.currentTime = 0;
    
    for(LevelGoal *goal in self.levelGoals)
    {
        [goal prepareForSaving];
    }
}

-(void)restorePreviousScores
{    
    // reset state into current
    self.currentTime = _stateTime;
    _currentBonus = _stateBonus;
    
    // restore previous into state
    _stateTime = _prevTime;
    _stateScore = _prevScore;
    _stateBonus = _prevBonus;
    _stateStarScore = _prevStarScore;
    
    // restore old into previous
    _prevTime = _oldTime;
    _prevScore = _oldScore;
    _prevBonus = _oldBonus;
    _prevStarScore = _oldStarScore;
    
    // optional, set old to zero
    _oldTime = kInt0;
    _oldScore = kInt0;
    _oldBonus = kInt0;
    _oldStarScore = kInt0;
    
    for(LevelGoal *goal in self.levelGoals)
    {
        [goal restorePreviousScores];
    }
    
    _saved = false;
}

-(void)resetLevel:(LevelWinStateEnum)winStateEnum
{
    [self resetDestroyedFruitsDict];
    
    self.currentTime = kInt0;
    _currentBonus = self.levelGoals.count * kBonusUnitPoints * kInt2;
    self.winState = winStateEnum;
        
    for(LevelGoal *goal in self.levelGoals)
    {
        [goal resetGoal];
    }
    
    _saved = false;
}

-(void)updateDestroyedFruitDict:(NSString *)fruitName
{
    int count = 1;
    NSArray *keys = [_destroyedFruits allKeys];
    NSString *key = nil;
    bool release = false;
    if([keys containsObject:fruitName])
    {
        key = [keys objectAtIndex:[keys indexOfObject:fruitName]];
        NSNumber *previousCount = (NSNumber*)[_destroyedFruits valueForKey:fruitName];
        count += [previousCount intValue];
        previousCount = nil;
    }
    else
    {
        release = true;
        key = [fruitName copy];
    }
    keys = nil;
    
    NSNumber *numberCount = [[NSNumber alloc] initWithInt:count];
    [_destroyedFruits setValue:numberCount forKey:key];
    [numberCount release];
    numberCount = nil;
    if(release)
    {
        [key release];
    }
    key = nil;
}

-(LevelGoal*)findGoalByName:(NSString *)fruitName
{
    LevelGoal *goal = nil;
    for(LevelGoal *item in self.levelGoals)
    {
        if([fruitName isEqualToString:item.fruitName])
        {
            goal = item;
            break;
        }
    }
    return goal;
}

-(LevelGoal*)privateUpdateGoalFruit:(NSString *)fruitName
                     quantity:(int)quantity
{
    LevelGoal *goal = [self findGoalByName:fruitName];
    goal.currentCount += quantity;
    return goal;
}

-(LevelGoal*)increaseGoalFruit:(NSString*)fruitName
{
    return [self privateUpdateGoalFruit:fruitName quantity:1];
}

-(LevelGoal*)decreaseGoalFruit:(NSString*)fruitName
{
    return [self privateUpdateGoalFruit:fruitName quantity:-1];
}

-(LevelGoal*)increaseDestroyedFruit:(NSString*)fruitName
{
    [self updateDestroyedFruitDict:fruitName];
    return [self findGoalByName:fruitName];
}

@end
