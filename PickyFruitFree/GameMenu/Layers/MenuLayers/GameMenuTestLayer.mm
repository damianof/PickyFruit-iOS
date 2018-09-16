//
//  GameMenuTestLayer.mm
//
//  Created by Damiano Fusco on 1/21/12.
//  Copyright 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuTestLayer.h"
#import "GameMenuScene.h"
#import "DevicePositionHelper.h"
#import "SceneHelper.h"
//#import "GameManager.h"
#import "GameLevel.h"
#import "LoadingScene.h"


typedef enum
{
    GameMenuTestUIControlTagINVALID = 0,
    GameMenuTestUIControlTagMenu,
    GameMenuTestUIControlTagLabelDebug,
    GameMenuTestUIControlTagMAX
} GameMenuTestUIControlTags;

typedef enum
{
    GameMenuTestINVALID = 0,
    GameMenuTestSetCurrentLevel,
    GameMenuTestSetNextLevel,
    
    GameMenuTestUpdateCurrentLevelAsPassed,
    GameMenuTestUpdateCurrentLevelAsFailed,
    
    GameMenuTestMAX
} GameMenuTests;



@implementation GameMenuTestLayer


-(id)init
{
    if((self = [super init]))
    {
        _screenSize = [DevicePositionHelper screenRect].size;
        _screenCenter = [DevicePositionHelper screenCenter];
                
        float fontSize = [DevicePositionHelper cgFromUnits:2.0f];
        
        // menu
        // set font name/size
        [CCMenuItemFont setFontName:@"Marker Felt"];
        [CCMenuItemFont setFontSize:fontSize];
        
        // Set Current Level button
        /*
        CCMenuItemFont *menuItemSetCurrentLevel = [CCMenuItemFont itemFromString:@"Set Current Level to 1"
                                                                          target:self
                                                                        selector:@selector(performTest:)];
        menuItemSetCurrentLevel.tag = GameMenuTestSetCurrentLevel;
        CGPoint itemPosition = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(0,0)];
        menuItemSetCurrentLevel.position = itemPosition;
        
        // set Next Level button
        CCMenuItemFont *menuItemSetNextLevel = [CCMenuItemFont itemFromString:@"Set Next Level"
                                                                       target:self
                                                                     selector:@selector(performTest:)];
        menuItemSetNextLevel.tag = GameMenuTestSetNextLevel;
        itemPosition = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(0,3)];
        menuItemSetNextLevel.position = itemPosition;
        
        // add Main Menu button
        CCMenuItemFont *menuItemUpdateAsPassed = [CCMenuItemFont itemFromString:@"Update Current Level As Passed"
                                                                         target:self
                                                                       selector:@selector(performTest:)];
        menuItemUpdateAsPassed.tag = GameMenuTestUpdateCurrentLevelAsPassed;
        itemPosition = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(0,6)];
        menuItemUpdateAsPassed.position = itemPosition;
        
        // add Main Menu button
        CCMenuItemFont *menuItemUpdateAsFailed = [CCMenuItemFont itemFromString:@"Update Current Level As Failed"
                                                                         target:self
                                                                       selector:@selector(performTest:)];
        menuItemUpdateAsFailed.tag = GameMenuTestUpdateCurrentLevelAsFailed;
        itemPosition = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(0,8)];
        menuItemUpdateAsFailed.position = itemPosition;
        
        // add menu
        CCMenu *menu = [CCMenu menuWithItems:menuItemSetCurrentLevel, menuItemSetNextLevel, menuItemUpdateAsPassed, menuItemUpdateAsFailed, nil];
        menu.position = CGPointMake(_screenCenter.x, _screenCenter.y + (fontSize * 2));
        
        // remember to tag added CCMenu and remove it by tag in dealloc or
        // it will keep listening for touches in next scenes
        //CCLOG(@"GameMenuTestLayer: init, add menu");
        [self addChild:menu z:1 tag:GameMenuTestUIControlTagMenu];
        */
        
        // label Debug
        fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        _labelDebug = [CCLabelTTF labelWithString:@"Debug label"
                                         fontName:@"Marker Felt"
                                         fontSize:fontSize];
        _labelDebug.position =  CGPointMake(_screenCenter.x, _screenCenter.y + 10);
        [self addChild:_labelDebug z:0 tag:GameMenuTestUIControlTagLabelDebug];
        
        CCMenuItemFont *menuBack = [CCMenuItemFont itemFromString:@"Back to Main"
                                                           target:self
                                                         selector:@selector(backToMain)];
        CCMenu *menu = [CCMenu menuWithItems:menuBack, nil];
        menu.position = CGPointMake(_screenCenter.x, _screenCenter.y + (fontSize * 2));
        
        // remember to tag added CCMenu and remove it by tag in dealloc or
        // it will keep listening for touches in next scenes
        //CCLOG(@"GameMenuTestLayer: init, add menu");
        [self addChild:menu z:1 tag:GameMenuTestUIControlTagMenu];
        
        //[self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuTestLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(void)onExit
{
    CCLOG(@"GameMenuTestLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [super onExit];
}

-(void)update:(ccTime)dt
{
    //[GameManager increaseTimeElapsedFromStart:dt];
}

-(void)backToMain
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    GameMenuScene *scene = [LoadingScene sceneWithTargetScene:TargetSceneMenu
                                               andTargetLayer:TargetLayerMenuPlay]; //TargetLayerMenuPlay, TargetLayerMenuTest
	[[CCDirector sharedDirector] replaceScene:scene];
}
/*
-(void)updateDebugLabel
{
    int score = [GameManager currentGameLevel].stateScore;
    int prevScore = [GameManager currentGameLevel].prevScore;
    
    float time = [GameManager currentGameLevel].stateTime;
    float prevTime = [GameManager currentGameLevel].prevTime;
    
    //int timeScore = [GameManager currentGameLevel].timeScore;
    int starScore = [GameManager currentGameLevel].stateStarScore;
    int prevStarScore = [GameManager currentGameLevel].prevStarScore;
    
    NSString *strValue = [NSString initWithFormat:@"Time %.2f PrevTime %.2f | Score %d PrevScore %d | Star %d PrevStar %d"
                          , time, prevTime, score, prevScore, starScore, prevStarScore];
    
    [_labelDebug setString:strValue];

}

-(void)performTest:(id)menuItem
{
    int test = ((CCMenuItemFont*)menuItem).tag;
    CCLOG(@"performTest %d", test);
    
    GameManager *manager = [GameManager sharedInstance];
    if(test == GameMenuTestSetCurrentLevel)
    {
        [GameManager stopManager];
        [GameManager setCurrentLevelNumberAndGetTargetLayer:1]; 
        [GameManager runManager];
    }
    else if (test == GameMenuTestSetNextLevel)
    {
        [GameManager stopManager];
        [GameManager setNextGameLevelAndGetTargetGameLayer];
        [GameManager runManager];
    }
    
    else if(test == GameMenuTestUpdateCurrentLevelAsPassed)
    {
        [GameManager stopManager];
        [manager updateCurrentLevelAsPassed];
    }
    else if (test == GameMenuTestUpdateCurrentLevelAsFailed)
    {
        [GameManager stopManager];
        [manager updateCurrentLevelAsFailed];
    }
    
    [self updateDebugLabel];
}*/

@end
