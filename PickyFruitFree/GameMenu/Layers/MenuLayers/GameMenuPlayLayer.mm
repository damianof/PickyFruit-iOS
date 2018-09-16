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
#import "GameConfigAndState.h"
#import "SimpleAudioEngine.h"

#import "GameKitHelper.h"


typedef enum{
    GameMenuPlayTagINVALID = 0,
    
    GameMenuPlayTagSpriteBackground,
    GameMenuPlayTagSpriteFreeEdition,
    GameMenuPlayTagSpritePlayNow,
    GameMenuPlayTagSpriteTwitter,
    GameMenuPlayTagSpriteFaceBook,
    GameMenuPlayTagSpriteDigg,
    GameMenuPlayTagSpriteCDBaby,
    GameMenuPlayTagSpriteCredits,
    GameMenuPlayTagSpriteResetGame,
    GameMenuPlayTagSpriteMusicOn,
    GameMenuPlayTagSpriteMusicOff,
    GameMenuPlayTagSpriteSoundsOn,
    GameMenuPlayTagSpriteSoundsOff,
    GameMenuPlayTagLayerAchievements,
    
    GameMenuPlayTagLabelTotalScore,
    GameMenuPlayTagLabelTotalStars,
    GameMenuPlayTagLabelTotalTimesPlayed,
    GameMenuPlayTagLabelAchievements,
    GameMenuPlayTagMAX
} GameMenuPlayTags;


@implementation GameMenuPlayLayer


-(id)init
{
    if((self = [super init]))
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
        
        // textures with retain count 1 will be removed
        // you can add this line in your scene#dealloc method
        //[[CCTextureCache sharedTextureCache] removeAllTextures];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
        
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFilePlayMenu]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFilePlayMenu];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileAchievements]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileAchievements];
        
        //CCLOG(@"GameMenuPlayLayer init");
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        //CGPoint screenCenter = [DevicePositionHelper screenCenter];

        // add background
        CCSprite *spriteBackground = [[CCSprite alloc] initWithSpriteFrameName:@"PlayBackground"];
        spriteBackground.anchorPoint = cgzero;
        spriteBackground.position = cgzero;
        [self addChild:spriteBackground z:0 tag:GameMenuPlayTagSpriteBackground];
        [spriteBackground release];
        spriteBackground = nil;
        
        // FREE EDITION
        UnitsPoint unitsPosition = UnitsPointMake(screenUnitsSize.width, screenUnitsSize.height);
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteFreeEdition = [[CCSprite alloc] initWithSpriteFrameName:@"FreeEdition"];
        spriteFreeEdition.anchorPoint = cgoneone;
        spriteFreeEdition.position = position;
        [self addChild:spriteFreeEdition z:0 tag:GameMenuPlayTagSpriteFreeEdition];
        [spriteFreeEdition release];
        spriteFreeEdition = nil;
        
    // begin: social icons
        // add Twitter
        unitsPosition = UnitsPointMake(4, 9);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteTwitter = [[CCSprite alloc] initWithSpriteFrameName:@"twitter"];
        spriteTwitter.anchorPoint = cgzero;
        spriteTwitter.position = position;
        [self addChild:spriteTwitter z:0 tag:GameMenuPlayTagSpriteTwitter];
        [spriteTwitter release];
        spriteTwitter = nil;
        
        // add FaceBook
        unitsPosition = UnitsPointMake(9, 9);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteFaceBook = [[CCSprite alloc] initWithSpriteFrameName:@"facebook"];
        spriteFaceBook.anchorPoint = cgzero;
        spriteFaceBook.position = position;
        [self addChild:spriteFaceBook z:0 tag:GameMenuPlayTagSpriteFaceBook];
        [spriteFaceBook release];
        spriteFaceBook = nil;
        
        // add Digg
        unitsPosition = UnitsPointMake(14, 9);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteDigg = [[CCSprite alloc] initWithSpriteFrameName:@"digg"];
        spriteDigg.anchorPoint = cgzero;
        spriteDigg.position = position;
        [self addChild:spriteDigg z:0 tag:GameMenuPlayTagSpriteDigg];
        [spriteDigg release];
        spriteDigg = nil;
        
        // add CDBaby
        unitsPosition = UnitsPointMake(19, 9);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteCDBaby = [[CCSprite alloc] initWithSpriteFrameName:@"cdbaby"];
        spriteCDBaby.anchorPoint = cgzero;
        spriteCDBaby.position = position;
        [self addChild:spriteCDBaby z:0 tag:GameMenuPlayTagSpriteCDBaby];
        [spriteCDBaby release];
        spriteCDBaby = nil;
        
    // end: social icons
        
        // add Play Now
        unitsPosition = UnitsPointMake(4, 2);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spritePlayNow = [[CCSprite alloc] initWithSpriteFrameName:@"PlayNow"];
        spritePlayNow.anchorPoint = cgzero;
        spritePlayNow.position = position;
        [self addChild:spritePlayNow z:0 tag:GameMenuPlayTagSpritePlayNow];
        [spritePlayNow release];
        spritePlayNow = nil;
        
        // add Reset
        unitsPosition = UnitsPointMake(screenUnitsSize.width-2.5f, 5);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteReset = [[CCSprite alloc] initWithSpriteFrameName:@"Reset"];
        spriteReset.anchorPoint = cgoneone;
        spriteReset.position = position;
        [self addChild:spriteReset z:0 tag:GameMenuPlayTagSpriteResetGame];
        [spriteReset release];
        spriteReset = nil;
        
        // add Credits
        unitsPosition = UnitsPointMake(screenUnitsSize.width-2, 10);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        //position = CGPointMake(position.x-spriteReset.boundingBox.size.width, position.y);
        CCSprite *spriteCredits = [[CCSprite alloc] initWithSpriteFrameName:@"Credits"];
        spriteCredits.anchorPoint = cgoneone;
        spriteCredits.position = position;
        [self addChild:spriteCredits z:0 tag:GameMenuPlayTagSpriteCredits];
        [spriteCredits release];
        spriteCredits = nil;
        
        // add Sounds button
        bool soundsOn = [SimpleAudioEngine sharedEngine].soundsOn;
        unitsPosition = UnitsPointMake(screenUnitsSize.width-16, 6.5f);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteSoundsOff = [[CCSprite alloc] initWithSpriteFrameName:@"SoundsOff"];
        spriteSoundsOff.anchorPoint = cgoneone;
        spriteSoundsOff.position = position;
        spriteSoundsOff.visible = (soundsOn == false);
        [self addChild:spriteSoundsOff z:0 tag:GameMenuPlayTagSpriteSoundsOff];
        [spriteSoundsOff release];
        spriteSoundsOff = nil;
        
        CCSprite *spriteSoundsOn = [[CCSprite alloc] initWithSpriteFrameName:@"SoundsOn"];
        spriteSoundsOn.anchorPoint = cgoneone;
        spriteSoundsOn.position = position;
        spriteSoundsOn.visible = soundsOn;
        [self addChild:spriteSoundsOn z:1 tag:GameMenuPlayTagSpriteSoundsOn];
        [spriteSoundsOn release];
        spriteSoundsOn = nil;
        
        // add Music button
        bool musicOn = [SimpleAudioEngine sharedEngine].musicOn;
        unitsPosition = UnitsPointMake(screenUnitsSize.width-23, 6.5f);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteMusicOff = [[CCSprite alloc] initWithSpriteFrameName:@"MusicOff"];
        spriteMusicOff.anchorPoint = cgoneone;
        spriteMusicOff.position = position;
        spriteMusicOff.visible = (musicOn == false);
        [self addChild:spriteMusicOff z:0 tag:GameMenuPlayTagSpriteMusicOff];
        [spriteMusicOff release];
        spriteMusicOff = nil;
        
        CCSprite *spriteMusicOn = [[CCSprite alloc] initWithSpriteFrameName:@"MusicOn"];
        spriteMusicOn.anchorPoint = cgoneone;
        spriteMusicOn.position = position;
        spriteMusicOn.visible = musicOn;
        [self addChild:spriteMusicOn z:1 tag:GameMenuPlayTagSpriteMusicOn];
        [spriteMusicOn release];
        spriteMusicOn = nil;
        
        // label Total Score
        int totalScore = [GameManager totalScore];
        float fontSize = kFloat0Point5;
        NSString *strTotScore = [[NSString alloc] initWithFormat:kStringFormatTotalScore, totalScore];
        CCLabelBMFont *labelTotScore = [[CCLabelBMFont alloc] initWithString:strTotScore fntFile:kBmpFontAll32];
        labelTotScore.scale = fontSize;
        [strTotScore release];
        strTotScore = nil;
        unitsPosition = UnitsPointMake(4, screenUnitsSize.height-3);
        labelTotScore.anchorPoint = cgzeroone;
        labelTotScore.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelTotScore z:0 tag:GameMenuPlayTagLabelTotalScore];
        [labelTotScore release];
        labelTotScore = nil;
        
        // label Total Stars
        int totalStars = [GameManager totalStars];
        //fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        NSString *strTotStars = [[NSString alloc] initWithFormat:kStringFormatTotalStars, totalStars];
        CCLabelBMFont *labelTotStars = [[CCLabelBMFont alloc] initWithString:strTotStars fntFile:kBmpFontAll32];
        labelTotStars.scale = fontSize;
        [strTotStars release];
        strTotStars = nil;
        unitsPosition = UnitsPointMake(4, screenUnitsSize.height-6);
        labelTotStars.anchorPoint = cgzeroone;
        labelTotStars.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelTotStars z:0 tag:GameMenuPlayTagLabelTotalStars];
        [labelTotStars release];
        labelTotStars = nil;
        
        // label Total Times Played
        int totalTimesPlayed = [GameManager totalTimesPlayed];
        //fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        NSString *strTotTimesPLayed = [[NSString alloc] initWithFormat:kStringFormatTimesPlayed, totalTimesPlayed];
        CCLabelBMFont *labelTotTimesPlayed = [[CCLabelBMFont alloc] initWithString:strTotTimesPLayed fntFile:kBmpFontAll32];
        labelTotTimesPlayed.scale = fontSize;
        [strTotTimesPLayed release];
        strTotTimesPLayed = nil;
        unitsPosition = UnitsPointMake(4, screenUnitsSize.height-9);
        labelTotTimesPlayed.anchorPoint = cgzeroone;
        labelTotTimesPlayed.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelTotTimesPlayed z:0 tag:GameMenuPlayTagLabelTotalTimesPlayed];
        [labelTotTimesPlayed release];
        labelTotTimesPlayed = nil;
        
        // add AChievements layer
        unitsPosition = UnitsPointMake(4, screenUnitsSize.height-13);
        CCLabelBMFont *labelAchievements = [[CCLabelBMFont alloc] initWithString:@"Achievements:" fntFile:kBmpFontAll32];
        labelAchievements.scale = fontSize;
        labelAchievements.anchorPoint = cgzeroone;
        labelAchievements.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        //labelAchievements.color = ccc3(204,96,0);
        labelAchievements.opacity = kInt0;
        [self addChild:labelAchievements z:0 tag:GameMenuPlayTagLabelAchievements];
        // release
        // labelAchievements is released at the end of the if statments below
        
        unitsPosition = UnitsPointMake(4, screenUnitsSize.height-19.5f);
        _layerAchievements = [[CCLayerColor alloc] initWithColor:ccc4(255,255,255,0)
                                                           width:32
                                                          height:32];
        _layerAchievements.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_layerAchievements z:1 tag:GameMenuPlayTagLayerAchievements];
        
        GameConfigAndState *gameState = [GameManager sharedInstance].gameConfigAndState;
        
        // add Golden Apples achievements
        unitsPosition = UnitsPointMake(0, 0);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        float ypos = position.y;
        if(gameState.didAchieveAtLeastOneGoldenApple)
        {
            NSString *frameName = nil;
            if(gameState.achieve10GoldenApple == 10) {
                frameName = kSpriteFrameNameAchieveAppleGolden10;
            }
            else if(gameState.achieve7GoldenApple == 7) {
                frameName = kSpriteFrameNameAchieveAppleGolden7;
            }
            else if(gameState.achieve3GoldenApple == 3) {
                frameName = kSpriteFrameNameAchieveAppleGolden3;
            }
            else if(gameState.achieve1GoldenApple == 1) {
                frameName = kSpriteFrameNameAchieveAppleGolden1;
            }
            
            CCSprite *spriteGoldenApple = [[CCSprite alloc] initWithSpriteFrameName:frameName];
            frameName = nil;
            spriteGoldenApple.anchorPoint = cgzero;
            spriteGoldenApple.position = position;
            [_layerAchievements addChild:spriteGoldenApple];
            [spriteGoldenApple release];
            spriteGoldenApple = nil;
        }
        
        // add Level Passed achievements
        if(gameState.achieveLevel18With3Stars == kInt1)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchieveLevel18];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        if(gameState.achieveLevel33With3Stars == kInt1)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchieveLevel33];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        
        // add Played xyz times achievements
        /*if(gameState.totalTimesPlayed == kInt100)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchievePlayed100Times];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        if(gameState.totalTimesPlayed == kInt200)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchievePlayed200Times];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }*/
        
        // add AppleRed and Green achievements
        if(gameState.achieve10RedApples == kInt10)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchieveAppleRed10];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        if(gameState.achieve10GreenApples == kInt10)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchieveAppleGreen10];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        if(gameState.achieve10Bananas == kInt10)
        {
            CCNode *lastItem = [[_layerAchievements children] lastObject];
            CGPoint origin = lastItem.boundingBox.origin;
            position  = ccp(origin.x + lastItem.boundingBox.size.width, ypos);
            CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAchieveBananas10];
            sprite.anchorPoint = cgzero;
            sprite.position = position;
            [_layerAchievements addChild:sprite];
            [sprite release];
            sprite = nil;
        }
        
        if(_layerAchievements.children.count < 1)
        {
            labelAchievements.opacity = 0;
        }
        else
        {
            [_layerAchievements setContentSize:CGSizeMake(_layerAchievements.children.count*32, 32)];
            labelAchievements.opacity = 255;
        }
        [labelAchievements release];
        labelAchievements = nil;
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuPlayLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [_layerAchievements removeAllChildrenWithCleanup:YES];
    [_layerAchievements release];
    _layerAchievements = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    // textures with retain count 1 will be removed
    // you can add this line in your scene#dealloc method
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFilePlayMenu];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileAchievements];
    
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnter];
}

-(void)onExit
{
    CCLOG(@"GameMenuPlayLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

    [super onExit];
}

-(void)loadGroupLevels
{
    // load the GameMenuGroupLevels
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    _spriteTouched.color = ccWHITE;
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuGroupLevels
                            useTransition:true]; //TargetLayerMenuGroupLevels TargetLayerMenuTest
}

-(void)loadGameCredits
{
    // load the GameCreditsLayer
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    _spriteTouched.color = ccWHITE;
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuCredits
                            useTransition:true];
}

-(void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //CCLOG(@"alertView %d", buttonIndex);
    // reset game here
    
    if(buttonIndex == kInt1)
    {
        [self unscheduleAllSelectors];
        [GameManager deleteGameState];
        
        NSString *strTotScore = [[NSString alloc] initWithFormat:kStringFormatTotalScore, kInt0];
        [(CCLabelBMFont*)[self getChildByTag:GameMenuPlayTagLabelTotalScore] setString:strTotScore];
        [strTotScore release];
        strTotScore = nil;
        NSString *strTotStars = [[NSString alloc] initWithFormat:kStringFormatTotalStars, kInt0];
        [(CCLabelBMFont*)[self getChildByTag:GameMenuPlayTagLabelTotalStars] setString:strTotStars];
        [strTotStars release];
        strTotStars = nil;
        NSString *strTotTimesPLayed = [[NSString alloc] initWithFormat:kStringFormatTimesPlayed, kInt0];
        [(CCLabelBMFont*)[self getChildByTag:GameMenuPlayTagLabelTotalTimesPlayed] setString:strTotTimesPLayed];
        [strTotTimesPLayed release];
        strTotTimesPLayed = nil;
        
        // remove achievements items
        if(_layerAchievements)
        {
            [[self getChildByTag:GameMenuPlayTagLabelAchievements] removeFromParentAndCleanup:YES];
            [_layerAchievements removeAllChildrenWithCleanup:YES];
        }
        
        UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Reset Scores"
                                                         message:@"Scores have been reset."
                                                        delegate:self 
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [prompt show];
        [prompt release];
        prompt = nil;
    }
    
    // reset sprite color
    _spriteTouched.color = ccWHITE;
    _promptVisible = false;
}

-(void)resetGamePrompt
{
    _promptVisible = true;
    [self unscheduleAllSelectors];

    /*UIActionSheet *prompt = [[UIActionSheet alloc] 
                             initWithTitle:@"Reset Scores"
                             message:@"Are you sure you want to reset all the scores to zero?" 
                             delegate:self 
                             cancelButtonTitle:@"Cancel" 
                             destructiveButtonTitle:@"Reset"
                             otherButtonTitles:nil];*/
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Reset Scores"
                                                     message:@"Are you sure you want to reset the scores? This cannot be undone."
                                                    delegate:self 
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    [prompt show];
    [prompt release];
    prompt = nil;
}

-(void)switchMusicPreference
{
    CCNode *spriteOn = [self getChildByTag:GameMenuPlayTagSpriteMusicOn];
    CCNode *spriteOff = [self getChildByTag:GameMenuPlayTagSpriteMusicOff];
    
    if(spriteOn.visible)
    {
        spriteOn.visible = false;
        
    }
    else
    {
        spriteOn.visible = true;
        
    }
    [SimpleAudioEngine setMusicOn:spriteOn.visible];
    
    [[NSUserDefaults standardUserDefaults] setBool:spriteOn.visible forKey:kUserDefaultsKeyMusicOn];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    spriteOff.visible = !spriteOn.visible;
}

-(void)switchSoundsPreference
{
    CCNode *spriteOn = [self getChildByTag:GameMenuPlayTagSpriteSoundsOn];
    CCNode *spriteOff = [self getChildByTag:GameMenuPlayTagSpriteSoundsOff];
    
    if(spriteOn.visible)
    {
        spriteOn.visible = false;
        
    }
    else
    {
        spriteOn.visible = true;
        
    }
    [SimpleAudioEngine setSoundsOn:spriteOn.visible];
    
    [[NSUserDefaults standardUserDefaults] setBool:spriteOn.visible forKey:kUserDefaultsKeySoundsOn];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    spriteOff.visible = !spriteOn.visible;
}

-(void)switchTouch
{
    int tmp = _tagTouched;
    switch (tmp) 
    {
        case GameMenuPlayTagSpritePlayNow:
        {
            [self loadGroupLevels];
            break;
        }
        case GameMenuPlayTagSpriteResetGame:
        {
            if(_promptVisible == false)
            {
                [self resetGamePrompt];
            }
            break;
        }
        case GameMenuPlayTagSpriteCredits:
        {
            // TODO: display options screen
            // for now, flip allLevelsUnlocked flag for testing
            //_spriteTouched.color = ccBLUE;
            //[GameManager setAllLevelsUnlocked:!GameManager.allLevelsUnlocked];
            [self loadGameCredits];
            break;
        }
        case GameMenuPlayTagSpriteMusicOn:
        case GameMenuPlayTagSpriteMusicOff:
        {
            [self switchMusicPreference];
            break;
        }
        case GameMenuPlayTagSpriteSoundsOn:
        case GameMenuPlayTagSpriteSoundsOff:
        {
            [self switchSoundsPreference];
            break;
        }
        case GameMenuPlayTagSpriteTwitter:
        {
            NSString* launchUrl = @"http://twitter.com/PickyFruit";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            break;
        }
        case GameMenuPlayTagSpriteFaceBook:
        {
            NSString* launchUrl = @"http://www.facebook.com/PickyFruit";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            break;
        }
        case GameMenuPlayTagSpriteDigg:
        {
            NSString* launchUrl = @"http://digg.com/pickyfruit";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            break;
        }
        case GameMenuPlayTagSpriteCDBaby:
        {
            NSString* launchUrl = @"http://www.cdbaby.com/dfmichael";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            break;
        }
        default:
        {
            break;
        }
    };
}

// touch handling
-(void)checkTouch:(UITouch*)touch
{
    for (id item in self.children)
	{
        if([item isKindOfClass:[CCSprite class]])
        {
            CCSprite *sprite = (CCSprite*)item;
            
            if (sprite.tag != GameMenuPlayTagSpriteBackground
                && sprite.tag != GameMenuPlayTagSpriteFreeEdition
                && [sprite isTouchOnSprite:touch])
            {
                _spriteTouched = sprite;
                _spriteTouched.color = 
                sprite.tag == GameMenuPlayTagSpriteMusicOn
                || sprite.tag == GameMenuPlayTagSpriteMusicOff
                || sprite.tag == GameMenuPlayTagSpriteSoundsOn
                || sprite.tag == GameMenuPlayTagSpriteSoundsOff
                ? ccWHITE
                : ccRED;
                _tagTouched = sprite.tag;
                // break loop
                break;
            }
        }
	}   
}
    
-(BOOL) ccTouchBegan:(UITouch *)touch 
           withEvent:(UIEvent *)event
{
    _tagTouched = -1;
    
    [self checkTouch:touch];
    
	return _tagTouched != -1;
}

-(void) ccTouchEnded:(UITouch *)touch 
           withEvent:(UIEvent *)event
{
    if (_tagTouched != -1)
    {
        [self switchTouch];
    }
    else if(_spriteTouched)
    {
        _spriteTouched.color = ccWHITE;
        _spriteTouched = nil;
    }
}

-(void) ccTouchCancelled:(UITouch *)touch 
               withEvent:(UIEvent *)event
{
    [self checkTouch:touch];
    if (_tagTouched != -1)
    {
        [self switchTouch];
    }
    else
    {
        if(_spriteTouched)
        {
            _spriteTouched.color = ccWHITE;
            _spriteTouched = nil;
        }
        _tagTouched = -1;
    }
}

-(void) ccTouchMoved:(UITouch *)touch 
           withEvent:(UIEvent *)event
{
    _tagTouched = -1;
    [self checkTouch:touch];
    if(_spriteTouched && _tagTouched == -1)
    {
        _spriteTouched.color = ccWHITE;
        _spriteTouched = nil;
    }
}



@end
