//
//  LightiningAnimationNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "LightiningAnimationNode.h"


@implementation LightiningAnimationNode


/*
+(id)bugAnimation
{
    return [[[self alloc] initWithBugAnimationImage] autorelease];
}

-(id)initWithBugAnimationImage
{
    // Load the Texture Atlas sprite frames, this also loads the Texture with the same name.
	CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[frameCache addSpriteFramesWithFile:@"BugAnimation.plist"];
    
	// Loading the Ship's sprite using a sprite frame name (eg the filename)
	if ((self = [super initWithSpriteFrameName:@"BugAnimation0.png"]))
	{
		// create an animation object from all the sprite animation frames
		CCAnimation* anim = [CCAnimation animationWithFrame:@"BugAnimation" frameCount:3 delay:0.08f];
		
		// add the animation to the sprite (optional)
		//[self addAnimation:anim];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[_sprite runAction:repeat];
		
		[self scheduleUpdate];
	}
	return self;
}
 */

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
            position:(b2Vec2)p 
                 tag:(int)t 
                name:(NSString *)n
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb
                               position:p 
                                    tag:t
                                   name:n] autorelease];
}

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb
          position:(b2Vec2)p 
               tag:(int)t 
              name:(NSString *)n
{
    // Load the Texture Atlas sprite frames, this also loads the Texture with the same name.
	CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[frameCache addSpriteFramesWithFile:@"LightiningAnimA.plist"];
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"LightiningAnimA0.png"];
    s.tag = t;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.1f;
    fd->friction = 0.5f;
    fd->restitution = 0.25f;
    b2CircleShape *shape = new b2CircleShape();
    shape->m_radius = spriteSizeInMeters.x * 0.51f;
    //fd.shape = &shape;
    
    // fruit node has density=2, friction=0.2, restitution=0.2
    if((self = [super initWithWorld:w
                         groundBody:gb
                           position:p 
                             sprite:s 
                                tag:t
                         fixtureDef:fd
                              shape:shape]))
    {
        [self animateOnce];
		
		//[self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"BugAnimation dealloc: retain count = %d", [self retainCount]);
    
    [super dealloc];
}

-(void) update:(ccTime)delta
{
}

-(void)animateOnce
{
    [_sprite stopAllActions];

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
    [_sprite runAction:animateAllThenHide];
}

-(void)onEnter
{
    [super onEnter];
    
    if(_animationRunning == false)
    {
        _animationRunning = true;
    }
}

-(void)onExit
{
    [self stopAllActions];
    [super onExit];
}

@end
