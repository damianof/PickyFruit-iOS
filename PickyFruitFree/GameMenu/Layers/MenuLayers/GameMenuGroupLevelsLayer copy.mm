//
//  GameMenuPlayLayer.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuGroupLevelsLayer.h"
#import "GameConfigAndState.h"
#import "GameGroup.h"
#import "SceneHelper.h"
#import "GameManager.h"
#import "DevicePositionHelper.h"
#import "MenuGrid.h"
#import "CCScrollLayer.h"


typedef enum
{
    GroupLevelsLayerTagINVALID = 0,
    GroupLevelsLayerTagScroller,
    GroupLevelsLayerTagBackButton,
    GroupLevelsLayerTagMAX
} GroupLevelsLayerTags;


@implementation GameMenuGroupLevelsLayer

-(id)init
{
    if((self = [super init]))
    {
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileGameMenuGroupButtons]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileGameMenuGroupButtons];
        
        GameManager *gameManager = [GameManager sharedInstance];
        
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        int numberOfGroups = [gameManager.gameConfigAndState.groups count];
        CCArray* allItems = [[CCArray alloc] initWithCapacity:numberOfGroups];
        float fontSize = kFloat1;            
        
        for (GameGroup *gameGroup in gameManager.gameConfigAndState.groups)
        {
            // use local pool to avoid string With Format leaks in loop
            NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
            
            CCNode *pageLayer = [[[CCNode alloc] init] autorelease];
            
            CCSprite* normalSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.groupButtonImage];
            CCSprite* selectedSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.groupButtonImagePressed];
            
            CCMenuItemSprite* menuItem =[CCMenuItemSprite itemFromNormalSprite:normalSprite 
                                                                selectedSprite:selectedSprite                   
                                                                        target:self 
                                                                      selector:@selector(buttonLevelGroupTapped:)];
            [normalSprite release];
            normalSprite = nil;
            [selectedSprite release];
            selectedSprite = nil;
            
            // if not enabled
            if(gameGroup.enabled == false)
            {
                CCSprite* disabledSprite = [[CCSprite alloc] initWithSpriteFrameName:gameGroup.groupButtonImageDisabled];
                menuItem.disabledImage = disabledSprite;
                [menuItem setIsEnabled:false];
                [disabledSprite release];
                disabledSprite = nil;
            }
            
            menuItem.tag = gameGroup.number;
            
            // show group number
            NSString* strGroupText = [[NSString alloc] initWithFormat:kStringFormatGroupLabel, gameGroup.number];
            CCLabelBMFont *lbl = [[CCLabelBMFont alloc] initWithString:strGroupText fntFile:kBmpFont32All];
            [strGroupText release];
            strGroupText = nil;
            lbl.scale = fontSize * CC_CONTENT_SCALE_FACTOR();
            lbl.anchorPoint = cgzero;
            lbl.color = ccBLACK;
            //lbl.position = ccp(xpos, scoreLayerSize.height);
            
            [menuItem addChild:lbl];
            [lbl release];
            lbl = nil;
            
            CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
            menu.position = screenCenter;
            [pageLayer addChild:menu z:0 tag:gameGroup.number];
            
            [allItems addObject:pageLayer];
            
            // drain local pool 
            [loopPool release];
        }

        // now create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages)
        _scroller = [[CCScrollLayer alloc] initWithLayers:allItems widthOffset: kInt0];
        [allItems release];
        allItems = nil;
        
        // finally add the scroller to your scene
        [self addChild:_scroller z:0 tag:GroupLevelsLayerTagScroller];
        
        int groupSelected = [GameManager groupNumberSelected];
        if (groupSelected > 0) 
        {
            [_scroller moveToPage:groupSelected];
        }
         
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
        
        [self addChild:backMenu z:0 tag:GroupLevelsLayerTagBackButton];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuGroupLevelsLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [_scroller release];
    _scroller = nil;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileGameMenuGroupButtons];
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
    CCLOG(@"MenuGroupLevelsLayer: onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [super onExit];
}

-(void)buttonBackTapped:(id)sender
{
    //CCLOG(@"MenuGroupLevelsLayer: buttonBackTapped");

    // goes back to Play scene
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuPlay];
}

-(void)buttonLevelGroupTapped:(id)sender
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    int group = ((CCNode*)sender).tag;
    //CCLOG(@"MenuGroupLevelsLayer: Button Group Tapped: %d", group);
    
    // set the group selected
    [GameManager setGroupNumberSelected:group];
    
    // goes to the selected MenuLevels
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevels];
}


@end
