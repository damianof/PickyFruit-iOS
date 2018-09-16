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
#import "MenuScroll.h"
#import "MenuScrollItem.h"


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
    if((self = [super initWithColor:kBackgroundGradientStart 
                           fadingTo:kBackgroundGradientEnd 
                        alongVector:[DevicePositionHelper gradientVector]]))
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:0 
                                                  swallowsTouches:YES];
        
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileGameMenuGroupButtons]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileGameMenuGroupButtons];
        
        // create the scroller
        _scroller = [[MenuScroll alloc] initWithWidthOffset:kInt0
                                                     target:self
                                                   selector:@selector(buttonLevelGroupTapped:)];
        
        // finally add the scroller to your scene
        [self addChild:_scroller z:0 tag:GroupLevelsLayerTagScroller];
        
        int groupSelected = [GameManager groupNumberSelected];
        if (groupSelected > 0) 
        {
            [_scroller moveToPage:groupSelected];
        }
                 
        // add Back button
        UnitsPoint unitsPosition = UnitsPointMake(2, 2);
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteBack = [[CCSprite alloc] initWithSpriteFrameName:kStringBack];
        spriteBack.anchorPoint = cgzero;
        spriteBack.position = position;
        [self addChild:spriteBack z:0 tag:GroupLevelsLayerTagBackButton];
        [spriteBack release];
        spriteBack = nil;
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuGroupLevelsLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
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
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

-(void)buttonBackTapped
{
    //CCLOG(@"MenuGroupLevelsLayer: buttonBackTapped");

    // goes back to Play scene
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuPlay
                            useTransition:true];
}

-(void)buttonLevelGroupTapped:(id)sender
{
    int groupNumber = ((MenuScrollItem*)sender).groupNumber;
    CCLOG(@"MenuGroupLevelsLayer: Button Group Tapped: %d", groupNumber);
    
    // set the group selected
    [GameManager setGroupNumberSelected:groupNumber];
    
    // FREE EDITION
    if (groupNumber < kInt3) 
    {
        [self stopAllActions];
        [self unscheduleAllSelectors];
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        
        // goes to the selected MenuLevels
        [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevels
                                useTransition:true];
    }
    else
    {
        [self buttonBackTapped];
        
        //CCLOG(@"MenuGroupLevelsLayer: Button Group Tapped: %d: NEED TO OPEN iTUNES LINK TO FULL VERSION", groupNumber);
        NSString* launchUrl = @"http://itunes.apple.com/us/app/picky-fruit/id508543850";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
        launchUrl = nil;
        
        //[_scroller moveToPage:1];
    }
}

// touch handling
-(void)checkTouch:(UITouch*)touch
{
    for (id item in self.children)
	{
        if([item isKindOfClass:[CCSprite class]])
        {
            CCSprite *sprite = (CCSprite*)item;
            
            if (sprite.tag == GroupLevelsLayerTagBackButton
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
        case GroupLevelsLayerTagBackButton:
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
