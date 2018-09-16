//
//  LevelLoadingScene.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"
#import "LevelLoadingScene.h"
#import "GameManager.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "FruitSlotSpinnerSystem.h"


#define kStringFormatLoadingLevel @"Loading level %d"
#define kStringYourGoalForThisLevelIs @"Your goal for this level is:"


typedef enum{
    LevelLoadingSceneTagINVALID = 0,
    LevelLoadingSceneBackground,
    LevelLoadingSceneLabelLoading,
    LevelLoadingSceneLabelYourGoal,
    LevelLoadingSceneLevelGoalsLayer,
    LevelLoadingSceneTagMAX
} LevelLoadingSceneTags;


@implementation LevelLoadingScene

+(id)sceneWithTargetScene:(TargetSceneEnum)targetScene
           andTargetLayer:(TargetLayerEnum)targetLayer
{
    return [[[self alloc] initWithTargetScene:targetScene 
                               andTargetLayer:targetLayer] autorelease];
}

-(id)initWithTargetScene:(TargetSceneEnum)targetScene
          andTargetLayer:(TargetLayerEnum)targetLayer
{
    if((self = [super init]))
    {
        
        _targetScene = targetScene;
        _targetLayer = targetLayer;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileDarkBackground]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileDarkBackground];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        // Background
        CCSprite *spriteBackground = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameBackground];
        spriteBackground.position = [DevicePositionHelper screenCenter];
        [self addChild:spriteBackground z:-1 tag:LevelLoadingSceneBackground];
        [spriteBackground release];
        spriteBackground = nil;
        
        _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        _screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        
        [self setupLabels];
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)setupLabels
{
    GameLevel *level = [GameManager currentGameLevel];
    
    // add loading label
    float fontSize = kFloat1;
    
    // add Loading Level x label
    NSString *str = [[NSString alloc] initWithFormat:kStringFormatLoadingLevel, level.number];
    CCLabelBMFont *labelLoading = [[CCLabelBMFont alloc] initWithString:str fntFile:kBmpFontAll32];
    [str release];
    str = nil;
    labelLoading.anchorPoint = cgcenterone;
    labelLoading.scale = fontSize;
    UnitsPoint unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsSize.height - kInt4);
    labelLoading.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
    [self addChild:labelLoading z:kInt0 tag:LevelLoadingSceneLabelLoading];
    [labelLoading release];
    labelLoading = nil;
    
    
    unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsSize.height - kInt12);
    fontSize = kFloat0Point5;
    
    //  add Your Goal for this level is: label
    CCLabelBMFont *labelYourGoal = [[CCLabelBMFont alloc] initWithString:kStringYourGoalForThisLevelIs fntFile:kBmpFontAll32];
    labelYourGoal.anchorPoint = cgcenterone;
    labelYourGoal.scale = fontSize;
    labelYourGoal.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
    [self addChild:labelYourGoal z:kInt0 tag:LevelLoadingSceneLabelYourGoal];
    [labelYourGoal release];
    labelYourGoal = nil;
    
    
    // add fruit spinner to show goal
    unitsPosition = UnitsPointMake(_screenUnitsCenter.x, _screenUnitsCenter.y - kInt5);
    CGPoint pos = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
    _fruitSlotSpinner = [[FruitSlotSpinnerSystem alloc] initWithLevelGoals:level.levelGoals
                                                                   timeout:0.35f
                                                                nextTarget:nil
                                                                nextAction:nil];
    _fruitSlotSpinner.isTouchEnabled = false;
    CGSize contentSize = _fruitSlotSpinner.contentSize;
    //pos = ccp(_screenCenter.x-(contentSize.width/2), _screenCenter.y-(contentSize.height*2));
    pos = ccp(pos.x-(contentSize.width*kFloat0Point5), pos.y);
    //_fruitSlotSpinner.anchorPoint = cgcenterone;
    _fruitSlotSpinner.position = pos;
    [self addChild:_fruitSlotSpinner z:1 tag:LevelLoadingSceneLevelGoalsLayer];
    
    // create goals labels
    int cellWidth = _fruitSlotSpinner.cellWidth;
    int cellHalfWidth = _fruitSlotSpinner.cellHalfWidth;
    float gap = _fruitSlotSpinner.gap;
    
    //float scoreFontSize = [DevicePositionHelper cgFromUnits:2.0f]; 
    //ccColor3B labelScoreColor = ccc3(255, 255, 0);
    //CGPoint labelScoreAnchorPoint = ccp(0.5f, 1.0f);
    
    float labelTargetY = _fruitSlotSpinner.position.y + _fruitSlotSpinner.contentSize.height + gap;
    fontSize = kFloat0Point5;
    
    int i = -1;
    while(++i < level.levelGoals.count)
    {
        LevelGoal *goal = (LevelGoal*)[level.levelGoals objectAtIndex:i];
        
        float xpos = _fruitSlotSpinner.position.x + cellHalfWidth + ((cellWidth+gap) * i);
        
        // Label Target
        NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, goal.target];
        CCLabelBMFont *labelTarget = [[CCLabelBMFont alloc] initWithString:str fntFile:kBmpFontAll32];
        [str release];
        str = nil;
        labelTarget.scale = fontSize;
        labelTarget.anchorPoint = cgcenterzero;
        //labelTarget.color = labelTargetColor;
        labelTarget.position = ccp(xpos, labelTargetY);
        [self addChild:labelTarget z:kInt1];
        [labelTarget release];
        labelTarget = nil;
    }
}

-(void)dealloc
{
    CCLOG(@"LevelLoadingScene dealloc");
    //multiLayerSceneInstance = nil;

    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [_fruitSlotSpinner release];
    _fruitSlotSpinner = nil;
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileDarkBackground];
    
    [super dealloc];
}

-(void)onEnter
{
    CCLOG(@"LevelLoadingScene onEnter");
    [super onEnter];
}

-(void)onExit
{
    CCLOG(@"LevelLoadingScene onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)update:(ccTime)delta
{
    _timeElapsedFromStart += delta;
    
    // if 1 second has passed
    if(_timeElapsedFromStart > kFloat1Point5)
    {
        // unschedule so that Update is called only once
        [self unscheduleAllSelectors];
        // call select scene
        [self selectScene];
    }
}

-(void)selectScene
{
    switch (_targetScene) 
    {
        [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
            
        case TargetSceneMultiLayer:
        {
            // Can't use SceneHelper here
            MultiLayerScene *scene = [MultiLayerScene sceneWithTargetLayer:_targetLayer];
            [[CCDirector sharedDirector] replaceScene:scene];
            break;
        }
        default:
        {
            NSAssert2(nil, @"%@: unsupported TargetScene %i", NSStringFromSelector(_cmd), _targetScene);
            break;
        }
    }
}

@end
