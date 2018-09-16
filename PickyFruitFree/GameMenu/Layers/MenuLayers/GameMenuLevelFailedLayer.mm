//
//  GameMenuLevelFailedLayer.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/9/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuLevelFailedLayer.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "GameManager.h"
#import "DevicePositionHelper.h"
#import "SceneHelper.h"
#import "SimpleAudioEngine.h"

typedef enum
{
    LevelFailedTagINVALID = 0,
    LevelFailedTagSpriteBackground,
    LevelFailedTagSpriteFailed,
    // add clickable items to the end of enum:
    LevelFailedTagSpriteMainMenu,
    LevelFailedTagSpriteReplay,
    LevelFailedTagSpriteLevelSelect,
    LevelFailedTagMAX
} LevelFailedTags;


@implementation GameMenuLevelFailedLayer

/*+(id)scene
{
    CCScene *scene = [CCScene node];
    GameMenuLevelFailedLayer *layer = [GameMenuLevelFailedLayer node];
    [scene addChild:layer];
    return scene;
}*/

-(id)init
{
    if((self = [super init]))
    {
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileLevelPassedFailed]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileLevelPassedFailed];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileDarkBackground]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileDarkBackground];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
        
        _spriteScaleForLevelGoalsLayer = kFloat1;
        
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        UnitsPoint screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        
        _currentLevel = [GameManager currentGameLevel];
        
        // Background
        CCSprite *spriteBackground = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameBackground];
        spriteBackground.position = screenCenter;
        [self addChild:spriteBackground z:-1 tag:LevelFailedTagSpriteBackground];
        [spriteBackground release];
        spriteBackground = nil;
        
        // Display Failed message
        CCSprite *spriteFailed = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameLevelFailed];
        spriteFailed.position = screenCenter;
        [self addChild:spriteFailed z:kInt0 tag:LevelFailedTagSpriteFailed];
        [spriteFailed release];
        spriteFailed = nil;
        
        // menu
        // levels select button
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(kInt2, kInt2)];
        CCSprite *spriteLevelSelect = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUILevelSelect];
        spriteLevelSelect.anchorPoint = cgzero;
        spriteLevelSelect.position = position;
        [self addChild:spriteLevelSelect z:kInt0 tag:LevelFailedTagSpriteLevelSelect];
        [spriteLevelSelect release];
        spriteLevelSelect = nil;
        
        // add Replay Now
        position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsCenter.x, kInt2)];
        CCSprite *spriteReplay = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUIReplay];
        spriteReplay.anchorPoint = cgcenterzero;
        spriteReplay.position = position;
        [self addChild:spriteReplay z:kInt0 tag:LevelFailedTagSpriteReplay];
        [spriteReplay release];
        spriteReplay = nil;
        
        // add Main Menu button
        position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsSize.width - kInt2, kInt2)];
        CCSprite *spriteMainMenu = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameMainMenu];
        spriteMainMenu.anchorPoint = cgonezero;
        spriteMainMenu.position = position;
        [self addChild:spriteMainMenu z:kInt0 tag:LevelFailedTagSpriteMainMenu];
        [spriteMainMenu release];
        spriteMainMenu = nil;
        
        // report to game center
        [[GameManager sharedInstance] reportToGameCenter];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuLevelFailedLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileLevelPassedFailed];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileDarkBackground];
    
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"GameMenuLevelFailedLayer onEnter");
    [super onEnter];
    [[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxLevelFailed];
}

-(void)onExit
{
    //CCLOG(@"GameMenuLevelFailedLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

-(void)loadNextLevel
{   
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [GameManager loadNextLevelLayer];
}

-(void)loadMainMenu
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    // back to Menu Play
    [GameManager loadMenuPlay];
}

-(void)replayCurrentLevel
{    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [GameManager reloadCurrentLevelLayerForReplay];
}

// touch handling
-(void)checkTouch:(UITouch*)touch
{
    for (id item in self.children)
	{
        if([item isKindOfClass:[CCSprite class]])
        {
            CCSprite *sprite = (CCSprite*)item;
            
            if ((sprite.tag >= LevelFailedTagSpriteMainMenu && sprite.tag < LevelFailedTagMAX)
                && [sprite isTouchOnSprite:touch])
            {
                _spriteTouched = sprite;
                _spriteTouched.color = ccRED;
                _tagTouched = sprite.tag;
                // break loop
                break;
            }
        }
	}   
}

-(void)loadLevelSelect
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    // back to Menu Levels
    [GameManager loadMenuLevels];
}

-(void)switchTouch
{
    int tmp = _tagTouched;
    switch (tmp) 
    {
        case LevelFailedTagSpriteMainMenu:
        {
            [self loadMainMenu];
            break;
        }
        case LevelFailedTagSpriteReplay:
        {
            [self replayCurrentLevel];
            break;
        }
        case LevelFailedTagSpriteLevelSelect:
        {
            [self loadLevelSelect];
            break;
        }
        default:
        {
            break;
        }
    };
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
