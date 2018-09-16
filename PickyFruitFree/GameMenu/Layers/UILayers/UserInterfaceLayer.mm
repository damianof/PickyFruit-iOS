//
//  UserInterfaceLayer.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
#import "UserInterfaceLayer.h"
#import "CCLayerWithWorld.h"
#import "GameManager.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "GameManager.h"
#import "GameGroup.h"
#import "DevicePositionHelper.h"
#import "SceneHelper.h"
#import "TreeSystemInfo.h"

/*struct FruitFrameCount
{
    NSString    *frame;
    int count;
};*/

#define kUILayerTagSpriteGoalGoldenApple 97835276

typedef enum{
    UILayerTagINVALID = 0,
    UILayerTagLabelTimeStatic,
    UILayerTagLabelTime,
    UILayerTagLabelLivesStatic,
    UILayerTagLabelLives,
    UILayerTagLabelBonusStatic,
    UILayerTagLabelBonusRemaining,
    UILayerTagLevelGoalsLayer,
    UILayerTagMAX
} UILayerTags;

@implementation UserInterfaceLayer


//@synthesize 
//    gameLayer = _gameLayer;

/*+(id)scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [UserInterfaceLayer node];
    [scene addChild:layer];
    return scene;
 }*/

/*-(void)setGameLayer:(CCLayerWithWorld *)layer
{
    _gameLayer = layer;
}*/

-(id)init
{
    if ((self = [super initWithColor:ccc4(255,255,255,0)]))
	//if ((self = [super init]))
	{
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileUIImages]];
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileFruit32]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileUIImages];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileFruit32];
        
        _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        _drawUnitsGrid = true;
        
        // set Delegate
        [[GameManager sharedInstance] setDelegate:self];
        
        _spriteScaleForLevelGoalsLayer = kFloat0Point5;
        [self setupLevelGoalsLayer];
        
        _truckSpeed = -([GameManager currentGameGroup].treeSystemInfo.speed*0.7f);
        [[GameManager sharedInstance].gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                                                  message:@"initial"
                                                               floatValue:_truckSpeed
                                                              stringValue:nil];
        _truckSpeedIncrement = kFloat0Point2;
        
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        UnitsPoint screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        
        CCSprite* uibackground = [[CCSprite alloc] initWithSpriteFrameName:[GameManager currentGameGroup].uiBackgroundImage];
        //uibackground.opacity = 96;
        uibackground.position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(kInt0, 5.5f)];
        uibackground.anchorPoint = cgzeroone;
        [self addChild:uibackground z:kInt0 tag:kInt0];
        [uibackground release];
        uibackground = nil;
        
        // add back to menu item
        CCSprite *spritePause = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUILevelSelect];
        CCSprite *spritePauseSelected = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUILevelSelect];
        spritePauseSelected.color = ccYELLOW;
        CCMenuItemSprite* backMenuItem =[CCMenuItemSprite itemFromNormalSprite:spritePause 
                                                                selectedSprite:spritePauseSelected                   
                                                                        target:self 
                                                                      selector:@selector(buttonBackTapped:)];
        [spritePause release];
        spritePause = nil;
        [spritePauseSelected release];
        spritePauseSelected = nil;
        
        //backMenuItem.anchorPoint = cgzero;
        UnitsPoint backMenuItemPosition = UnitsPointMake(backMenuItem.position.x, backMenuItem.position.y);
        
        //UnitsSize backMenuSize = [DevicePositionHelper unitsSizeFromSize:[backMenuItem boundingBox].size];
        int screenFirstQuarterX = screenUnitsCenter.x * kTwoInverted;
        int screenThirdQuarterX = screenUnitsCenter.x + screenFirstQuarterX;
        UnitsPoint unitsPosition;
        
        // Group Label (position on the right size, 1 unit from screen edge
        //float fontSize = [DevicePositionHelper cgFromUnits:1.5f];
        
        // ------- labels ----------------
        // label Time Elapsed
        // static
        unitsPosition = UnitsPointMake(screenFirstQuarterX-2, 3.4f);
        _labelTimeStatic = [[CCLabelBMFont alloc] initWithString:@"Time" fntFile:kBmpFontUI16];
        _labelTimeStatic.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_labelTimeStatic z:kInt0 tag:UILayerTagLabelTimeStatic];
        // value
        unitsPosition = UnitsPointMake(screenFirstQuarterX+3, 3.4f);
        _labelTimeElapsed = [[CCLabelBMFont alloc] initWithString:@"0.0" fntFile:kBmpFontUI16];
        _labelTimeElapsed.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_labelTimeElapsed z:kInt0 tag:UILayerTagLabelTime];
        
        // label Lives
        // static
        unitsPosition = UnitsPointMake(screenFirstQuarterX-2, 1.3f);
        _labelLivesStatic = [[CCLabelBMFont alloc] initWithString:@"Lives" fntFile:kBmpFontUI16];
        _labelLivesStatic.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_labelLivesStatic z:kInt0 tag:UILayerTagLabelLivesStatic];
        // value
        unitsPosition = UnitsPointMake(screenFirstQuarterX+3, 1.3f);
        _labelLivesRemaining = [[CCLabelBMFont alloc] initWithString:@"10" fntFile:kBmpFontUI16];
        _labelLivesRemaining.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_labelLivesRemaining z:kInt0 tag:UILayerTagLabelLives];
        
        // label Bonus static
        unitsPosition = UnitsPointMake(screenThirdQuarterX, 3.4f);
        CCLabelBMFont *labelBonusStatic = [[CCLabelBMFont alloc] initWithString:@"Bonus" fntFile:kBmpFontUI16];
        labelBonusStatic.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelBonusStatic z:kInt0 tag:UILayerTagLabelBonusStatic];
        [labelBonusStatic release];
        labelBonusStatic = nil;
        
        // label Bonus value on next line
        unitsPosition = UnitsPointMake(screenThirdQuarterX, 1.3f);
        NSString *strAvailBonus = [[NSString alloc] initWithFormat:kStringFormatInt, [GameManager currentGameLevel].currentBonus];
        _labelBonusRemaining = [[CCLabelBMFont alloc] initWithString:strAvailBonus fntFile:kBmpFontUI16];
        [strAvailBonus release];
        strAvailBonus = nil;
        _labelBonusRemaining.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:_labelBonusRemaining z:kInt0 tag:UILayerTagLabelBonusRemaining];
        
        // add truck back button
        CCSprite *spriteTruckBack = [[CCSprite alloc] initWithSpriteFrameName:@"UILayerTruckBack"];
        CCSprite *spriteTruckBackSelected = [[CCSprite alloc] initWithSpriteFrameName:@"UILayerTruckBack"];
        spriteTruckBackSelected.color = ccYELLOW;
        // increase button bounding box horizontally for better touch
        _truckBackMenuItem =[CCMenuItemSprite itemFromNormalSprite:spriteTruckBack 
                                                    selectedSprite:spriteTruckBackSelected                   
                                                            target:self 
                                                          selector:nil]; //@selector(buttonTruckBackTapped:)
        [spriteTruckBack release];
        spriteTruckBack = nil;
        [spriteTruckBackSelected release];
        spriteTruckBackSelected = nil;
        _truckBackMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsCenter.x-kFloat5, backMenuItemPosition.y)];
        
        
        // add truck forwardbutton
        CCSprite *spriteTruckFwd = [[CCSprite alloc] initWithSpriteFrameName:@"UILayerTruckFwd"];
        CCSprite *spriteTruckFwdSelected = [[CCSprite alloc] initWithSpriteFrameName:@"UILayerTruckFwd"];
        spriteTruckFwdSelected.color = ccYELLOW;
        _truckFwdMenuItem =[CCMenuItemSprite itemFromNormalSprite:spriteTruckFwd 
                                                   selectedSprite:spriteTruckFwdSelected                   
                                                           target:self 
                                                         selector:nil]; //@selector(buttonTruckForwardTapped:)
        [spriteTruckFwd release];
        spriteTruckFwd = nil;
        [spriteTruckFwdSelected release];
        spriteTruckFwdSelected = nil;
        _truckFwdMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsCenter.x+kFloat3, backMenuItemPosition.y)];
        
        
        // add Replay button
        CCSprite *spriteReplay = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUIReplay];
        CCSprite *spriteReplaySelected = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameUIReplay];
        spriteReplaySelected.color = ccYELLOW;
        CCMenuItemSprite* replayMenuItem =[CCMenuItemSprite itemFromNormalSprite:spriteReplay 
                                                                  selectedSprite:spriteReplaySelected                   
                                                                          target:self 
                                                                        selector:@selector(buttonReplayTapped:)];
        [spriteReplay release];
        spriteReplay = nil;
        [spriteReplaySelected release];
        spriteReplaySelected = nil;
        replayMenuItem.anchorPoint = ccp(kFloat1Point5, kFloat0Point5);
        unitsPosition = UnitsPointMake(_screenUnitsSize.width - 1, backMenuItemPosition.y);
        replayMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        
        // add debug button
        /* debugMenuItem.position = ccp(replayMenuItem.position.x - 60, replayMenuItem.position.y);*/
        
        
        // add items to menu 
        CCMenu *uiMenu = [CCMenu menuWithItems:backMenuItem, _truckBackMenuItem, _truckFwdMenuItem, replayMenuItem, nil];
        // add menu
        //uiMenu.anchorPoint = cgzero;
        UnitsPoint uiMenuUnitsPos = UnitsPointMake(kFloat2, kFloat2Point5);
        uiMenu.position = [DevicePositionHelper pointFromUnitsPoint:uiMenuUnitsPos];
        [self addChild:uiMenu z:kInt0 tag:kTagUIMenu];
        
        // this layer should have touch disabled
        self.isTouchEnabled = NO;
        
        /*CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"StarryNight.plist"];
        ps.positionType = kCCPositionTypeGrouped;
        ps.position = [DevicePositionHelper screenCenter];
        [self addChild:ps z:2000 tag:214151];*/
        
        _livesRemain = 10;
        
        [self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{    
    CCLOG(@"UserInterfaceLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[GameManager sharedInstance] setDelegate:nil];
    [self removeAllChildrenWithCleanup:YES];
    
    [_labelTimeElapsed release];
    _labelTimeElapsed = nil;
    
    [_labelTimeStatic release];
    _labelTimeStatic = nil;
    
    [_labelLivesStatic release];
    _labelLivesStatic = nil;
    
    [_labelLivesRemaining release];
    _labelLivesRemaining = nil;
    
    [_labelBonusRemaining release];
    _labelBonusRemaining = nil;
    
    [_levelGoalsLayer release];
    _levelGoalsLayer = nil;
    
    _truckBackMenuItem = nil;
    _truckFwdMenuItem = nil;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileUIImages];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileFruit32];
    
    [super dealloc];
}

/*-(void)draw
{
    if(_drawUnitsGrid)
    {
        glEnable(GL_LINE_SMOOTH);
        glLineWidth(0.1f);
        
        // draw units grid in UI Layer for positioning UI Layer buttons etc.
        glColor4f(0.2, 0.2, 0.0, 1.0);  
        for (int i = 1; i < _screenUnitsSize.width; i++) {
            CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(i,1)];
            CGPoint p2 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(i,4)];
            ccDrawLine( p1, p2 );
        }
        
        for (int i = 1; i < 6; i++) {
            CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(1,i)];
            CGPoint p2 = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(_screenUnitsSize.width-1,i)];
            ccDrawLine( p1, p2 );
        }
    }
}*/

-(void)update:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        if(_truckBackMenuItem.isSelected)
        {
            //CCLOG(@"UserInterfaceLayer truckBackButton selected");
            _truckSpeed += _truckSpeedIncrement;
            if(_truckSpeed > 5.0f){
                _truckSpeed = 5.0f;
            }
            [[GameManager sharedInstance].gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                                                      message:@"rew"
                                                                   floatValue:_truckSpeed
                                                                  stringValue:nil];
        }
        else if(_truckFwdMenuItem.isSelected)
        {
            //CCLOG(@"UserInterfaceLayer truckForwardButton selected");
            _truckSpeed -= _truckSpeedIncrement;
            if(_truckSpeed < -5.0f){
                _truckSpeed = -5.0f;
            }
            [[GameManager sharedInstance].gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                                                      message:@"fwd"
                                                                   floatValue:_truckSpeed
                                                                  stringValue:nil];
        }
        else
        {
            if(_truckSpeed != _truckPrevSpeed)
            {
                CCLOG(@"UserInterfaceLayer: stop speed");
                [[GameManager sharedInstance].gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                                                          message:@"stop"
                                                                       floatValue:_truckSpeed
                                                                      stringValue:nil];
                _truckPrevSpeed = _truckSpeed;
            }
        }
        
        if(_timeElapsed > 30) 
        {
            _elapsedForHighTimeBlink += dt;            
            if(_elapsedForHighTimeBlink > kFloat0Point5){
                _labelTimeStatic.color = ccWHITE;
                _labelTimeElapsed.color = _labelTimeStatic.color;
                _elapsedForHighTimeBlink = kFloat0;
            }
            if(_elapsedForHighTimeBlink > kFloat0Point25){
                _labelTimeStatic.color = ccRED;
                _labelTimeElapsed.color = _labelTimeStatic.color;
            }
        }
        
        if(_livesRemain < 2)
        {
            _elapsedForLowLivesBlink += dt;
            if(_elapsedForLowLivesBlink > kFloat0Point5){
                _labelLivesStatic.color = ccWHITE;
                _labelLivesRemaining.color = _labelLivesStatic.color;
                _elapsedForLowLivesBlink = kFloat0;
            }
            else if(_elapsedForLowLivesBlink > kFloat0Point25){
                _labelLivesStatic.color = ccRED;
                _labelLivesRemaining.color = _labelLivesStatic.color;
            }
        }
    }
}

-(void)setupLevelGoalsLayer
{
    _goalsLayerOnRightSide = false; // 1 = right, 0 = left
    
    GameLevel *level = [GameManager currentGameLevel];
    
    // Base measurement on sprite dimension so that it will automatically scale on different devices
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kSpriteFrameNameFruitGoalUnderlay];
    float spriteWidth = frame.rect.size.width * _spriteScaleForLevelGoalsLayer;
    float spriteHeight = frame.rect.size.height * _spriteScaleForLevelGoalsLayer;
    float spriteHalfWidth = (spriteWidth*kTwoInverted);
    float gap = 0; //(spriteWidth*kTenInverted);
    frame = nil;
    
    int numOfGoals = [level.levelGoals count];
    
    _levelGoalsLayerTotWidth = ((spriteWidth+gap) * numOfGoals) - gap - gap;
    _levelGoalsLayerTotHeight = spriteHeight;
    
    // Layer
    CGSize scoreLayerSize = CGSizeMake(_levelGoalsLayerTotWidth, _levelGoalsLayerTotHeight);
    _levelGoalsLayer = [[CCLayerColor alloc] initWithColor:ccc4(kInt255, kInt255, kInt255, 0)
                                                     width:scoreLayerSize.width 
                                                    height:scoreLayerSize.height];
    _levelGoalsLayer.isTouchEnabled = false;
    //CGPoint pos = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(_screenUnitsSize.width, _screenUnitsSize.height)];
    CGSize screenSize = [DevicePositionHelper screenRect].size;
    
    //if(_goalsLayerOnRightSide)
    //{
    //    pos = CGPointMake(screenSize.width, screenSize.height);
    //    _levelGoalsLayer.position = ccp(pos.x-scoreLayerSize.width, pos.y-scoreLayerSize.height);
    // }
    //else
    // {
    //    pos = CGPointMake(kFloat0, screenSize.height);
    //    _levelGoalsLayer.position = ccp(pos.x, pos.y-scoreLayerSize.height);
    //}
    
    CGPoint pos = CGPointMake(screenSize.width*_goalsLayerOnRightSide, screenSize.height);
    _levelGoalsLayer.position = ccp(pos.x-(scoreLayerSize.width*_goalsLayerOnRightSide), pos.y-scoreLayerSize.height);
    
    [self addChild:_levelGoalsLayer z:kInt0 tag:UILayerTagLevelGoalsLayer];
    
    // Goals    
    float labelTargetY = _levelGoalsLayerTotHeight * 0.95f;
    _spriteGoalY = spriteHeight*kThreeInverted; //_levelGoalsLayerTotHeight - (gap*3.6f);
    float labelScoreY = _levelGoalsLayerTotHeight * 0.05f;
    _labelGoalNumberColor = ccWHITE;
    int underOpacity = 64;
    if([GameManager sharedInstance].currentGameGroup.number == 1)
    {
        _labelGoalNumberColor = kColorBlueForGoalNumbers;
        underOpacity = 128;
    }
    
    for(LevelGoal *goal in level.levelGoals)
    {
        float xpos = (spriteHalfWidth + ((spriteWidth+gap) * (goal.tag-kInt1)) + gap);
        
        //CCLOG(@"UserInterfaceLayer: Goal %@ %d", goal.fruitName, goal.target);
        // Label Target
        NSString *strTarget = [[NSString alloc] initWithFormat:kStringFormatInt, goal.target];
        CCLabelBMFont *labelTarget = [[CCLabelBMFont alloc] initWithString:strTarget fntFile:kBmpFontDigits10];
        [strTarget release];
        strTarget = nil;
        labelTarget.anchorPoint = cgcenterone;
        labelTarget.position = ccp(xpos, labelTargetY);
        labelTarget.color = _labelGoalNumberColor;
        // add to layer
        [_levelGoalsLayer addChild:labelTarget z:kInt2 tag:(kInt100 + goal.tag)];
        [labelTarget release];
        labelTarget = nil;
        
        // underlay sprite
        CCSprite *underlay = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameFruitGoalUnderlay];
        underlay.opacity = underOpacity;
        underlay.color = ccc3(kInt255, kInt255, 204);
        underlay.scale = _spriteScaleForLevelGoalsLayer;
        underlay.anchorPoint = cgcenterzero;
        underlay.position = ccp(xpos, 0);
        [_levelGoalsLayer addChild:underlay z:kInt1 tag:(kInt2000 + goal.tag)];
        [underlay release];
        underlay = nil;
        
        // Sprite
        CCSprite *sprite = [[CCSprite alloc] initWithSpriteFrameName:goal.fruitName];
        sprite.scale = _spriteScaleForLevelGoalsLayer;
        sprite.anchorPoint = cgcenterzero;
        sprite.position = ccp(xpos, _spriteGoalY);
        // add to layer
        [_levelGoalsLayer addChild:sprite z:kInt2 tag:(kInt1000 + goal.tag)];
        [sprite release];
        sprite = nil;
        
        _levelGoalsLayerTotWidth += spriteWidth;
        
        // Label Score
        CCLabelBMFont *labelScore = [[CCLabelBMFont alloc] initWithString:kString0 fntFile:kBmpFontDigits10];
        labelScore.anchorPoint = cgcenterzero;
        labelScore.position = ccp(xpos, labelScoreY);
        labelScore.color = _labelGoalNumberColor;
        // add to layer
        [_levelGoalsLayer addChild:labelScore z:kInt2 tag:goal.tag];
        [labelScore release];
        labelScore = nil;
    }
}

-(void)receiveFruitMessage:(FruitMessageEnum)fruitMessage
                 fruitName:(NSString*)fruitName
                      goal:(LevelGoal*)goal
{
    if([GameManager sharedInstance].running)
    {
        if([GameManager currentGameLevel].currentBonus != _prevLabelBonusValue)
        {
            _prevLabelBonusValue = [GameManager currentGameLevel].currentBonus;
            NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, _prevLabelBonusValue];
            [_labelBonusRemaining setString:str];
            [str release];
            str = nil;
        }
        
        // display a golden apple next to the goal layer
        if([fruitName isEqualToString:kSpriteFrameNameAppleGolden])
        {
            id spriteGoalGoldenApple = [_levelGoalsLayer getChildByTag:kUILayerTagSpriteGoalGoldenApple];
            if(!spriteGoalGoldenApple 
               && fruitMessage == FruitMessageIncreaseSaved)
            {
                CCSprite *spriteTemp = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameAppleGolden];
                spriteTemp.anchorPoint = cgzero;
                spriteTemp.scale = (_spriteScaleForLevelGoalsLayer * 1.5f);
                spriteTemp.position = ccp(_levelGoalsLayer.contentSize.width*1.1f, _spriteGoalY / 1.35f);
                [_levelGoalsLayer addChild:spriteTemp z:100 tag:kUILayerTagSpriteGoalGoldenApple];
                [spriteTemp release];
                spriteTemp = nil;
            }
            else if(spriteGoalGoldenApple
                    && fruitMessage == FruitMessageDecreaseSaved)
            {
                [self removeChildByTag:kUILayerTagSpriteGoalGoldenApple cleanup:YES];
                spriteGoalGoldenApple = nil;
            }
        }
        
        if(goal && 
            (fruitMessage == FruitMessageIncreaseSaved 
            || fruitMessage == FruitMessageDecreaseSaved))
        {
            CCLabelBMFont *labelTarget = (CCLabelBMFont *)[_levelGoalsLayer getChildByTag:(kInt100 + goal.tag)];
            
            NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, goal.currentCount];
            CCLabelBMFont *labelScore = (CCLabelBMFont *)[_levelGoalsLayer getChildByTag:goal.tag];
            [labelScore setString:str];
            [str release];
            str = nil;
            
            CCSprite *underlay = (CCSprite *)[_levelGoalsLayer getChildByTag:(kInt2000 + goal.tag)];
            if(goal.currentCount < goal.target)
            {
                // white
                labelTarget.color = _labelGoalNumberColor;
                labelScore.color = _labelGoalNumberColor;
                underlay.color = ccWHITE;
            }
            else if(goal.currentCount == goal.target)
            {
                // green
                labelTarget.color = ccWHITE;
                labelScore.color = ccWHITE;
                underlay.opacity = 192;
                underlay.color = ccc3(kInt0, 192, kInt0);
            }
            else if(goal.currentCount == (goal.target + kInt1))
            {
                // red
                labelTarget.color = ccWHITE;
                labelScore.color = ccWHITE;
                underlay.opacity = 192;
                underlay.color = ccc3(192, kInt0, kInt0);
            }
            underlay = nil;
            labelScore = nil;
        }
    }
}

-(void)buttonBackTapped:(id)sender
{
    CCLOG(@"UserInterfaceLayer: buttonBackTapped (need to reload config and state)");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[GameManager sharedInstance] setDelegate:nil];
    [self removeAllChildrenWithCleanup:YES];
        
    // back to Menu Levels
    [[GameManager sharedInstance].gameLayer stopEverything];
    [GameManager loadMenuLevels];
}

-(void)buttonReplayTapped:(id)sender
{
    CCLOG(@"UserInterfaceLayer: buttonReplayTapped (updateCurrentLevelAsReplay)");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[GameManager sharedInstance] setDelegate:nil];
    [self removeAllChildrenWithCleanup:YES];
    
    [[GameManager sharedInstance].gameLayer stopEverything];
    [GameManager reloadCurrentLevelLayerForReplay];
}

-(void)buttonDebugDrawTapped:(id)sender
{
    CCLOG(@"buttonDebugDrawTapped");
    bool enabled = [AppDelegate sharedDelegate].debugDrawEnabled;
    [AppDelegate sharedDelegate].debugDrawEnabled = !enabled;
    
    /* 
    // cheat to test immediate passed level
    for(LevelGoal *goal in [GameManager currentGameLevel].levelGoals)
    {
        while(goal.currentCount < goal.target)
        {
            goal.currentCount++;
        }
    }
    [GameManager checkForEndLevel];*/
}

-(void)buttonTruckBackTapped:(id)sender
{
    /*CCLOG(@"UserInterfaceLayer: buttonTruckBackTapped _truckSpeedIncrement %f", _truckSpeedIncrement);
    [_gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                  message:@"reduceMotorSpeed"
                               floatValue:_truckSpeedIncrement
                              stringValue:nil];*/
}

-(void)buttonTruckForwardTapped:(id)sender
{
    /*CCLOG(@"UserInterfaceLayer: buttonTruckForwardTapped _truckSpeedIncrement %f", _truckSpeedIncrement);
    [_gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                  message:@"increaseMotorSpeed"
                               floatValue:_truckSpeedIncrement
                              stringValue:nil];*/
}

/*-(void)sendMessageToLabelWithTag:(int)tag 
                         message:(NSString *)m
{
    if([GameManager sharedInstance].running)
    {
        CCNode *node = [self getChildByTag:tag];
        if(node)
        {
            CCLabelTTF *label = (CCLabelTTF *)node;
            [label setString:m];
            CCLOG(@"m retainCount %d", m.retainCount);
        }
    }
}*/

// GameMagangerDelegate handlers
-(void)didIncreaseTimeElapsedFromStart:(float)te
{
    _timeElapsed = te;
    if([GameManager sharedInstance].running && te > _prevLabelTimeElapsedValue)
    {        
        NSString *str = [[NSString alloc] initWithFormat:kStringFormatTimeLabel, te];
		[_labelTimeElapsed setString:str];
        [str release];
        str = nil;
        
        _prevLabelTimeElapsedValue = te;
    }
}
-(void)didIncreaseSavedFruits:(LevelGoal*)goal
                    fruitName:(NSString*)fruitName
               totFruitsSaved:(int)totFruitsSaved
{
    if([GameManager sharedInstance].running)
    {
        [self receiveFruitMessage:FruitMessageIncreaseSaved
                        fruitName:fruitName
                             goal:goal];
    }
}
-(void)didDecreaseSavedFruits:(LevelGoal*)goal
                    fruitName:(NSString*)fruitName
               totFruitsSaved:(int)totFruitsSaved
{
    if([GameManager sharedInstance].running)
    {        
        [self receiveFruitMessage:FruitMessageDecreaseSaved
                        fruitName:fruitName
                             goal:goal];
    }
}
-(void)didIncreaseDestroyedFruits:(LevelGoal*)goal
                        fruitName:(NSString*)fruitName
               totFruitsDestroyed:(int)totFruitsDestroyed
{
    if([GameManager sharedInstance].running)
    {
        _livesRemain = (10-totFruitsDestroyed);
        NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, _livesRemain];
		[_labelLivesRemaining setString:str];
        [str release];
        str = nil;
        
        [self receiveFruitMessage:FruitMessageIncreaseDestroyed
                        fruitName:fruitName
                             goal:goal];
    }
}

@end
