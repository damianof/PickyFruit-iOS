//
//  LoadingScene.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/20/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "cocos2d.h"
#import "LoadingScene.h"

typedef enum{
    LoadingSceneTagINVALID = 0,
    LoadingSceneLabelLoading,
    LoadingSceneTagMAX
} LoadingSceneTags;


@implementation LoadingScene

+(id)sceneWithTargetScene:(TargetSceneEnum)targetScene
           andTargetLayer:(TargetLayerEnum)targetLayer
{
    // creates an autorelease object of the current class (self == LoadingScene)
    return [[[self alloc] initWithTargetScene:targetScene 
                               andTargetLayer:targetLayer] autorelease];
}

-(id)initWithTargetScene:(TargetSceneEnum)targetScene
          andTargetLayer:(TargetLayerEnum)targetLayer
{
    if((self = [super init]))
    {
        _targetScene = targetScene;
        _targetLayer = targetLayer;
        
        CGSize screenSize = [DevicePositionHelper screenRect].size;
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        int fontSize = screenSize.width * kTenInverted;
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Loading..."
                                               fontName:kMarkerFelt
                                               fontSize:fontSize];
        label.position = screenCenter;
        [self addChild:label z:kInt0 tag:LoadingSceneLabelLoading];
        
        [self scheduleUpdate];
    }
    
    return self;
}


-(void)dealloc
{
    CCLOG(@"LoadingScene dealloc");
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    //multiLayerSceneInstance = nil;
    [super dealloc];
}

-(void)onEnter
{
    CCLOG(@"LoadingScene onEnter");    
    [super onEnter];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)update:(ccTime)delta
{
    _timeElapsedFromStart += delta;
    
    // if 1 second has passed
    if(_timeElapsedFromStart > 1)
    {
        // unschedule so that Update is called only once
        [self unscheduleAllSelectors];
        // call select scene
        [self selectScene];
    }
}

-(void)selectScene
{
    switch (_targetScene) 
    {
        [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
            
        case TargetSceneMenu:
        {
            // Can't use SceneHelper here
            GameMenuScene *scene = [GameMenuScene sceneWithTargetLayer:_targetLayer];
            [[CCDirector sharedDirector] replaceScene:scene];
            
            break;
        }
        case TargetSceneMultiLayer:
        {
            // Can't use SceneHelper here
            MultiLayerScene *scene = [MultiLayerScene sceneWithTargetLayer:_targetLayer];
            [[CCDirector sharedDirector] replaceScene:scene];
            break;
        }
        default:
        {
            NSAssert2(nil, @"%@: unsupported TargetScene %i", NSStringFromSelector(_cmd), _targetScene);
            break;
        }
    }
}

@end
