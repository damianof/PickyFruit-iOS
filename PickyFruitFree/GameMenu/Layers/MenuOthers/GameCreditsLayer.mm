//
//  GameCreditsLayer.mm
//  PickyFruit
//
//  Created by Damiano Fusco on 2/26/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
#import "GameCreditsLayer.h"
#import "DevicePositionHelper.h"
#import "GameMenuScene.h"
#import "SceneHelper.h"


typedef enum{
    GameMenuCreditsTagINVALID = 0,
    GameMenuCreditsTagSpriteBackground,
    GameMenuCreditsTagSpriteWebsite,
    GameMenuCreditsTagSpriteSupport,
    GameMenuCreditsTagSpriteMainMenu,
    GameMenuCreditsTagMAX
} GameMenuCreditsTags;

@implementation GameCreditsLayer

-(id)init
{
    if((self = [super init]))
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
        
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileCreditsMenu]]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileCreditsMenu];
        
        
        //CCLOG(@"GameMenuPlayLayer init");
        //CGSize screenSize = [DevicePositionHelper screenRect].size;
        UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        UnitsPoint screenUnitsCenter = [DevicePositionHelper screenUnitsCenter];
        //CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        // add background
        CCSprite *spriteBackground = [[CCSprite alloc] initWithSpriteFrameName:@"CreditsBackground"];
        spriteBackground.anchorPoint = cgzero;
        spriteBackground.position = cgzero;
        [self addChild:spriteBackground z:0 tag:GameMenuCreditsTagSpriteBackground];
        [spriteBackground release];
        spriteBackground = nil;
        
        // Main Menu button
        UnitsPoint unitsPosition = UnitsPointMake(screenUnitsSize.width - 2, 1);
        CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteMainMenu = [[CCSprite alloc] initWithSpriteFrameName:@"MainMenu"];
        spriteMainMenu.anchorPoint = cgonezero;
        spriteMainMenu.position = position;
        [self addChild:spriteMainMenu z:1 tag:GameMenuCreditsTagSpriteMainMenu];
        [spriteMainMenu release];
        spriteMainMenu = nil;
        
        // website
        unitsPosition = UnitsPointMake(screenUnitsCenter.x, screenUnitsSize.height-11);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteWebsite = [[CCSprite alloc] initWithSpriteFrameName:@"Website"];
        spriteWebsite.anchorPoint = cgcenterone;
        spriteWebsite.position = position;
        [self addChild:spriteWebsite z:1 tag:GameMenuCreditsTagSpriteWebsite];
        [spriteWebsite release];
        spriteWebsite = nil;
        
        // support
        unitsPosition = UnitsPointMake(screenUnitsCenter.x, screenUnitsSize.height-14);
        position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
        CCSprite *spriteSupport = [[CCSprite alloc] initWithSpriteFrameName:@"Support"];
        spriteSupport.anchorPoint = cgcenterone;
        spriteSupport.position = position;
        [self addChild:spriteSupport z:1 tag:GameMenuCreditsTagSpriteSupport];
        [spriteSupport release];
        spriteSupport = nil;
        
        // label Debug
        /*float fontSize = [DevicePositionHelper cgFromUnits:1.75f];
        CCLabelTTF *labelDebug = [CCLabelTTF labelWithString:@"Credits"
                                         fontName:kMarkerFelt
                                         fontSize:fontSize];
        labelDebug.position =  CGPointMake(screenCenter.x, screenCenter.y + 10);
        [self addChild:labelDebug];*/
        
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"GameMenuPlayLayer dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFilePlayMenu];
    
    [super dealloc];
}

-(void)onExit
{
    CCLOG(@"GameCreditsLayer onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super onExit];
}

-(void)loadMainMenu
{
    // load the GameCreditsLayer
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    _spriteTouched.color = ccWHITE;
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuPlay
                            useTransition:true];
}

-(void)switchTouch
{
    int tmp = _tagTouched;
    switch (tmp) 
    {
        case GameMenuCreditsTagSpriteMainMenu:
        {
            [self loadMainMenu];
            break;
        }
        case GameMenuCreditsTagSpriteWebsite:
        case GameMenuCreditsTagSpriteSupport:
        {
            NSString* launchUrl = @"http://www.pickyfruit.com";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            break;
        }
        //case GameMenuCreditsTagSpriteSupport:
        //{
            /*NSString* launchUrl = @"mailto:support@pickyfruit.com";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            launchUrl = nil;
            _spriteTouched.color = ccWHITE;
            */
            /*NSString *subject = [[NSString alloc] initWithString:@"Picky Fruit support"]; 
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self; //keep self as the delegate
            // Set the subject of email
            [picker setSubject:subject];
            [subject release];
            subject = nil;
            
            // Add email addresses
            // Notice three sections: "to" "cc" and "bcc"	
            [picker setToRecipients:[NSArray arrayWithObjects:@"supportpickyfruit.com", nil]];
            
            // Show email view	
            // push into self
            [self presentModalViewController:picker animated:YES];
            
            // Release picker
            [picker release];*/
            //break;
        //}
        default:
        {
            break;
        }
    };
}

// touch handling
-(void)checkTouch:(UITouch*)touch
{
    for (id item in self.children)
	{
        if([item isKindOfClass:[CCSprite class]])
        {
            CCSprite *sprite = (CCSprite*)item;
            
            if (sprite.tag != GameMenuCreditsTagSpriteBackground
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
