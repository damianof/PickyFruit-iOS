//
//  LightiningAnimationNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "LightiningAnimationNode.h"
#import "CCAnimationHelper.h"


@implementation LightiningAnimationNode


+(id)createWithPosition:(CGPoint)p 
                    tag:(int)t 
                   name:(NSString *)n
{
    return [[[self alloc] initWithPosition:p 
                                       tag:t
                                      name:n] autorelease];
}

-(id)initWithPosition:(CGPoint)p 
               tag:(int)t 
              name:(NSString *)n
{    
    // fruit node has density=2, friction=0.2, restitution=0.2
    if ((self = [super initWithSpriteFrameName:@"LightiningAnimA0"]))
    {
        self.tag = t;
        self.position = p; // very important
        //[self animateOnce];
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"LightiningAnimA tag %d dealloc", self.tag);
    [super dealloc];
}

-(void)animateOnce
{
    [self stopAllActions];

    // fwd animation with all frames
    CCAnimation* animFullFwd = [CCAnimation animationWithFrame:@"LightiningAnimA" 
                                                    frameStart:0 
                                                      frameEnd:8 
                                                         delay:0.01f
                                                     direction:1];
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    CCAnimate* animateAllFwd = [CCAnimate actionWithAnimation:animFullFwd];
    CCRepeat* repeatAllFwd1 = [CCRepeat actionWithAction:animateAllFwd times:1];
    
    // reverse animatino with all frames
    CCAnimation* animFullRew = [CCAnimation animationWithFrame:@"LightiningAnimA" 
                                                    frameStart:0 
                                                      frameEnd:8 
                                                         delay:0.05f
                                                     direction:0];
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    CCAnimate* animateAllRew = [CCAnimate actionWithAnimation:animFullRew];
    CCRepeat* repeatAllRew1 = [CCRepeat actionWithAction:animateAllRew times:1];
    
    CCSequence *animateAllThenHide = [CCSequence actions:repeatAllFwd1, repeatAllRew1, [CCHide action], nil];
    
    [self runAction:animateAllThenHide];
}

-(void)onEnter
{
    [super onEnter];
    
    [self animateOnce];
    //if(_animationRunning == false)
    //{
    //    _animationRunning = true;
    //}
}

-(void)onExit
{
    [self stopAllActions];
    [super onExit];
}

@end
