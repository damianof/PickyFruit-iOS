//
//  GameMenuPlayLayer.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuLevelsLayer.h"
#import "GameGroup.h"
#import "GameLevel.h"
#import "GameConfigAndState.h"
#import "GameManager.h"
#import "DevicePositionHelper.h"
#import "SceneHelper.h"
#import "MenuGrid.h"
#import "MenuGridItem.h"


typedef enum
{
    LevelsLayersTagINVALID = 0,
    LevelLayersTagMenuLevels,
    LevelLayersTagBackButton,
    LevelsLayersTagMAX
} LevelsLayersTags;


@implementation GameMenuLevelsLayer


-(id)init
{
    if((self = [super initWithColor:kBackgroundGradientStart 
                           fadingTo:kBackgroundGradientEnd 
                        alongVector:[DevicePositionHelper gradientVector]]))
    {
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileGameMenuLevelButtons]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileGameMenuLevelButtons];
        
        GameManager *gameManager = [GameManager sharedInstance];
                
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        int gn = [GameManager groupNumberSelected];
    
        GameGroup *gameGroup = [gameManager.gameConfigAndState getGroupByNumber:gn];
        NSArray *gameLevels = gameManager.gameConfigAndState.levels;
        int levelsPerGroup = gameManager.gameConfigAndState.levelsPerGroup;
        CCArray* allItems = [[CCArray alloc] initWithCapacity:levelsPerGroup];
        
        for (GameLevel *gameLevel in gameLevels)
        {
            if(gameGroup.enabled 
               && gameLevel.groupNumber == gn)
            {
                MenuGridItem *item = [[MenuGridItem alloc] initWithFntFile:kBmpFont32AllSkyBlue 
                                                                  fontSize:kFloat0Point75 
                                                                   enabled:gameLevel.enabled 
                                                                    number:gameLevel.number 
                                                                     stars:gameLevel.stateStars
                                                                    target:self 
                                                                  selector:@selector(buttonLevelTapped:)];
                //(buttonLevelTapped:)];
                item.tag = gameLevel.number;                
                
                
                // add to array
                [allItems addObject:item];
                [item release];
                item = nil;
            }
        }
        
        int itemLimit = gameManager.gameConfigAndState.levelsPerRow;
        CGPoint pad = CGPointMake(8, 16);
        MenuGrid* menuGrid = [MenuGrid menuWithArray:allItems 
                                           fillStyle:kMenuGridFillColumnsFirst 
                                           itemLimit:itemLimit 
                                             padding:pad];
        [allItems release];
        allItems = nil;
        //menuGrid.anchorPoint = CGPointMake(0.5,0.5);
        menuGrid.position = screenCenter; 
        //CGPointMake(20, (menuGrid.boundingBox.size.width/2));
        [self addChild:menuGrid z:0 tag:LevelLayersTagMenuLevels];
        
        // add back item
        CCSprite* normalSprite = [[CCSprite alloc] initWithSpriteFrameName:kStringBack];
        CCSprite* selectedSprite = [[CCSprite alloc] initWithSpriteFrameName:kStringBack];
        CCMenuItemSprite* backMenuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                selectedSprite:selectedSprite                   
                                                                        target:self 
                                                                      selector:@selector(buttonBackTapped:)];
        CCMenu *backMenu = [CCMenu menuWithItems:backMenuItem, nil];
        backMenu.position = ccp(normalSprite.boundingBox.size.width, normalSprite.boundingBox.size.height);
        [normalSprite release];
        normalSprite = nil;
        [selectedSprite release];
        selectedSprite = nil;
        
        [self addChild:backMenu z:0 tag:LevelLayersTagBackButton];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuLevelsLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileGameMenuLevelButtons];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [super dealloc];
}

-(void)onEnter
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnter];
}

-(void)onEnterTransitionDidFinish
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnterTransitionDidFinish];
}

-(void)onExit
{
    CCLOG(@"GameMenuLevelsLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [super onExit];
}

-(void)buttonBackTapped:(id)sender
{
    //CCLOG(@"MenuLevelsLayer: buttonBackTapped ");
    // back to Menu Group Levels
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuGroupLevels
                            useTransition:true];
}

-(void)buttonLevelTapped:(id)sender
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    int levelNumber = ((CCMenuItemSprite *)sender).tag;
    //CCLOG(@"MenuLevelsLayer: Button Level Tapped: %d", levelNumber);
    
    [GameManager loadCurrentLevelLayer:levelNumber];
}


@end
