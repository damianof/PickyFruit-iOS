//
//  GameMenuPlayLayer.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuPlayLayer.h"
#import "GameMenuScene.h"
#import "DevicePositionHelper.h"
#import "SceneHelper.h"
#import "GameManager.h"

#import "GameKitHelper.h"


typedef enum{
    GameMenuPlayTagINVALID = 0,
    GameMenuPlayTagMenu,
    GameMenuPlayTagLabelPlay,
    GameMenuPlayTagLabelResetGame,
    GameMenuPlayTagLabelTotalScore,
    GameMenuPlayTagLabelTotalStars,
    GameMenuPlayTagLabelTotalTimesPlayed,
    GameMenuPlayTagMAX
} GameMenuPlayTags;


@implementation GameMenuPlayLayer


-(id)init
{
    if((self = [super init]))
    {
        // textures with retain count 1 will be removed
        // you can add this line in your scene#dealloc method
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        
        //CCLOG(@"GameMenuPlayLayer init");
        CGSize screenSize = [DevicePositionHelper screenRect].size;
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        float fontSize = [DevicePositionHelper cgFromUnits:3.0f];
        
        [CCMenuItemFont setFontName:kMarkerFelt];
        [CCMenuItemFont setFontSize:fontSize];
        
        CCMenuItemFont *item1 = [CCMenuItemFont itemFromString:@"Play Now"
                                                        target:self
                                                      selector:@selector(loadGroupLevels:)];
        item1.tag = GameMenuPlayTagLabelPlay;
        CCMenuItemFont *item2 = [CCMenuItemFont itemFromString:@"Reset Game"
                                                        target:self
                                                      selector:@selector(resetGame:)];
    
        item2.tag = GameMenuPlayTagLabelResetGame;
        item2.position = CGPointMake(item1.position.x, item1.position.y - (fontSize*2.5f));
        
        CCMenu *playMenu = [CCMenu menuWithItems:item1, item2, nil];
        playMenu.position = CGPointMake(screenCenter.x, screenCenter.y + 30);
        
        // remember to tag added CCMenu and remove it by tag in dealloc or
        // it will keep listening for touches in next scenes
        [self addChild:playMenu z:0 tag:GameMenuPlayTagMenu];
        
        // label Total Score
        int totalScore = [GameManager totalScore];
        fontSize = 0.5f;
        NSString *strTotScore = [[NSString alloc] initWithFormat:kStringFormatTotalScore, totalScore];
        _labelTotScore = [CCLabelBMFont labelWithString:strTotScore fntFile:kBmpFont32All];
        _labelTotScore.scale = fontSize * CC_CONTENT_SCALE_FACTOR();
        [strTotScore release];
        strTotScore = nil;
        _labelTotScore.position = CGPointMake(playMenu.position.x, screenSize.height*0.25);
        [self addChild:_labelTotScore z:0 tag:GameMenuPlayTagLabelTotalScore];
        
        // label Total Stars
        int totalStars = [GameManager totalStars];
        //fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        NSString *strTotStars = [[NSString alloc] initWithFormat:kStringFormatTotalStars, totalStars];
        _labelTotStars = [CCLabelBMFont labelWithString:strTotStars fntFile:kBmpFont32All];
        _labelTotStars.scale = fontSize * CC_CONTENT_SCALE_FACTOR();
        [strTotStars release];
        strTotStars = nil;
        _labelTotStars.position = CGPointMake(playMenu.position.x, _labelTotScore.position.y-(fontSize*50.0));
        [self addChild:_labelTotStars z:0 tag:GameMenuPlayTagLabelTotalStars];
        
        // label Total Times Played
        int totalTimesPlayed = [GameManager totalTimesPlayed];
        //fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        NSString *strTotTimesPLayed = [[NSString alloc] initWithFormat:kStringFormatTimesPlayed, totalTimesPlayed];
        _labelTotTimesPlayed = [CCLabelBMFont labelWithString:strTotTimesPLayed fntFile:kBmpFont32All];
        _labelTotTimesPlayed.scale = fontSize * CC_CONTENT_SCALE_FACTOR();
        [strTotTimesPLayed release];
        strTotTimesPLayed = nil;
        _labelTotTimesPlayed.position = CGPointMake(playMenu.position.x, _labelTotStars.position.y-(fontSize*50.0));
        [self addChild:_labelTotTimesPlayed z:0 tag:GameMenuPlayTagLabelTotalTimesPlayed];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuPlayLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    
    // textures with retain count 1 will be removed
    // you can add this line in your scene#dealloc method
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnter];
    
    // set GameKitHelper delegate to GameManager
    [[GameKitHelper sharedInstance] setDelegate:[GameManager sharedInstance]];
    [[GameKitHelper sharedInstance] authenticateLocalPlayer];
}

-(void)onExit
{
    CCLOG(@"GameMenuPlayLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];

    [super onExit];
}

-(void)loadGroupLevels:(id)sender
{
    // load the GameMenuGroupLevels
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuGroupLevels]; //TargetLayerMenuGroupLevels TargetLayerMenuTest
}

-(void)resetGame:(id)sender
{
    /*[self unscheduleAllSelectors];
    [GameManager deleteGameState];
    
    CCMenu *playMenu = (CCMenu*)[self getChildByTag:GameMenuPlayTagMenu];
    CCMenuItemFont *item = (CCMenuItemFont*)[playMenu getChildByTag:GameMenuPlayTagLabelResetGame];
     
    [item setString:@"Game state has been resetted"];*/
}


@end
