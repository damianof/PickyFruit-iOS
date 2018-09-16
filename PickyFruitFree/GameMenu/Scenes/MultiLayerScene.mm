//
//  MultiLayerScene.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "MultiLayerScene.h"
#import "TargetLayerEnumHelper.h"
#import "CCLayerWithWorld.h"
#import "UserInterfaceLayer.h"

//static MultiLayerScene *multiLayerSceneInstance = nil;

typedef enum{
    MultiLayerSceneTagINVALID = 0,
    MultiLayerSceneTagGameLayer,
    MultiLayerSceneTagUILayer,
    MultiLayerSceneTagMAX
} MultiLayerSceneTags;


@implementation MultiLayerScene


/*+(MultiLayerScene *)sharedScene
{
    NSAssert(multiLayerSceneInstance != nil, @"MultiLayerScene not available!");
    return multiLayerSceneInstance;
}*/

/*-(CCLayer *)gameLayer
{
    CCLayer *retVal;
    if([self getChildByTag:kTagGameLayer])
    {
        CCNode *layer = [self getChildByTag:kTagGameLayer];
        NSAssert1([layer isKindOfClass:[CCLayer class]], @"%@ not a CCLayer!", NSStringFromSelector(_cmd));
        retVal = (CCLayer *)layer;
    }
    return retVal;
}

-(UserInterfaceLayer *)uiLayer
{
    UserInterfaceLayer *retVal;
    if([self getChildByTag:kTagUserInterfaceLayer])
    {
        CCNode *layer = [self getChildByTag:kTagUserInterfaceLayer];
        NSAssert1([layer isKindOfClass:[UserInterfaceLayer class]], @"%@ not a UserInterfaceLayer!", NSStringFromSelector(_cmd));
        retVal = (UserInterfaceLayer *)layer;
    }
    return retVal;
}*/

+(id)sceneWithTargetLayer:(TargetLayerEnum)tl
{
    return [[[self alloc] initWithTargetLayer:tl] autorelease];
}

-(id)initWithTargetLayer:(TargetLayerEnum)tl
{
    if((self = [super init]))
    {
        //CGSize screenSize = [AppDelegate screenRect].size;
        //CGPoint screenCenter = [AppDelegate screenCenter];
        
        //multiLayerSceneInstance = self;
        
        CCLayerWithWorld *gameLayer = [self replaceTargetLayer:tl];
        // add weak reference to Game Layer 
        [[GameManager sharedInstance] setGameLayer:gameLayer];
         
        UserInterfaceLayer *uiLayer = [UserInterfaceLayer node];
        // add weak reference to UI Layer 
        [[GameManager sharedInstance] setUILayer:uiLayer];
        
        [self addChild:uiLayer z:2 tag:MultiLayerSceneTagUILayer];
    }
    
    return self;
}

-(CCLayerWithWorld*)replaceTargetLayer:(TargetLayerEnum)tl
{
    CCNode *node = [self getChildByTag:MultiLayerSceneTagGameLayer];
    if(node)
    {
        CCLOG(@"MultiLayerScene replaceTargetLayer: remove current layer, retain count = %d", [node retainCount]);
        [node removeFromParentAndCleanup:YES];
    }
    
    CCLayerWithWorld *gameLayer = [TargetLayerEnumHelper gameLayerFromEnumValue:tl];
    CCLOG(@"MultiLayerScene replaceTargetLayer: new layer retain count = %d", gameLayer.retainCount);
    if (gameLayer != nil) 
    {
        [self addChild:gameLayer z:1 tag:MultiLayerSceneTagGameLayer];
    }
    return gameLayer;
}

-(void)dealloc
{
    CCLOG(@"MultiLayerScene dealloc");
    //multiLayerSceneInstance = nil;
    
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


@end
