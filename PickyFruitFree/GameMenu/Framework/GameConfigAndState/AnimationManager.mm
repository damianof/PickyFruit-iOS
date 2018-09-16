//
//  AnimationManager.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/19/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "AnimationManager.h"


static AnimationManager *_sharedAnimationManager;
static CCSequence *_tractorDriverHitSequence;


@implementation AnimationManager

// static
+(AnimationManager *)sharedAnimationManager
{
    if(!_sharedAnimationManager)
    {
        _sharedAnimationManager = [[AnimationManager create] retain];
    }
    return _sharedAnimationManager;
}

+(CCSequence *)tractorDriverHitSequence
{
    return _tractorDriverHitSequence;
}

+(id)create
{
    return [[[self alloc] init] autorelease];
}

+(void)cleanup
{   
    // Cleanup method is called by the GameManager dealloc method
    [_sharedAnimationManager release];
    _sharedAnimationManager = nil;
}

-(id)init
{
    if((self = [super init]))
    {   
        [self setupAnimations];
    }
    return self;
}

-(void)dealloc
{
    [_tractorDriverHitSequence release];
    _tractorDriverHitSequence = nil;
    
    [super dealloc];
}

-(void)setupTractorDriverSequence
{
    // fwd animation with all frames
    /*id animFwd = [CCAnimation animationWithFrame:@"TractorDriver" 
     frameStart:0 
     frameEnd:1 
     delay:0.08f
     direction:1];*/
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *frame0 = [frameCache spriteFrameByName:@"TractorDriver0"];
    CCSpriteFrame *frame1 = [frameCache spriteFrameByName:@"TractorDriver1"];
    NSArray *framesFwd = [NSArray arrayWithObjects:frame0, frame1, nil];
    id animFwd = [CCAnimation animationWithFrames:framesFwd delay:0.08f];
    
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    id animateFwd = [CCAnimate actionWithAnimation:animFwd];
    
    // reverse animatino with all frames
    /*id animRew = [CCAnimation animationWithFrame:@"TractorDriver" 
     frameStart:0 
     frameEnd:1 
     delay:0.25f
     direction:0];*/
    
    NSArray *framesRew = [NSArray arrayWithObjects:frame1, frame0, nil];
    id animRew = [CCAnimation animationWithFrames:framesRew delay:0.025f];
    
    frame0 = nil;
    frame1 =  nil;
    
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    id animateRew = [CCAnimate actionWithAnimation:animRew];
    
    //id setAnimationRunningToFalse = [CCCallFunc actionWithTarget:self selector:@selector(setAnimationRunningToFalse)];
    _tractorDriverHitSequence = [[CCSequence actions:animateFwd, animateRew, nil] retain];
    //setAnimationRunningToFalse = nil;
}

-(void)setupAnimations
{
    [self setupTractorDriverSequence];
}

@end
