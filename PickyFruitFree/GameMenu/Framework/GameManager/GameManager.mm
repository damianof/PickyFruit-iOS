//
//  GameManager.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameManager.h"

#import "GameStateXmlHelper.h"
#import "GameConfigAndState.h"
#import "ActorInfo.h"
#import "GameGroup.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "TargetLayerEnum.h"
#import "SceneHelper.h"
#import "TractorNode.h"
#import "TrailerNode.h"
#import "TreeSystemNode.h"
#import "ActorsCache.h"
#import "AnimationManager.h"
#import "CCLayerWithWorld.h"
#import "SimpleAudioEngine.h"

static GameManager *_gameManagerInstance;


@implementation GameManager

@synthesize 
    gameConfigAndState = _gameConfigAndState,
    delegate = _delegate;


-(void)setGameLayer:(CCLayerWithWorld *)layer
{
    _gameLayer = layer;
}

-(void)setAllLevelsUnlocked:(bool)unlocked
{
    _allLevelsUnlocked = unlocked;
}

-(bool)allLevelsUnlocked
{
    return _allLevelsUnlocked;
}

-(CCLayerWithWorld *)gameLayer
{
    return _gameLayer;
}

-(void)setUILayer:(UserInterfaceLayer *)layer
{
    _uiLayer = layer;
}

-(UserInterfaceLayer *)uiLayer
{
    return _uiLayer;
}


-(GameGroup*)currentGameGroup
{
    return _currentGameGroup;
}

-(GameLevel*)currentGameLevel
{
    return _currentGameLevel;
}

-(void)setCurrentGameGroup:(GameGroup*)group
{
    _currentGameGroup = group;
}

-(void)setCurrentGameLevel:(GameLevel*)level
{
    // call resetLevel to prepare level for playing
    [level resetLevel:LevelWinStatePlay];
    _currentGameLevel = level;
}

-(float)timeElapsedFromStart
{
    return [self currentGameLevel].currentTime;
}

-(bool)running
{
    if(_levelEnded)
    {
        _running = false;
    }
    
    return _running;
}

-(void)runManager
{
    // reset current couns and time elapsed
    [self currentGameLevel].currentTime = 0;
    _running = true;
    _levelEnded = false;
    //_timeElapsedFromStart = 0;
    _totFruitsSaved = 0;
    _totFruitsDestroyed = 0;
    _totEnemiesKilled = 0;
}

-(void)stopManager
{
    _running = false;
}

-(void)reportToGameCenter
{
    int totScore = self.gameConfigAndState.totalScore;
    int totStars = self.gameConfigAndState.totalStars;
    int totTimesPlayed = self.gameConfigAndState.totalTimesPlayed;
    //int totGoldenApples = self.gameConfigAndState.goldenApples;
        
    // Leaderboards: report tot score and stars
    [[GameKitHelper sharedInstance] leaderboardsReport:totScore 
                                              totStars:totStars];
    
    // Achieve: Report times played
    [[GameKitHelper sharedInstance] achieveReportTimesPlayed:totTimesPlayed];
    
    // Achieve: Report xy fruits picked
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit10GreenApples
                                                       value:self.gameConfigAndState.achieve10GreenApples 
                                                    maxValue:10.0f];
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit10RedApples
                                                       value:self.gameConfigAndState.achieve10RedApples 
                                                    maxValue:10.0f];
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit10Bananas
                                                       value:self.gameConfigAndState.achieve10Bananas 
                                                    maxValue:10.0f];
    
    // golden apples
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit1GoldenApple
                                                       value:self.gameConfigAndState.achieve1GoldenApple 
                                                    maxValue:1.0f];
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit3GoldenApple
                                                       value:self.gameConfigAndState.achieve3GoldenApple 
                                                    maxValue:3.0f];
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit7GoldenApple
                                                       value:self.gameConfigAndState.achieve7GoldenApple 
                                                    maxValue:7.0f];
    [[GameKitHelper sharedInstance] achieveReportPickXYFruit:kAchievePickyFruit10GoldenApple
                                                       value:self.gameConfigAndState.achieve10GoldenApple 
                                                    maxValue:10.0f];
    
    // levels passed with 3 stars
    [[GameKitHelper sharedInstance] achieveReportLevelPassed:kAchievePickyFruitPassedLevel18
                                                       value:self.gameConfigAndState.achieveLevel18With3Stars];
    [[GameKitHelper sharedInstance] achieveReportLevelPassed:kAchievePickyFruitPassedLevel33
                                                       value:self.gameConfigAndState.achieveLevel33With3Stars];
}

-(int)updateCurrentLevelAsPassed
{
    // call this when Level is passed. 
    // Update fruit score, time, and 
    // increase times played and passed.

    // set level time
    //self.currentGameLevel.currentTime = self.timeElapsedFromStart; // round float to 2 decimals
    //NSAssert(self.currentGameLevel.time == self.timeElapsedFromStart, @"Time elapsed is not equal to level time");
    
    // update level as Passed
    [self.currentGameLevel setAsPassed];
    // initial save to update timesPlayed and timesPassed
    [GameStateXmlHelper saveGameState:self.gameConfigAndState];
    // prepare scores for saving
    [self.currentGameLevel prepareForSaving];
    
    // if passed level 18 or 33 with 3 stars, update achievement
    if((self.currentGameLevel.number == 18 || self.currentGameLevel.number == 33)
       && (self.currentGameLevel.stateStars == kInt3))
    {
        // increase achievement
        // timer.userInfo is the fruit frameName
        [self.gameConfigAndState levelPassedWith3Stars:self.currentGameLevel.number];
    }
    
    // save only if the stateScore is greater then the prev score 
    // (then in the checkForEndLevel we make sure we revert prepareForSaving in case we did save)
    // This is necessary to allow the GameMenuLevelPassedLayer to display the correct temporary scores, 
    // even though the level has not be saved with an improved score
    if(self.currentGameLevel.stateScore > self.currentGameLevel.prevScore)
    {
        //CCLOG(@"updateCurrentLevelAsPassed: saving state because of improved score");
        // save scores state
        [GameStateXmlHelper saveGameState:self.gameConfigAndState];
        self.currentGameLevel.saved = true;
    }
    
    // return TotScore
    return self.gameConfigAndState.totalScore;
}

-(int)updateCurrentLevelAsFailed
{
    // call this when level is failed. 
    // Increase only times played.

    // update level as Failed
    [self.currentGameLevel setAsFailed];
    [self.currentGameLevel restorePreviousScores];
    // save to update timesPlayed and timesPassed
    [GameStateXmlHelper saveGameState:self.gameConfigAndState];
       
    // return TotScore
    return self.gameConfigAndState.totalScore;
}

/*-(int)updateCurrentLevelAsReplay
{
    // call this when level is replayed (either from LevelFailedLayer or LevelPassedLayer). 
    // Restore previous results.

    // reset current level for play with new win state of Replay
    [self.currentGameLevel resetLevel:LevelWinStateReplay];
    
    // return TotScore
    return self.gameConfigAndState.totalScore;
}*/

-(void)checkForEndLevel
{
    if(self.currentGameLevel.allGoalsReached)
    {
        [self stopManager];
        _levelEnded = true;
        
        //CCLOG(@"Level %d all goals reached", self.currentGameLevel.number);
        // passed so update score/time and increase both time played/passed:
        [self updateCurrentLevelAsPassed];
        
        // display Level Passed screen
        [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevelPassed
                                useTransition:false];
        
        // if NOT saved, restore previous score
        // (revert prepareForSaving in case we did save within the updateCurrentLevelAsPassed method)
        if(self.currentGameLevel.saved == false)
        {
            [self.currentGameLevel restorePreviousScores];
        }
    }
    
    //else if(self.currentGameLevel.goalFruitsDestroyed)
    else if(_totFruitsDestroyed == 10)
    {
        [self stopManager];
        _levelEnded = true;
        
        //CCLOG(@"Level %d destroyed too many fruits. Level failed", self.currentGameLevel.number);
        
        [self updateCurrentLevelAsFailed];
        
        // display Level Failed screen
        [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevelFailed
                                useTransition:false];
    }
}

-(void)increaseTimeElapsedFromStart:(float)dt
{
    if(self.running)
    {
        //_timeElapsedFromStart += dt;
        [self currentGameLevel].currentTime += dt;
        if(self.delegate)
        {
            [self.delegate didIncreaseTimeElapsedFromStart:self.timeElapsedFromStart];
        }
    }
}

-(void)increaseSavedFruits:(NSString *)fruitName
{
    if(self.running)
    {
        _totFruitsSaved++;
        if(self.delegate)
        {
            // send info to Tree System so that it can recreate the missing fruit if is part of the goal
            LevelGoal *goal = [[GameManager currentGameLevel] increaseGoalFruit:fruitName];
            [[[GameManager currentGameGroup] treeSystem] receiveMissingFruitName:fruitName
                                                                       levelGoal:goal
                                                                           saved:true];
            
            [self.delegate didIncreaseSavedFruits:goal 
                                        fruitName:fruitName
                                   totFruitsSaved:_totFruitsSaved];
            goal = nil;
            
            // increase achievement
            // timer.userInfo is the fruit frameName
            [self.gameConfigAndState achieveIncrease:fruitName];
        }
        
        [GameManager checkForEndLevel];
    }
}
-(void)decreaseSavedFruits:(NSString *)fruitName
{
    if(self.running && _totFruitsSaved > 0)
    {
        _totFruitsSaved--;
        if(self.delegate)
        {
            LevelGoal *goal = [[GameManager currentGameLevel] decreaseGoalFruit:fruitName];
            // goal could be nil and that is ok. Delegate method will check for that
            [self.delegate didDecreaseSavedFruits:goal
                                        fruitName:fruitName
                                   totFruitsSaved:_totFruitsSaved];
            goal = nil;
        }
        [GameManager checkForEndLevel];
    }
}
-(void)increaseDestroyedFruits:(NSString *)fruitName
{
    if(self.running)
    {
        _totFruitsDestroyed++;
        // decrease bonus
        [[GameManager currentGameLevel] decreaseCurrentBonus];
        if(self.delegate)
        {
            // send info to Tree System so that it can recreate the missing fruit if is part of the goal
            LevelGoal *goal = [[GameManager currentGameLevel] increaseDestroyedFruit:fruitName];
            
            [[[GameManager currentGameGroup] treeSystem] receiveMissingFruitName:fruitName
                                                                       levelGoal:goal
                                                                           saved:false];
            
            // goal could be nil and that is ok. Delegate method will check for that
            [self.delegate didIncreaseDestroyedFruits:goal
                                            fruitName:fruitName
                                   totFruitsDestroyed:_totFruitsDestroyed];
            goal = nil;
        }
        [GameManager checkForEndLevel];
    }
}

-(void)increaseSavedFruitsWithTimer:(NSTimer*)timer
{
    [self increaseSavedFruits:timer.userInfo];
}
-(void)decreaseSavedFruitsWithTimer:(NSTimer*)timer
{
    [self decreaseSavedFruits:timer.userInfo];
}
-(void)increaseDestroyedFruitsWithTimer:(NSTimer*)timer
{
    [self increaseDestroyedFruits:timer.userInfo];
}

// delayed functions
-(void)increaseSavedFruits:(NSString *)fruitFrameName
                 withDelay:(float)seconds
{
    if(self.running)
    {
        if(seconds > kFloat0)
        {
            // send delayed message to increase saved fruits to manager 
            [NSTimer scheduledTimerWithTimeInterval:seconds 
                                             target:self
                                           selector:@selector(increaseSavedFruitsWithTimer:) 
                                           userInfo:fruitFrameName 
                                            repeats:NO];
        }
        else
        {
            [self increaseSavedFruits:fruitFrameName];
        }
    }
}
-(void)decreaseSavedFruits:(NSString *)fruitFrameName
                 withDelay:(float)seconds
{
    if(self.running && _totFruitsSaved > kInt0)
    {
        if(seconds > kFloat0)
        {
            // send delayed message to decrease destroyed fruits to manager 
            [NSTimer scheduledTimerWithTimeInterval:seconds 
                                             target:self
                                           selector:@selector(decreaseSavedFruitsWithTimer:) 
                                           userInfo:fruitFrameName 
                                            repeats:NO];
        }
        else
        {
            [self decreaseSavedFruits:fruitFrameName];
        }
    }
}
-(void)increaseDestroyedFruits:(NSString*)fruitFrameName
                     withDelay:(float)seconds
{
    if(self.running)
    {
        if(seconds > kFloat0)
        {
            // send delayed message to increase destroyed fruits to manager 
            // so that user can see the fruit exploding
            [NSTimer scheduledTimerWithTimeInterval:seconds 
                                             target:self
                                           selector:@selector(increaseDestroyedFruitsWithTimer:) 
                                           userInfo:fruitFrameName 
                                            repeats:NO];
        }
        else
        {
            [self increaseDestroyedFruits:fruitFrameName];
        }
    }
}

-(void)initializeAnimations
{
    if(_animationInitialized == false)
    {
        // for now just called the shared imation manager so that it gets instantiated
        id am = [AnimationManager sharedAnimationManager];
        am = am != nil ? am : nil; // stupid code to avoid xcode warning of unused variable
        _animationInitialized = true;
    }
}

-(id)init
{
    if((self = [super init]))
    {   
        [self loadConfigAndState];
    }
    return self;
}

-(void)dealloc
{
    _delegate = NULL;
    
    [_gameConfigAndState release];
    _gameConfigAndState = nil;
    
    [_currentGameLevel release];
    _currentGameLevel = nil;
    
    [_currentGameGroup release];
    _currentGameGroup = nil;
    
    _gameLayer = nil;
    _uiLayer = nil;
    
    [super dealloc];
}

/*-(void)resetManager
{
    // reset current level counts
    _levelEnded = false;
    _timeElapsedFromStart = 0;
    _totFruitsSaved = 0;
    _totFruitsDestroyed = 0;
 _totEnemiesKilled = 0;
}*/

-(GameConfigAndState*)loadConfigAndState
{
    //CCLOG(@"GameManager: Releasing previous _gameConfigAndState before reloading");
    [_gameConfigAndState release];
    
    _gameConfigAndState = nil;
    _gameConfigAndState = [[GameStateXmlHelper loadGameConfigAndState] retain];
    
    return _gameConfigAndState;
}

// Game Kit Helper delegate functions
-(void)onLocalPlayerAuthenticationChanged
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		[[GameKitHelper sharedInstance] getLocalPlayerFriends];
		//[[GameKitHelper sharedInstance] resetAchievements];
	}	
}

-(void)onFriendListReceived:(NSArray*)friends
{
    //CCLOG(@"onFriendListReceived: %@", [friends description]);
	[[GameKitHelper sharedInstance] getPlayerInfo:friends]; 
}

-(void)onPlayerInfoReceived:(NSArray*)players
{
    //CCLOG(@"onPlayerInfoReceived: %@", [players description]);
	
	//[[GameKitHelper sharedInstance] submitScore:1234 category:@"LeaderBoardPickTheFruitScore"];
    
    //[gkHelper showLeaderboard];
	/*GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
	request.minPlayers = 2;
	request.maxPlayers = 4;
	
	[[GameKitHelper sharedInstance] showMatchmakerWithRequest:request];
	[[GameKitHelper sharedInstance] queryMatchmakingActivity];*/
}

-(void)onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
	
	if (success)
	{
		[[GameKitHelper sharedInstance] retrieveTopTenAllTimeGlobalScores];
	}
}

-(void)onScoresReceived:(NSArray*)scores
{
	//CCLOG(@"onScoresReceived: %@", [scores description]);
	//[[GameKitHelper sharedInstance] showLeaderboard];
    //[[GameKitHelper sharedInstance] showAchievements];
}

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	//CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void)onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
    [[GameKitHelper sharedInstance] retrieveTopTenAllTimeGlobalScores];
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
}

-(void) onMatchFound:(GKMatch*)match
{
	CCLOG(@"onMatchFound: %@", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(NSString*)playerID
{
	CCLOG(@"onPlayerConnected: %@", playerID);
}

-(void) onPlayerDisconnected:(NSString*)playerID
{
	CCLOG(@"onPlayerDisconnected: %@", playerID);
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
}

-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
	CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}


// end Game Kit Helper delegate methods


// static
+(GameManager *)sharedInstance
{
    if(!_gameManagerInstance)
    {
        _gameManagerInstance = [[GameManager create] retain];
    }
    
    return _gameManagerInstance;
}

+(GameConfigAndState *)gameConfigAndState
{
    return [GameManager sharedInstance].gameConfigAndState;
}

+(GameGroup *)currentGameGroup
{
    return [GameManager sharedInstance].currentGameGroup;
}

+(GameLevel *)currentGameLevel
{
    return [GameManager sharedInstance].currentGameLevel;
}

+(id)create
{
    return [[[self alloc] init] autorelease];
}

/*+(void)resetManager
{
    [[self sharedGameManager] resetManager];
}*/

+(void)runManager
{
    [[GameManager sharedInstance] runManager];
}

+(void)stopManager
{
    [[GameManager sharedInstance] stopManager];
}

+(void)cleanup
{   
    // Cleanup method is called within the AppDelegate dealloc method
    
    [AnimationManager cleanup];
    
    [_gameManagerInstance release];
    _gameManagerInstance = nil;
}

/*+(GameConfigAndState*)reloadConfigAndState
{
    GameManager *gameManager = [self sharedGameManager];
    [gameManager loadConfigAndState];
    return [gameManager gameConfigAndState];
}*/

+(bool)allLevelsUnlocked
{
    return [self sharedInstance].allLevelsUnlocked;
}

+(void)setAllLevelsUnlocked:(bool)unlocked
{
    [[self sharedInstance] setAllLevelsUnlocked:unlocked];
}

// game menu stuff and control
+(int)groupNumberSelected
{
    return [GameManager sharedInstance].currentGameGroup.number;
}

+(void)setGroupNumberSelected:(int)gn
{
    //[GameManager reset];// not necessary as done when current level is set
    GameManager *gameManager = [GameManager sharedInstance];
    GameGroup *group = [gameManager.gameConfigAndState getGroupByNumber:gn];
    [gameManager setCurrentGameGroup:group];
    group = nil;
}

+(void)setCurrentGameLevel:(GameLevel*)level
{
    [[GameManager sharedInstance] setCurrentGameLevel:level];
}

+(int)totalScore
{
    int ts = [GameManager sharedInstance].gameConfigAndState.totalScore;
    return ts;
}

+(int)totalStars
{
    int ts = [GameManager sharedInstance].gameConfigAndState.totalStars;
    return ts;
}

+(int)totalTimesPlayed
{
    int ts = [GameManager sharedInstance].gameConfigAndState.totalTimesPlayed;
    return ts;
}

+(TargetLayerEnum)targetLayerSelected
{
    return [GameManager currentGameGroup].targetLayer;
}

+(TargetLayerEnum)setCurrentLevelNumberAndGetTargetLayer:(int)ln
{
    GameManager *gameManager = [GameManager sharedInstance];
    
    GameLevel *level = [gameManager.gameConfigAndState getGameLevel:ln];
    [gameManager setCurrentGameLevel:level];
    level = nil;
    
    [self setGroupNumberSelected:gameManager.currentGameLevel.groupNumber];
    
    TargetLayerEnum tl = [self targetLayerSelected];
    return tl;
}

+(TargetLayerEnum)setNextGameLevelAndGetTargetGameLayer
{
    GameManager *gameManager = [GameManager sharedInstance];
    [gameManager stopManager];
    GameLevel *currentLevel = gameManager.currentGameLevel;
    
    // TODO: Need to add logic here to verify there is enough score to move to next level.
    // Also, if a new group is next, need to display a message that group has been unlocked
    int currentLevelNumber = currentLevel.number;
    int nextLevel = currentLevelNumber + 1;
    
    int gameGroups = gameManager.gameConfigAndState.numberOfGroups;
    int gameLevelsPerGroup = gameManager.gameConfigAndState.levelsPerGroup;
    
    int maxLevelAvailable = (gameGroups * gameLevelsPerGroup);
    if(nextLevel > maxLevelAvailable)
    {
        CCLOG(@"GameManager getNextTargetGameLayer: passed max level available. Resetting to level 1 and starting game from beginning");
        nextLevel = 1; // for now reset to first level and start game from beginning
    }
    currentLevel = nil;
    
    TargetLayerEnum tl = [GameManager setCurrentLevelNumberAndGetTargetLayer:nextLevel];
    return tl;
}

+(void)loadCurrentLevelLayer:(int)levelNumber
{
    [GameManager stopManager];
    
    // set the level selected and get the target layer
    TargetLayerEnum targetLayer = [GameManager setCurrentLevelNumberAndGetTargetLayer:levelNumber];    
    // load MultiLayerScene with selected Game layer
    [SceneHelper levelLoadingSceneWithTargetLayer:targetLayer
                                    useTransition:false];
    [GameManager runManager];
}

+(GameLevel *)peekNextLevel
{
    GameManager *gameManager = [GameManager sharedInstance];
    GameLevel *currentLevel = gameManager.currentGameLevel;
    
    int nextLevelNumber = currentLevel.number + 1;
    
    int gameGroups = gameManager.gameConfigAndState.numberOfGroups;
    int gameLevelsPerGroup = gameManager.gameConfigAndState.levelsPerGroup;
    
    int maxLevelAvailable = (gameGroups * gameLevelsPerGroup);
    if(nextLevelNumber > maxLevelAvailable)
    {
        CCLOG(@"GameManager getNextTargetGameLayer: passed max level available. Resetting to level 1 and starting game from beginning");
        nextLevelNumber = 1; // for now reset to first level and start game from beginning
    }
    currentLevel = nil;

    GameLevel *level = [gameManager.gameConfigAndState getGameLevel:nextLevelNumber];
    return level;
}

+(void)loadNextLevelLayer
{
    [GameManager stopManager];
    
    // load MultiLayerScene with selected Game Layer
    TargetLayerEnum targetLayer = [GameManager setNextGameLevelAndGetTargetGameLayer];
    [SceneHelper levelLoadingSceneWithTargetLayer:targetLayer
                                    useTransition:false];
    [GameManager runManager];
}

+(void)reloadCurrentLevelLayerForReplay
{
    [GameManager stopManager];
    
    // replaying, so reset Level to previous results
    //[[GameManager sharedGameManager] updateCurrentLevelAsReplay];
    
    int levelNumber = [GameManager currentGameLevel].number;
    
    TargetLayerEnum targetLayer = [GameManager setCurrentLevelNumberAndGetTargetLayer:levelNumber];    
    
    // load MultiLayerScene with current Game Layer
    [SceneHelper levelLoadingSceneWithTargetLayer:targetLayer
                                    useTransition:false];
    [GameManager runManager];
}

+(void)loadMenuLevels
{
    [GameManager stopManager];
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevels
                            useTransition:true];
}

+(void)loadMenuPlay
{
    [GameManager stopManager];
    // goes back to Play scene
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuPlay
                            useTransition:true];
}

+(void)increaseTimeElapsedFromStart:(float)dt
{
    if([GameManager sharedInstance].running)
    {
        [[GameManager sharedInstance] increaseTimeElapsedFromStart:dt];
    }
}

+(void)checkForEndLevel
{
    return [[GameManager sharedInstance] checkForEndLevel];
}

+(void)deleteGameState
{
    [GameConfigAndState deleteGameState];
}



@end
