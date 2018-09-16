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
#import "DevicePositionHelper.h"
#import "SceneHelper.h"

/*struct FruitFrameCount
{
    NSString    *frame;
    int count;
};*/

@implementation UserInterfaceLayer


//@synthesize 
//    gameLayer = _gameLayer;

+(id)scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [UserInterfaceLayer node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    //if ((self = [super initWithColor:ccc4(255,255,0,125)]))
	if ((self = [super init]))
	{
        _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        _drawUnitsGrid = true;
        
        CCLOG(@"UserInterfaceLayer set Delegate");
        [[GameManager sharedGameManager] setDelegate:self];
        
        _spriteScaleForLevelGoalsLayer = 0.5f;
        [self setupLevelGoalsLayer];
        
        _truckSpeedIncrement = 0.75f;
        
        //_fruitScoreLabelsDict = [[NSMutableDictionary dictionaryWithCapacity:9] retain];
        //_fruitCounts = [[NSMutableDictionary dictionaryWithCapacity:9] retain];
        
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        UnitsPoint screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        
        //[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"UIBackground.plist"];
        //[[GB2ShapeCache sharedShapeCache] addFixturesToBody:_groundBody forShapeName:@"UIBackground"];
        //[spriteMountains setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"UIBackground"]];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"UILayerButtons.plist"];
        
        CCSprite* uibackground = [CCSprite spriteWithFile:@"UIBackground.png"];
        uibackground.anchorPoint = ccp(0,0);
        [self addChild:uibackground z:0 tag:0];
        
        // add back item
        CCSprite* normalSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerPause"];
        CCSprite* selectedSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerPause"];
        CCMenuItemSprite* backMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                selectedSprite:selectedSprite                   
                                                                        target:self 
                                                                      selector:@selector(buttonBackTapped:)];
        //backMenuItem.anchorPoint = ccp(0,0);
        
        UnitsPoint backMenuItemPosition = UnitsPointMake(backMenuItem.position.x, backMenuItem.position.y);
        
        //UnitsSize backMenuSize = [DevicePositionHelper unitsSizeFromSize:[backMenuItem boundingBox].size];
        int screenFirstQuarterX = screenUnitsCenter.x / 2;
        int screenThirdQuarterX = screenUnitsCenter.x + screenFirstQuarterX;
        UnitsPoint unitsPosition;
        
        // Group Label (position on the right size, 1 unit from screen edge
        float fontSize = [DevicePositionHelper cgFromUnits:1.5f];
        unitsPosition = UnitsPointMake(screenFirstQuarterX, 2.5f);
        CCLabelTTF *labelTimeElapsed = [CCLabelTTF labelWithString:@"Time 0"
                                                         fontName:@"Marker Felt"
                                                         fontSize:fontSize];
        labelTimeElapsed.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelTimeElapsed z:0 tag:kTagUILayerLabelTime];
        
        // Level Label
        GameLevel *level = [GameManager currentGameLevel];
        int levelSelected = level.number;
        unitsPosition = UnitsPointMake(screenThirdQuarterX, 1.7f);
        CCLabelTTF *labelLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", levelSelected]
                                                    fontName:@"Marker Felt"
                                                    fontSize:fontSize];
        labelLevel.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelLevel z:0 tag:kTagUILayerLabelLevel];
        
        
        // another level label on second line
        unitsPosition = UnitsPointMake(screenThirdQuarterX, 3.1f);
        CCLabelTTF *labelLevel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", levelSelected]
                                                    fontName:@"Marker Felt"
                                                    fontSize:fontSize];
        labelLevel2.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        [self addChild:labelLevel2 z:0 tag:kTagUILayerLabelLevel2];
        
        
        // add truck back button
        normalSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerTruckBack"];
        selectedSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerTruckBack"];
        CCMenuItemSprite* truckBackMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                     selectedSprite:selectedSprite                   
                                                                             target:self 
                                                                           selector:@selector(buttonTruckBackTapped:)];
        //truckBackMenuItem.position = ccp(backMenuItem.position.x + 52, backMenuItem.position.y);
        truckBackMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsCenter.x-5.0f, backMenuItemPosition.y)];
        
        // add truck forwardbutton
        normalSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerTruckFwd"];
        selectedSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerTruckFwd"];
        CCMenuItemSprite* truckForwardMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                     selectedSprite:selectedSprite                   
                                                                             target:self 
                                                                           selector:@selector(buttonTruckForwardTapped:)];
        //truckForwardMenuItem.position = ccp(truckBackMenuItem.position.x + 52, truckBackMenuItem.position.y);
        truckForwardMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(screenUnitsCenter.x+3.0f, backMenuItemPosition.y)];
        
        
        // add Replay button
        normalSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerReplay"];
        selectedSprite = [CCSprite spriteWithSpriteFrameName:@"UILayerReplay"];
        CCMenuItemSprite* replayMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                selectedSprite:selectedSprite                   
                                                                        target:self 
                                                                      selector:@selector(buttonReplayTapped:)];
        replayMenuItem.anchorPoint = ccp(1.5f,0.5f);
        unitsPosition = UnitsPointMake(_screenUnitsSize.width - 1, backMenuItemPosition.y);
        replayMenuItem.position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        
        // add debug button
        normalSprite = [CCSprite spriteWithFile:@"Icon-Small.png"];
        selectedSprite = [CCSprite spriteWithFile:@"Icon-Small.png"];
        CCMenuItemSprite* debugMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                 selectedSprite:selectedSprite                   
                                                                         target:self 
                                                                       selector:@selector(buttonDebugDrawTapped:)];
        //debugMenuItem.anchorPoint = ccp(0,0);
        debugMenuItem.position = ccp(replayMenuItem.position.x - 60, replayMenuItem.position.y);
        
        
        // add items to menu 
        CCMenu *uiMenu = [CCMenu menuWithItems:backMenuItem, debugMenuItem, truckBackMenuItem, truckForwardMenuItem, replayMenuItem, nil];
        
        // add menu
        //uiMenu.anchorPoint = ccp(0,0);
        UnitsPoint uiMenuUnitsPos = UnitsPointMake(2,2.5f);
        uiMenu.position = [DevicePositionHelper pointFromUnitsPoint:uiMenuUnitsPos];
        [self addChild:uiMenu z:0 tag:kTagUIMenu];
        
    
        // this layer should have touch disabled
        self.isTouchEnabled = NO;
    }
    return self;
}

-(void)setGameLayer:(CCLayerWithWorld *)layer
{
    _gameLayer = layer;
}

-(void)dealloc
{    
    //CCLOG(@"UserInterfaceLayer dealloc");
    
    [[GameManager sharedGameManager] setDelegate:NULL];

    //[_fruitScoreLabelsDict release];
    //_fruitScoreLabelsDict = NULL;
    //[_fruitCounts release];
    //_fruitCounts = NULL;
    _levelGoalsLayer = NULL;
    
    [self removeChildByTag:kTagUIMenu cleanup:YES];
    
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

-(void)sendMessageToLabelWithTag:(int)tag 
                         message:(NSString *)m
{
    CCNode *node = [self getChildByTag:tag];
    if(node)
    {
        CCLabelTTF *label = (CCLabelTTF *)node;
        [label setString:m];
    }
}

-(void)setupLevelGoalsLayer
{
    GameLevel *level = [GameManager currentGameLevel];
    
    // Base measurement on sprite dimension so that it will automatically scale on different devices
    CCSprite *tempSprite = [CCSprite spriteWithSpriteFrameName:@"AppleRed-32"];
    tempSprite.scale = _spriteScaleForLevelGoalsLayer;
    float spriteWidth = tempSprite.boundingBox.size.width;
    float spriteHeight = tempSprite.boundingBox.size.height;
    float spriteHalfWidth = (spriteWidth/2);
    float gap = (spriteWidth/5);
    
    int numOfGoals = [level.levelGoals count];
    _levelGoalsLayerTotWidth = ((spriteWidth+gap) * numOfGoals) + gap;
    _levelGoalsLayerTotHeight = spriteHeight + (gap*7);
    
    
    // Layer
    CGSize scoreLayerSize = CGSizeMake(_levelGoalsLayerTotWidth, _levelGoalsLayerTotHeight);
    _levelGoalsLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 0, 64)
                                              width:scoreLayerSize.width 
                                             height:scoreLayerSize.height];
    _levelGoalsLayer.isTouchEnabled = false;
    //CGPoint pos = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(_screenUnitsSize.width, _screenUnitsSize.height)];
    CGSize screenSize = [DevicePositionHelper screenRect].size;
    CGPoint pos = CGPointMake(screenSize.width, screenSize.height);
    _levelGoalsLayer.position = ccp(pos.x-scoreLayerSize.width, pos.y-scoreLayerSize.height);
    [self addChild:_levelGoalsLayer z:0 tag:kTagUILayerLevelGoalsLayer];
    
    // Goals
    //float fontSize = [DevicePositionHelper cgFromUnits:1.5f];
    float fontSize = [DevicePositionHelper cgFromUnits:(2.5f*_spriteScaleForLevelGoalsLayer)]; //(gap/5);
    
    ccColor3B labelTargetColor = ccc3(0, 64, 128);
    CGPoint labelTargetAnchorPoint = ccp(0.5f, 1.0f);
    
    CGPoint spriteAnchorPoint = ccp(0.5f, 1.0f);
    
    ccColor3B labelScoreColor = ccc3(0, 128, 0);
    CGPoint labelScoreAnchorPoint = ccp(0.5f, 1.0f);
    
    for(LevelGoal *goal in level.levelGoals)
    {
        float xpos = (spriteHalfWidth + ((spriteWidth+gap) * (goal.tag-1)) + gap);
        
        CCLOG(@"Goal %@ %d", goal.fruitName, goal.target);
        // Label Target
        CCLabelTTF *labelTarget = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", goal.target]
                                                     fontName:kMarkerFelt
                                                     fontSize:fontSize];
        labelTarget.color = labelTargetColor;
        labelTarget.anchorPoint = labelTargetAnchorPoint;
        labelTarget.position = ccp(xpos, _levelGoalsLayerTotHeight);
        
        [_levelGoalsLayer addChild:labelTarget z:1 tag:(100 + goal.tag)];
        
        // Sprite
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:goal.fruitName];
        sprite.scale = _spriteScaleForLevelGoalsLayer;
        sprite.anchorPoint = spriteAnchorPoint;
        sprite.position = ccp(xpos, _levelGoalsLayerTotHeight - (gap*3.5));
        [_levelGoalsLayer addChild:sprite z:0 tag:(101 + goal.tag)];
        
        _levelGoalsLayerTotWidth += spriteWidth;
        
        // Label Score
        CCLabelTTF *labelScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", 0]
                                                    fontName:kMarkerFelt
                                                    fontSize:fontSize];
        labelScore.color = labelScoreColor;
        labelScore.anchorPoint = labelScoreAnchorPoint;
        labelScore.position = ccp(xpos, _levelGoalsLayerTotHeight - (spriteHeight+(gap*3.5)) );
        
        // add to layer
        [_levelGoalsLayer addChild:labelScore z:1 tag:goal.tag];
    }
}

-(void)receiveFruitMessage:(FruitMessageEnum)fruitMessage 
                 frameName:(NSString *)frameName
{
    int amount = 0;

    if(fruitMessage == FruitMessageIncreaseSaved)
    {
        amount = 1; 
    }
    else if (fruitMessage == FruitMessageDecreaseSaved)
    {
        amount = -1;
    }
    
    GameLevel *level = [GameManager currentGameLevel];
    LevelGoal *goal = NULL;
    for(LevelGoal *item in level.levelGoals)
    {
        if([frameName isEqualToString:item.fruitName])
        {
            goal = item;
            goal.currentCount += amount;
            break;
        }
    }
    
    CCLabelTTF *labelScore = (CCLabelTTF *)[_levelGoalsLayer getChildByTag:goal.tag];
    [labelScore setString:[NSString stringWithFormat:@"%d", goal.currentCount]];

    // resize and position the layer
    //CGSize scoreLayerSize = CGSizeMake(totWidth, totHeight);
    //[_fruitScoreLayer setContentSize:scoreLayerSize];
    //CGPoint pos = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(_screenUnitsSize.width-0.5f, _screenUnitsSize.height-0.5f)];
    //_fruitScoreLayer.position = ccp(pos.x-scoreLayerSize.width,pos.y-scoreLayerSize.height);   
}

-(void)refreshTimeLabel
{
    float te = [GameManager sharedGameManager].timeElapsedFromStart;
    
    [self sendMessageToLabelWithTag:kTagUILayerLabelTime
                            message:[NSString stringWithFormat:@"Time %.1f", te]];
}

-(void)buttonBackTapped:(id)sender
{
    CCLOG(@"UserInterfaceLayer: buttonBackTapped (need to reload config and state)");
    
    // moved the following line into GameManager loadMenuLevels
    //[SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevels];
    
    // back to Menu Levels
    [GameManager loadMenuLevels];
}

-(void)buttonReplayTapped:(id)sender
{
    CCLOG(@"UserInterfaceLayer: buttonReplayTapped (updateCurrentLevelAsReplay)");
    
    // moved the following lines into GameManager reloadCurrentLevelLayerForReplay
    // replaying, so reset Level to previous results
    //[GameManager updateCurrentLevelAsReplay];
    // load MultiLayerScene with current Game Layer
    //TargetLayerEnum targetLayer = [GameManager targetLayerSelected];
    //[SceneHelper multiLayerSceneWithTargetLayer:targetLayer];
    
    [GameManager reloadCurrentLevelLayerForReplay];
}

-(void)buttonDebugDrawTapped:(id)sender
{
    CCLOG(@"buttonDebugDrawTapped");
    bool enabled = [AppDelegate sharedDelegate].debugDrawEnabled;
    [AppDelegate sharedDelegate].debugDrawEnabled = !enabled;
    
    /*for(LevelGoal *goal in [GameManager currentGameLevel].levelGoals)
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
    CCLOG(@"UserInterfaceLayer: buttonTruckBackTapped _truckSpeedIncrement %f", _truckSpeedIncrement);
    [_gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                  message:@"reduceMotorSpeed"
                               floatValue:_truckSpeedIncrement
                              stringValue:nil];
}

-(void)buttonTruckForwardTapped:(id)sender
{
    CCLOG(@"UserInterfaceLayer: buttonTruckForwardTapped _truckSpeedIncrement %f", _truckSpeedIncrement);
    [_gameLayer sendMessageToActorWithTag:kActorTagTractor 
                                  message:@"increaseMotorSpeed"
                               floatValue:_truckSpeedIncrement
                              stringValue:nil];
}

// GameMagangerDelegate handlers
-(void)didIncreaseTimeElapsedFromStart:(float)te
{
    [self sendMessageToLabelWithTag:kTagUILayerLabelTime
                            message:[NSString stringWithFormat:@"Time %.1f", te]];
}
-(void)didIncreaseSavedFruits:(NSString*)fruitFrameName
               totFruitsSaved:(int)totFruitsSaved
{
    [self sendMessageToLabelWithTag:kTagUILayerLabelLevel
                            message:[NSString stringWithFormat:@"Saved %d", totFruitsSaved]];
    [self receiveFruitMessage:FruitMessageIncreaseSaved
                    frameName:fruitFrameName];
}
-(void)didDecreaseSavedFruits:(NSString*)fruitFrameName
               totFruitsSaved:(int)totFruitsSaved
{
    [self sendMessageToLabelWithTag:kTagUILayerLabelLevel
                            message:[NSString stringWithFormat:@"Saved %d", totFruitsSaved]];
    [self receiveFruitMessage:FruitMessageDecreaseSaved
                    frameName:fruitFrameName];
}
-(void)didIncreaseRottenFruits:(int)totFruitsRotten
{
    [self sendMessageToLabelWithTag:kTagUILayerLabelLevel2
                            message:[NSString stringWithFormat:@"Rotten %d", totFruitsRotten]];
}

@end
