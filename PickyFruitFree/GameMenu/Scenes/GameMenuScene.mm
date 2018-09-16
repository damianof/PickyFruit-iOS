//
//  GameMenuScene.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameMenuScene.h"
#import "TargetLayerEnumHelper.h"

typedef enum{
    GameMenuSceneTagINVALID = 0,
    GameMenuSceneTagMenuLayer,
    GameMenuSceneTagMAX
} GameMenuSceneTags;

@implementation GameMenuScene

+(id)sceneWithTargetLayer:(TargetLayerEnum)tl
{
    return [[[self alloc] initWithTargetLayer:tl] autorelease];    
}

-(id)initWithTargetLayer:(TargetLayerEnum)tl
{
    if((self = [super init]))
    {       
        _menuLayer = [TargetLayerEnumHelper menuLayerFromEnumValue:tl];
        
        //CCLOG(@"GameMenuScene init: layer retain count = %d", [menuLayer retainCount]);
        if (_menuLayer != nil) 
        {
            [self addChild:_menuLayer z:1 tag:GameMenuSceneTagMenuLayer];
        }
    }
    
    return self;
}

-(void)dealloc
{
    //CCLOG(@"GameMenuScene dealloc");
    // IMPORTANT: Remove Menu Layer
    CCLOG(@"GameMenuScene dealloc: _menuLayer retain count %d", _menuLayer.retainCount);
    
    [self stopAllActions];
    [self unscheduleAllSelectors];	
    [self removeAllChildrenWithCleanup:YES];
    _menuLayer = nil;
    [super dealloc];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

@end
