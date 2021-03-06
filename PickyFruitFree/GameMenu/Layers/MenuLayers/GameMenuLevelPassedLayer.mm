//
//  GameMenuLevelPassedLayer.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuLevelPassedLayer.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "GameManager.h"
#import "GameLevel.h"
#import "SceneHelper.h"
#import "LevelPassedScoresLayer.h"
#import "ImprovedScoreLayer.h"
#import "FruitSlotSpinnerSystem.h"
#import "SimpleAudioEngine.h"


typedef enum{
    LevelPassedTagINVALID = 0,
    LevelPassedTagSpriteBackground,
    LevelPassedTagSpritePassed,
    LevelPassedTagStarScoreLayer,
    LevelPassedTagTimeScoreLayer,
    LevelPassedTagStarsLayer,
    LevelPassedTagGoalsLayer,
    LevelPassedTagFinalScoreLayer,
    LevelPassedTagFinalScoreLabelStatic,
    LevelPassedTagFinalScoreLabelDynamic,
    LevelPassedTagImprovedScoreLayer,
    LevelPassedTagMenu,
    
    LevelPassedTagSpriteNextDisabled,
    // clickable items add to end of enum to make easier if statement in touch handling
    LevelPassedTagSpriteReplay,
    LevelPassedTagSpriteMainMenu,
    LevelPassedTagSpriteNext,
    LevelPassedTagSpriteLevelSelect,
    LevelPassedTagMAX
} LevelPassedTags;

#define kLevelGoalsLayerBGColor ccc4(255, 255, 125, 0)

#define kStarScoreLayerFontSize 0.75f
#define kStarScoreLayerSize CGSizeMake(166, 24)
#define kStarScoreLayerBGColor ccc4(255, 125, 0, 70)
#define kStarScoreLayerLabelText @"Goal Score:"

#define kTimeScoreLayerFontSize 0.75f
#define kTimeScoreLayerSize CGSizeMake(166, 24)
#define kTimeScoreLayerBGColor ccc4(125, 255, 0, 70)
#define kTimeScoreLayerLabelText @"Time Score:"

#define kFinalScoreLayerFontSize 1.0f
#define kFinalScoreLayerSize CGSizeMake(225, 28)
#define kFinalScoreLayerBGColor ccc4(0, 0, 255, 70)
#define kFinalScoreLayerLabelText @"Final Score:"

@implementation GameMenuLevelPassedLayer


/*+(id)scene
{
    CCScene *scene = [CCScene node];
    GameMenuLevelPassedLayer *layer = [GameMenuLevelPassedLayer node];
    [scene addChild:layer];
    return scene;
}*/

-(id)init
{
    if((self = [super init]))
    {       
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileStarScore64]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileStarScore64]; 
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileLevelPassedFailed]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileLevelPassedFailed];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileDarkBackground]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileDarkBackground];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
        
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        _currentLevel = [GameManager currentGameLevel];
        _screenCenter = [DevicePositionHelper screenCenter];
        _screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        _spriteScaleForLevelGoalsLayer = kFloat1;
        
        UnitsPoint screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        
        //CCLOG(@"Screen Rect %.2f %.2f %.2f %.2f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
        
        // Background
        CCSprite *spriteBackground = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameBackground];
        spriteBackground.position = _screenCenter;
        [self addChild:spriteBackground z:-1 tag:LevelPassedTagSpriteBackground];
        [spriteBackground release];
        spriteBackground = nil;
       
        // Display Awesome message
        NSString *frameNamePassed = nil;
        if(_currentLevel.stateStars == 3)
        {
            frameNamePassed = kSpriteFrameNameAwesome;
        }
        else if(_currentLevel.stateStars == 2)
        {
            frameNamePassed = kSpriteFrameNameGreat;
        }
        else 
        {
            frameNamePassed = kSpriteFrameNameGoodEnough;
        }
        CCSprite *spritePassed = [[CCSprite alloc] initWithSpriteFrameName:frameNamePassed];
        frameNamePassed = nil;
        spritePassed.anchorPoint = cgcenterone;
        UnitsPoint unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsSize.height-kFloat1Point5);
        spritePassed.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:spritePassed z:0 tag:LevelPassedTagSpritePassed];
        [spritePassed release];
        spritePassed = nil;
        
        // menu
        // levels select button (left)
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(kInt2, kInt2)];
        CCSprite *spriteLevelSelect = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUILevelSelect];
        spriteLevelSelect.anchorPoint = cgzero;
        spriteLevelSelect.position = position;
        [self addChild:spriteLevelSelect z:kInt0 tag:LevelPassedTagSpriteLevelSelect];
        [spriteLevelSelect release];
        spriteLevelSelect = nil;
        
        // add Next (center)
        CCSprite *spriteNext = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameNext];
        spriteNext.anchorPoint = cgcenterzero;
        unitsPosition = UnitsPointMake(screenUnitsCenter.x, kInt1);
        spriteNext.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        int tagNext = LevelPassedTagSpriteNext;
        if ([GameManager peekNextLevel].enabled == false) {
            spriteNext.opacity = 128;
            tagNext = LevelPassedTagSpriteNextDisabled;
        }
        [self addChild:spriteNext z:0 tag:tagNext];
        [spriteNext release];
        spriteNext = nil;
        
        // add Replay Now (on the right)
        CCSprite *spriteReplay = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUIReplay];
        spriteReplay.anchorPoint = cgonezero;
        unitsPosition = UnitsPointMake(screenUnitsSize.width - kInt2, kInt2);
        spriteReplay.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:spriteReplay z:0 tag:LevelPassedTagSpriteReplay];
        [spriteReplay release];
        spriteReplay = nil;
        
        /*// add Main Menu button
        CCSprite *spriteMainMenu = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameMainMenu];
        spriteMainMenu.anchorPoint = cgonezero;
        unitsPosition = UnitsPointMake(screenUnitsSize.width - kInt1, kInt1);
        spriteMainMenu.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:spriteMainMenu z:0 tag:LevelPassedTagSpriteMainMenu];
        [spriteMainMenu release];
        spriteMainMenu = nil;*/
        
        // report to game center
        [[GameManager sharedInstance] reportToGameCenter];
                
        // call the setup level goals method which will also fire the addxyzScoreLayer methods
        [self setupLevelGoalsLayer];
        [self setupLevelStarsLayer];
        [self addStarScoreLayer];
        [self addTimeScoreLayer];
        [self addFinalScoreLayer];
    }
    return self;
}

-(void)addStarScoreLayer
{
    // star score layer
    _starScoreLayer = [LevelPassedScoresLayer createWithColor:kStarScoreLayerBGColor
                                                         size:kStarScoreLayerSize
                                                    labelText:kStarScoreLayerLabelText
                                               scoreToAnimate:_currentLevel.stateStars
                                                    scoreBase:kStarScoreBase
                                                        delay:0.5f
                                                     fontSize:kStarScoreLayerFontSize
                                               hideOnComplete:true];
    
    _starScoreLayer.position = ccp(_screenCenter.x-(kStarScoreLayerSize.width*kFloat0Point5), _screenCenter.y+(kStarScoreLayerSize.height*kFloat0Point5));
    [self addChild:_starScoreLayer z:kInt0 tag:LevelPassedTagStarScoreLayer];
}

-(void)addTimeScoreLayer
{
    // time score layer
    _timeScoreLayer = [LevelPassedScoresLayer createWithColor:kTimeScoreLayerBGColor
                                                         size:kTimeScoreLayerSize
                                                    labelText:kTimeScoreLayerLabelText
                                               scoreToAnimate:_currentLevel.stateTimeScore
                                                    scoreBase:kInt1
                                                        delay:1.5f
                                                     fontSize:kTimeScoreLayerFontSize
                                               hideOnComplete:true];
    
    _timeScoreLayer.position = ccp(_screenCenter.x-(kTimeScoreLayerSize.width*kFloat0Point5), _starScoreLayer.position.y-kTimeScoreLayerSize.height*kFloat0Point9);
    [self addChild:_timeScoreLayer z:kInt0 tag:LevelPassedTagTimeScoreLayer];
}

-(void)addFinalScoreLayer
{
    // final score layer
    // add improved score sprite only if this is not the first time they played this level (timesPassed > kInt1)
    // and only if the current score (stateScore) is greater than the previous score (prevScore)
    bool addImprovedScoreSprite = (_currentLevel.timesPassed > kInt1 && _currentLevel.stateScore > _currentLevel.prevScore);
    
    _finalScoreLayer = [LevelPassedScoresLayer createWithColor:kFinalScoreLayerBGColor
                                                          size:kFinalScoreLayerSize
                                                     labelText:kFinalScoreLayerLabelText
                                                scoreToAnimate:_currentLevel.stateScore
                                                     scoreBase:kInt1
                                                         delay:2.6f
                                                      fontSize:kFinalScoreLayerFontSize
                                                hideOnComplete:false
                                                bonusLabelText:@"Bonus"
                                           bonusScoreToAnimate:_currentLevel.stateBonus
                                        addImprovedScoreSprite:addImprovedScoreSprite];
    
    _finalScoreLayer.position = ccp(_screenCenter.x-(kFinalScoreLayerSize.width*kFloat0Point5), _timeScoreLayer.position.y-kFinalScoreLayerSize.height*kFloat0Point9);
    [self addChild:_finalScoreLayer z:kInt0 tag:LevelPassedTagFinalScoreLayer];
}

-(void)setupLevelGoalsLayer
{
    GameLevel *level = [GameManager currentGameLevel];
    
    // Base measurement on sprite dimension so that it will automatically scale on different devices
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kSpriteFrameNameAppleRed];
    //tempSprite.scale = _spriteScaleForLevelGoalsLayer;
    float cellWidth = frame.rect.size.width * _spriteScaleForLevelGoalsLayer;
    float cellHeight = frame.rect.size.height * _spriteScaleForLevelGoalsLayer;
    float cellHalfWidth = cellWidth * kTwoInverted;
    float gap = cellWidth * kFiveInverted;
    
    int numOfGoals = level.levelGoals.count;
    int levelGoalsLayerTotWidth = ((cellWidth+gap) * numOfGoals) + gap;
    int levelGoalsLayerTotHeight = cellHeight + (gap*7);
    
    // Layer
    CGSize scoreLayerSize = CGSizeMake(levelGoalsLayerTotWidth, levelGoalsLayerTotHeight);
    _levelGoalsLayer = [CCLayerColor layerWithColor:kLevelGoalsLayerBGColor
                                              width:scoreLayerSize.width 
                                             height:scoreLayerSize.height];
    _levelGoalsLayer.isTouchEnabled = false;
    UnitsPoint unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsCenter.y * 1.5f);
    //UnitsPoint unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsCenter.y);
    CGPoint pos = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
    pos = ccp(pos.x - (scoreLayerSize.width*kTwoInverted), pos.y - (scoreLayerSize.height*kTwoInverted));
    _levelGoalsLayer.position = pos;
    [self addChild:_levelGoalsLayer z:kInt0 tag:LevelPassedTagGoalsLayer];
    
    // create labels
    float fontSize = kFloat1; 
    CGPoint labelTargetAnchorPoint = ccp(kFloat0Point5, kFloat1);    
    CGPoint spriteAnchorPoint = ccp(kFloat0Point5, kFloat1);    
    CGPoint labelScoreAnchorPoint = ccp(kFloat0Point5, kFloat1);
    
    for(LevelGoal *goal in level.levelGoals)
    {
        float xpos = (cellHalfWidth + ((cellWidth+gap) * (goal.tag-kInt1)) + gap);
        
        // Label Target
        NSString *strTarget = [[NSString alloc] initWithFormat:kStringFormatInt, goal.target];
        CCLabelBMFont *labelTarget = [[CCLabelBMFont alloc] initWithString:strTarget fntFile:kBmpFontDigits16];
        labelTarget.scale = fontSize;
        [strTarget release];
        strTarget = nil;
        labelTarget.anchorPoint = labelTargetAnchorPoint;
        labelTarget.position = ccp(xpos, scoreLayerSize.height*0.975f);
        [_levelGoalsLayer addChild:labelTarget z:kInt1 tag:(kInt100 + goal.tag)];
        [labelTarget release];
        labelTarget = nil;
        
        // Sprite
        CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:goal.fruitName];
        sprite.scale = _spriteScaleForLevelGoalsLayer;
        sprite.anchorPoint = spriteAnchorPoint;
        sprite.position = ccp(xpos, scoreLayerSize.height - (gap*kFloat3Point5));
        [_levelGoalsLayer addChild:sprite z:kInt0 tag:(kInt101 + goal.tag)];
        [sprite release];
        sprite = nil;
        
        // Label Score
        NSString *strScore = [[NSString alloc] initWithFormat:kStringFormatInt, goal.stateCount];
        CCLabelBMFont *labelScore = [[CCLabelBMFont alloc] initWithString:strScore fntFile:kBmpFontDigits16];
        labelScore.scale = fontSize;
        [strScore release];
        strScore = nil;
        labelScore.anchorPoint = labelScoreAnchorPoint;
        labelScore.position = ccp(xpos, scoreLayerSize.height - (cellHeight+(gap*3.75f)) );
        [_levelGoalsLayer addChild:labelScore z:kInt1 tag:goal.tag];
        [labelScore release];
        labelScore = nil;
    }
}

-(void)setupLevelStarsLayer
{
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kImageForStarInLevelPassedLayer];
    float spriteWidth = frame.rect.size.width;
    float spriteHeight = frame.rect.size.height;
    frame = nil;
    float spriteHalfWidth = spriteWidth * kTwoInverted;
    float gap = spriteWidth * kTenInverted;
    
    int numOfStars = _currentLevel.stateStars;
    int starsLayerTotWidth = ((spriteWidth+gap) * kInt3) + gap; // fixed width to 3 stars
    int starsLayerTotHeight = spriteHeight;
    
    // Layer
    CGSize layerSize = CGSizeMake(starsLayerTotWidth, starsLayerTotHeight);
    _levelStarsLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)
                                              width:layerSize.width 
                                             height:layerSize.height];
    _levelStarsLayer.isTouchEnabled = false;
    CGPoint pos = _screenCenter;
    _levelStarsLayer.position = ccp(pos.x-(layerSize.width*kFloat0Point5), pos.y-(layerSize.height*kFloat1Point75));
    [self addChild:_levelStarsLayer z:kInt0 tag:LevelPassedTagStarsLayer];
    
    // Stars
    for(int i = 0; i < numOfStars; i++)
    {
        float xpos = (spriteHalfWidth + ((spriteWidth+gap) * i) + gap);
        
        // Sprite
        CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kImageForStarInLevelPassedLayer];
        //sprite.scale = 1.0f;
        //sprite.anchorPoint = cgcenter;
        sprite.position = ccp(xpos, spriteHalfWidth);
        [_levelStarsLayer addChild:sprite z:0 tag:i];
        [sprite release];
        sprite = nil;
    }
    for(int i = numOfStars; i < 3; i++)
    {
        float xpos = (spriteHalfWidth + ((spriteWidth+gap) * i) + gap);
        
        // Sprite
        CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:kImageForStarDisabledInLevelPassedLayer];
        sprite.scale = 1.0f;
        //sprite.anchorPoint = cgcenter;
        sprite.position = ccp(xpos, spriteHalfWidth);
        [_levelStarsLayer addChild:sprite z:0 tag:i];
        [sprite release];
        sprite = nil;
    }
}

-(void)dealloc
{
    CCLOG(@"GameMenuLevelPassedLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:YES];
    
    _starScoreLayer = nil;
    _timeScoreLayer = nil;
    _finalScoreLayer = nil;
    _levelStarsLayer = nil;
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileStarScore64];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileLevelPassedFailed];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileDarkBackground];
    
    [super dealloc];
}

-(void)onEnter
{
    CCLOG(@"GameMenuLevelPassedLayer onEnter %d", self.retainCount);
    [super onEnter];
    //[[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxLevelPassed];
    
    //[_starScoreLayer scheduleUpdate];
    //[_timeScoreLayer scheduleUpdate];
    //[_finalScoreLayer scheduleUpdate];
}

-(void)onExit
{
    CCLOG(@"GameMenuLevelPassedLayer onExit %d", self.retainCount);
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)loadNextLevel
{
    CCLOG(@"GameMenuLevelPassedLayer loadNextLevel %d", self.retainCount);
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [GameManager loadNextLevelLayer];
}

-(void)loadMainMenu
{
    CCLOG(@"GameMenuLevelPassedLayer loadMainMenu %d", self.retainCount);
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    // back to Menu Play
    [GameManager loadMenuPlay];
}

-(void)replayCurrentLevel
{
    CCLOG(@"GameMenuLevelPassedLayer replayCurrentLevel %d", self.retainCount);
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
            
            if ((sprite.tag >= LevelPassedTagSpriteReplay && sprite.tag < LevelPassedTagMAX)
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
        case LevelPassedTagSpriteMainMenu:
        {
            [self loadMainMenu];
            break;
        }
        case LevelPassedTagSpriteReplay:
        {
            [self replayCurrentLevel];
            break;
        }
        case LevelPassedTagSpriteNext:
        {
            [self loadNextLevel];
            break;
        }
        case LevelPassedTagSpriteLevelSelect:
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
