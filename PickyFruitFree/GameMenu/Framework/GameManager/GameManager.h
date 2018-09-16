//
//  GameManager.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TargetLayerEnum.h"

#import "GameKitHelper.h"

@class GameConfigAndState;
@class GameGroup;
@class GameLevel;
@class LevelGoal;
@class CCLayerWithWorld;
@class UserInterfaceLayer;


@protocol GameManagerDelegate
-(void)didIncreaseTimeElapsedFromStart:(float)te;
-(void)didIncreaseSavedFruits:(LevelGoal*)goal
                    fruitName:(NSString*)fruitName
               totFruitsSaved:(int)totFruitsSaved;
-(void)didDecreaseSavedFruits:(LevelGoal*)goal
                    fruitName:(NSString*)fruitName
               totFruitsSaved:(int)totFruitsSaved;
-(void)didIncreaseDestroyedFruits:(LevelGoal*)goal
                        fruitName:(NSString*)fruitName
               totFruitsDestroyed:(int)totFruitsDestroyed;
@end


@interface GameManager : NSObject <GameKitHelperProtocol>
{
    id <GameManagerDelegate> _delegate;
    
    GameConfigAndState *_gameConfigAndState;
    GameGroup *_currentGameGroup;
    GameLevel *_currentGameLevel;
    
    // weak reference to game layer
    CCLayerWithWorld *_gameLayer;
    // weak reference to UI layer
    UserInterfaceLayer *_uiLayer;
    
    // following are just for displaying (not saved in state)
    int _totFruitsSaved; 
    int _totFruitsDestroyed;
    int _totEnemiesKilled;
    
    bool _levelEnded;
    bool _running;
    bool _allLevelsUnlocked;
    
    bool _animationInitialized;
}

@property (nonatomic, assign) id <GameManagerDelegate> delegate;

@property (nonatomic, readonly) GameConfigAndState *gameConfigAndState;
@property (nonatomic, readonly) GameGroup *currentGameGroup;
@property (nonatomic, readonly) GameLevel *currentGameLevel;

@property (nonatomic, readonly) CCLayerWithWorld *gameLayer;
@property (nonatomic, readonly) UserInterfaceLayer *uiLayer;

@property (nonatomic, readonly) float timeElapsedFromStart;
@property (nonatomic, readonly) bool running;
@property (nonatomic, readonly) bool allLevelsUnlocked;

-(void)setGameLayer:(CCLayerWithWorld *)layer;
-(void)setUILayer:(UserInterfaceLayer *)layer;
-(void)setCurrentGameGroup:(GameGroup*)group;
-(void)setCurrentGameLevel:(GameLevel*)level;

-(void)reportToGameCenter;

-(void)checkForEndLevel;
//-(void)increaseSavedFruits:(NSTimer*)timer;
//-(void)decreaseSavedFruits:(NSTimer*)timer;
//-(void)increaseDestroyedFruits:(NSTimer*)timer;
-(void)increaseTimeElapsedFromStart:(float)dt;
-(void)increaseSavedFruits:(NSString *)fruitFrameName
                 withDelay:(float)seconds;
-(void)decreaseSavedFruits:(NSString *)fruitFrameName
                 withDelay:(float)seconds;
-(void)increaseDestroyedFruits:(NSString *)fruitFrameName
                     withDelay:(float)seconds;

-(GameConfigAndState*)loadConfigAndState;

// following should be used only for testing, otherways make them private
-(int)updateCurrentLevelAsPassed;
-(int)updateCurrentLevelAsFailed;
//-(int)updateCurrentLevelAsReplay;

-(void)initializeAnimations;
-(void)setAllLevelsUnlocked:(bool)unlocked;

// static methods
+(id)create;
+(void)cleanup;
+(void)runManager;
+(void)stopManager;
//+(GameConfigAndState*)reloadConfigAndState;

+(GameManager *)sharedInstance;
+(GameConfigAndState *)gameConfigAndState;
+(GameGroup *)currentGameGroup;
+(GameLevel *)currentGameLevel;

+(TargetLayerEnum)targetLayerSelected;

//+(TargetLayerEnum)setCurrentLevelNumberAndGetTargetLayer:(int)ln;
//+(TargetLayerEnum)setNextGameLevelAndGetTargetGameLayer;
+(void)loadCurrentLevelLayer:(int)ln;
+(void)loadNextLevelLayer;
+(void)reloadCurrentLevelLayerForReplay;
+(void)loadMenuLevels;
+(void)loadMenuPlay;

//+(void)setCurrentGameGroup:(GameGroup*)group;
+(void)setCurrentGameLevel:(GameLevel*)level;

+(GameLevel *)peekNextLevel;

+(void)increaseTimeElapsedFromStart:(float)dt;

// game menu and control
+(int)totalScore;
+(int)totalStars;
+(int)totalTimesPlayed;

+(int)groupNumberSelected;
+(void)setGroupNumberSelected:(int)gn;

+(bool)allLevelsUnlocked;
+(void)setAllLevelsUnlocked:(bool)unlocked;


/*+(void)updateCurrentLevelScore:(int)ps
                     starScore:(int)pss
                          time:(float)pt
                   timesPlayed:(int)tplay
                   timesPassed:(int)tpass;*/

+(void)checkForEndLevel;

// following are for testing and should be made private once done
+(TargetLayerEnum)setCurrentLevelNumberAndGetTargetLayer:(int)ln;
+(TargetLayerEnum)setNextGameLevelAndGetTargetGameLayer;

+(void)deleteGameState;

@end
