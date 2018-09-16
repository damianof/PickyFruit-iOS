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
    if((self = [super init]))
    {
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileGameMenuButtons]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileGameMenuButtons];
        
        GameManager *gameManager = [GameManager sharedInstance];
                
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        int gn = [GameManager groupNumberSelected];
    
        GameGroup *gameGroup = [gameManager.gameConfigAndState getGroupByNumber:gn];
        NSArray *gameLevels = gameManager.gameConfigAndState.levels;
        int levelsPerGroup = gameManager.gameConfigAndState.levelsPerGroup;
        CCArray* allItems = [[CCArray alloc] initWithCapacity:levelsPerGroup];
        
        CGPoint starsIconAnchorPoint = ccp(0, -1.0f);
        float fontSize = [DevicePositionHelper cgFromUnits:1.5f];
        
        for (GameLevel *gameLevel in gameLevels)
        {
            if(gameGroup.enabled 
               && gameLevel.groupNumber == gn)
            {
                // use local pool to avoid string With Format leaks in loop
                NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
                
                // create a menu item for each character
                CCSprite* normalSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.levelButtonImage];
                CCSprite* selectedSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.levelButtonImagePressed];
                CCMenuItemSprite* menuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite selectedSprite:selectedSprite                   
                                                                            target:self 
                                                                          selector:@selector(buttonLevelTapped:)];
                [normalSprite release];
                normalSprite = nil;
                [selectedSprite release];
                selectedSprite = nil;
                
                menuItem.tag = gameLevel.number;
                
                // if not enabled:
                if(gameLevel.enabled == false)
                {
                    CCSprite* disabledSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.levelButtonImageDisabled];
                    menuItem.disabledImage = disabledSprite;
                    [menuItem setIsEnabled:false];
                    [disabledSprite release];
                    disabledSprite = nil;
                }
                else
                {
                    [menuItem setIsEnabled:true];
                }
                
                // show level number
                NSString* levelText = [[NSString alloc] initWithFormat:kStringFormatInt, gameLevel.number];
                CCLabelTTF *lbl = [CCLabelTTF labelWithString:levelText
                                                     fontName:kMarkerFelt
                                                     fontSize:fontSize];
                [levelText release];
                levelText = nil;
                lbl.color = ccBLUE;
                lbl.anchorPoint = CGPointZero;
                [menuItem addChild:lbl z:0 tag:gameLevel.number];

                // show stars count
                for(int i = 1; i <= gameLevel.stateStars; i++)
                {
                    CCSprite *star = [[CCSprite alloc] initWithSpriteFrameName:kButtonImageStarOverlay];
                    int starWidth = [star boundingBox].size.width;
                    star.anchorPoint = starsIconAnchorPoint;
                    star.position = CGPointMake(((i-1)*starWidth/2), 0);
                    [menuItem addChild:star z:i tag:gameLevel.number];
                    [star release];
                    star = nil;
                }
                
                // add to array
                [allItems addObject:menuItem];
                
                // drain local pool 
                [loopPool drain];
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
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileGameMenuButtons];
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
    [self removeAllChildrenWithCleanup:YES];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuGroupLevels];
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
