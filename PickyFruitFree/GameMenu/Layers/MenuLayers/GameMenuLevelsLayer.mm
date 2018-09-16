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
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:0 
                                                  swallowsTouches:YES];
        
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileGameMenuLevelButtons]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileGameMenuLevelButtons];
        
        GameManager *gameManager = [GameManager sharedInstance];
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        // add menu grid
        MenuGrid* menuGrid = [MenuGrid menuWithFillStyle:kMenuGridFillColumnsFirst 
                                               itemLimit:gameManager.gameConfigAndState.levelsPerRow 
                                                 padding:CGPointMake(8, 16)
                                                  target:self
                                                selector:@selector(buttonLevelTapped:)];

        menuGrid.position = screenCenter; 
        [self addChild:menuGrid z:0 tag:LevelLayersTagMenuLevels];
               
        // add Back button
        UnitsPoint unitsPosition = UnitsPointMake(2, 2);
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteBack = [[CCSprite alloc] initWithSpriteFrameName:kStringBack];
        spriteBack.anchorPoint = cgzero;
        spriteBack.position = position;
        [self addChild:spriteBack z:0 tag:LevelLayersTagBackButton];
        [spriteBack release];
        spriteBack = nil;
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuLevelsLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
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
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

-(void)buttonBackTapped
{
    //CCLOG(@"MenuLevelsLayer: buttonBackTapped ");
    // back to Menu Group Levels
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuGroupLevels
                            useTransition:true];
}

-(void)buttonLevelTapped:(id)sender
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    int levelNumber = ((CCMenuItemSprite *)sender).tag;
    //CCLOG(@"MenuLevelsLayer: Button Level Tapped: %d", levelNumber);
    
    [GameManager loadCurrentLevelLayer:levelNumber];
}

// touch handling
-(void)checkTouch:(UITouch*)touch
{
    for (id item in self.children)
	{
        if([item isKindOfClass:[CCSprite class]])
        {
            CCSprite *sprite = (CCSprite*)item;
            
            if (sprite.tag == LevelLayersTagBackButton
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

-(void)switchTouch
{
    int tmp = _tagTouched;
    switch (tmp) 
    {
        case LevelLayersTagBackButton:
            [self buttonBackTapped];
            break;
            
        default:
            break;
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
