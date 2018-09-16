//
//  ButtonGroupLevels.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ButtonGroupLevels.h"
#import "GameManager.h"
#import "SceneHelper.h"


@implementation ButtonGroupLevels


+(id)buttonGroupWithName:(NSString *)name
               andNumber:(int)number
{
    return [[[self alloc] initWithName:name andNumber:number] autorelease]; 
}

-(id)initWithName:(NSString *)name
        andNumber:(int)number
{
    if((self = [super init]))
    {
        _groupNumber = number;
                
        CCMenuItem *button = [CCMenuItemImage 
                              itemFromNormalImage:@"ButtonGroupLevels.png" 
                              selectedImage:@"ButtonGroupLevels-Pressed.png" 
                              target:self 
                              selector:@selector(buttonTapped:)];
        button.anchorPoint = CGPointZero;
        button.position = CGPointZero;
        
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        menu.anchorPoint = CGPointZero;
        menu.position = CGPointZero;
        [self addChild:menu z:0 tag:1];
        
        //ButtonGroupLevels
        CCLabelTTF *label = [CCLabelTTF labelWithString:name
                                               fontName:@"Marker Felt"
                                               fontSize:16];
        //label.position = CGPointMake(menu.position.x, menu.position.y - 32);
        [self addChild:label z:0 tag:2];
    }
    
    return self;
}

-(void)dealloc
{
    CCLOG(@"ButtonGroupLevels: dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];

    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)buttonTapped:(id)sender
{
    [GameManager setGroupNumberSelected:_groupNumber];
    
    // Go to Menu Levels
    [SceneHelper menuSceneWithTargetLayer:TargetLayerMenuLevels
                            useTransition:true];
}


@end
