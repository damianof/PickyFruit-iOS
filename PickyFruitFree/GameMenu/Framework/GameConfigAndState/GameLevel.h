//
//  GameLevel.h
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameManager.h"
#import "LevelWinStateEnum.h"

@class LevelGoal;


typedef enum{
    ScoreCalculationTypeINVALID = 0,
    ScoreCalculationTypeCurrent,
    ScoreCalculationTypeState,
    ScoreCalculationTypePrevious,
    ScoreCalculationTypeMAX
} ScoreCalculationType;


@interface GameLevel : NSObject 
{
    int _groupNumber;
    int _number;
    int _reqScoreToEnable;
    int _reqStarsToEnable;
    
    NSArray *_actorsInfo;
    NSArray *_levelGoals;
    
    // scores
    float _currentTime;
    int _currentBonus;
    
    // state
    int _stateScore;
    int _stateBonus;
    int _stateStarScore;
    float _stateTime;
    
    int _prevScore;
    int _prevBonus;
    int _prevStarScore;
    float _prevTime;
    
    int _oldScore;
    int _oldBonus;
    int _oldStarScore;
    float _oldTime;
    
    int _timesPlayed;
    int _timesPassed;
    int _timesFailed;
    
    NSMutableDictionary *_destroyedFruits;
    
    LevelWinStateEnum _winState;
}

// config
@property (nonatomic, retain) NSArray *actorsInfo;
@property (nonatomic, retain) NSArray *levelGoals;

@property (nonatomic, readwrite) bool saved;
@property (nonatomic, readonly) bool enabled;
@property (nonatomic, assign) int groupNumber;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int reqScoreToEnable;
@property (nonatomic, assign) int reqStarsToEnable;

// state (scores)
@property (nonatomic, readwrite) float currentTime;
@property (nonatomic, readonly) int currentBonus;

//@property (nonatomic, readonly) float time;

@property (nonatomic, readonly) int stateScore;
@property (nonatomic, readonly) int stateBonus;
@property (nonatomic, readonly) int stateStarScore;
@property (nonatomic, readonly) float stateTime;
@property (nonatomic, readonly) int stateStars;
@property (nonatomic, readonly) int stateTimeScore;

@property (nonatomic, readonly) int prevScore;
@property (nonatomic, readonly) int prevBonus;
@property (nonatomic, readonly) int prevStarScore;
@property (nonatomic, readonly) float prevTime;

@property (nonatomic, readwrite) int timesPlayed;
@property (nonatomic, readwrite) int timesPassed;
@property (nonatomic, readwrite) int timesFailed;

@property (nonatomic, assign) LevelWinStateEnum winState;

// calculated scores
@property (nonatomic, readonly) int currentTimeScore;
@property (nonatomic, readonly) int currentStars;
@property (nonatomic, readonly) int currentStarScore;
@property (nonatomic, readonly) int currentScore;

@property (nonatomic, readonly) bool allGoalsReached;
//@property (nonatomic, readonly) bool goalFruitsDestroyed;
//@property (nonatomic, readonly) bool maxNumberOfDestroyedFruitsReached;

/*+(int)calculateStars:(GameLevel*)level
     calculationType:(ScoreCalculationType)calculationType;
+(float)calculateTimeScore:(float)t;*/

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
           levelGoals:(NSArray*)levelGoals;

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
         levelGoals:(NSArray*)levelGoals;

// returns a positive number if the goals contain a goal with the same 
// fruitName indicating the number of fruits still needed to reach that specific goal
-(int)goalUnitsStillNeededForFruitName:(NSString*)fruitName;

-(void)setAsPassed;
-(void)setAsFailed;

-(void)decreaseCurrentBonus;

-(void)resetLevel:(LevelWinStateEnum)winStateEnum;
-(void)prepareForSaving;
-(void)restorePreviousScores;

-(LevelGoal*)increaseGoalFruit:(NSString*)fruitName;
-(LevelGoal*)decreaseGoalFruit:(NSString*)fruitName;
-(LevelGoal*)increaseDestroyedFruit:(NSString*)fruitName;

@end
