//
//  GameConfigAndState.h
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@class GameGroup;
@class GameLevel;
@class GameStateXmlHelper;


@interface GameConfigAndState : NSObject 
{
    NSArray *_groups;
    NSArray *_levels;
    int _numberOfGroups;
    int _levelsPerGroup;
    int _levelsPerRow;
    
    // achievements
    int _achieve10GreenApples;
    int _achieve10RedApples;
    int _achieve10Bananas;
    int _achieve1GoldenApple;
    int _achieve3GoldenApple;
    int _achieve7GoldenApple;
    int _achieve10GoldenApple;
    
    int _achieveLevel18With3Stars;
    int _achieveLevel33With3Stars;
}

@property (nonatomic, retain) NSArray *groups;
@property (nonatomic, retain) NSArray *levels;
@property (nonatomic, readonly) int numberOfGroups;
@property (nonatomic, readonly) int levelsPerGroup;
@property (nonatomic, readonly) int levelsPerRow;

// total scores
@property (nonatomic, readonly) int totalScore;
@property (nonatomic, readonly) int totalStars;
@property (nonatomic, readonly) int totalTimesPlayed;

// achievements
@property (nonatomic, readonly) bool didAchieveAtLeastOneGoldenApple;
@property (nonatomic, readwrite) int achieve10GreenApples;
@property (nonatomic, readwrite) int achieve10RedApples;
@property (nonatomic, readwrite) int achieve10Bananas;
@property (nonatomic, readwrite) int achieve1GoldenApple;
@property (nonatomic, readwrite) int achieve3GoldenApple;
@property (nonatomic, readwrite) int achieve7GoldenApple;
@property (nonatomic, readwrite) int achieve10GoldenApple;

@property (nonatomic, readwrite) int achieveLevel18With3Stars;
@property (nonatomic, readwrite) int achieveLevel33With3Stars;


+(void)deleteGameState;

+(id)createWithNumberOfGroups:(int)nog
               levelsPerGroup:(int)lpg
                 levelsPerRow:(int)lpr
                       groups:(NSArray*)grps
                       levels:(NSArray*)lvls;

-(id)initWithNumberOfGroups:(int)nog
              levelsPerGroup:(int)lpg
               levelsPerRow:(int)lpr
                     groups:(NSArray*)grps
                     levels:(NSArray*)lvls;

-(GameGroup*)getGroupByNumber:(int)gn;
-(GameLevel*)getGameLevel:(int)ln;

-(void)levelPassedWith3Stars:(int)levelNumber;
-(void)achieveIncrease:(NSString*)fruitName;

@end
