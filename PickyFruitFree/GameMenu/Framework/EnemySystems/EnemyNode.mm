//
//  EnemyNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/12/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "EnemyNode.h"
#import "ActorInfo.h"
#import "WorldHelper.h"
#import "CCAnimationHelper.h"
#import "EnemySystemNode.h"
#import "OutsideScreenEnum.h"
#import "CollisionTypeEnum.h"
#import "SimpleAudioEngine.h"

#define kTagParticleSystemSquish 1071087823


@implementation EnemyNode

@synthesize 
delegate = _delegate,
info = _info;


-(bool)isDying
{
    return _deadState != DeadStateINVALID;
}
/*
-(bool)isDead
{
    return _deadState == DeadStateEnded;
}*/

-(DeadStateEnum)deadState
{
    return _deadState;
}

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip
{
    return [[[self alloc] initWithLayer:layer
                                   info:info
                        initialPosition:ip] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip
{
    self.info = info;
    
    // hard coded anchor point
    _initialAnchorPoint = cgcenter;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
    b2FixtureDef *fd = new b2FixtureDef();
    fd->density = 0.0f;
    fd->friction = 0.0f;
    fd->restitution = 0.1f;
    b2CircleShape *shape = new b2CircleShape();
    shape->m_radius = spriteSizeInMeters.x * 0.5f;
    
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:ip 
                             sprite:s
                                  z:info.z
                    spriteFrameName:info.frameName
                                tag:info.tag
                         fixtureDef:fd
                              shape:shape]))
    {
        self.collisionType = info.collisionType;
        self.collidesWithTypes = info.collidesWithTypes;
        self.maskBits = info.maskBits;
        
        self.collisionCheckOn = false;
        //[self moveWings];
        
		[self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{
    CCLOG(@"EnemyNode dealloc %d", self.tag);
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [_info release];
    _info = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    _delegate = nil;
    _sprite = nil;
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    
    _body->SetAngularDamping(2.0f);
    anchorPoint_ = _initialAnchorPoint;
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void) update:(ccTime)delta
{
    if(self.outsideScreenValue != OutsideScreenINVALID
       && self.outsideScreenValue != OutsideScreenLeft)
    {
        //CCLOG(@"EnemyNode outsidescreen");
        if(self.delegate)
        {
            [self.delegate enemyDied:self];
        }
        
        //[self removeFromParentAndCleanup:YES];
        
        return;
    }
    
    if (_deadState == DeadStateInit)
    {
        [self stopAllActions];
        [self unscheduleAllSelectors];
        
        _deadState = DeadStateStarted;
        
        CCSprite *splash = [CCSprite spriteWithSpriteFrameName:@"SplashRed-32"];
        splash.position = self.sprite.position;
        [self.parent addChild:splash z:self.info.z+1 tag:self.tag+999999];
        [splash runAction:[CCFadeOut actionWithDuration:1.0f]];
        
        // or maybe i could use a particle system here like for the fruit explosion
        if(self.delegate)
        {
            [self.delegate enemyDied:self];
        }
        //[self removeFromParentAndCleanup:YES];
        //[_layer destroyBodyNodeWithSprite:self];
    }
}

//-(void)moveWings
//{
    /*[_sprite stopAllActions];
    // create an animation object from all the sprite animation frames
    CCAnimation* anim1 = [CCAnimation animationWithFrame:@"Animation" frameStart:0 frameEnd:1 delay:0.08f direction:1];
    CCAnimation* anim2 = [CCAnimation animationWithFrame:@"Animation" frameStart:1 frameEnd:2 delay:0.08f direction:1];
    CCAnimation* anim3 = [CCAnimation animationWithFrame:@"Animation" frameStart:0 frameEnd:0 delay:1.00f direction:1];
    
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate1 = [CCAnimate actionWithAnimation:anim1];
    CCAnimate* animate2 = [CCAnimate actionWithAnimation:anim2];
    CCAnimate* animate3 = [CCAnimate actionWithAnimation:anim3];
    //CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    CCRepeat* repeat1 = [CCRepeat actionWithAction:animate1 times:10];
    CCRepeat* repeat2 = [CCRepeat actionWithAction:animate2 times:5];
    CCRepeat* repeat3 = [CCRepeat actionWithAction:animate3 times:1];
    //[_sprite runAction:repeat];
    
    // to do something at the end of the animation, use CCSequence
    //CCSequence *animateThenHide = [CCSequence actions:repeat1, [CCHide action], nil];
    CCSequence *sequence = [CCSequence actions:repeat1, repeat2, repeat3, repeat1, nil];
    [_sprite runAction:sequence];*/
//}

//-(void)moveAntennas
//{
    /*[_sprite stopAllActions];
    // create an animation object from all the sprite animation frames
    CCAnimation* anim = [CCAnimation animationWithFrame:@"Animation" frameStart:1 frameEnd:2 delay:0.08f direction:1];
    
    // add the animation to the sprite (optional)
    //[self addAnimation:anim];
    
    // run the animation by using the CCAnimate action
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    
    [_sprite runAction:repeat];*/
//}

-(void)squish
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    self.maskBits = _info.maskBits 
        & ~CollisionTypeALL;
    
    self.collisionCheckOn = false;
        _deadState = DeadStateInit;
    
    [[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxBugSquish];
}

// touch
-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    return YES;
}
/*
-(void)ccTouchMoved:(UITouch *)touch 
          withEvent:(UIEvent *)event 
{
}

-(void)ccTouchCancelled:(UITouch *)touch 
              withEvent:(UIEvent *)event 
{
}
*/
-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //CCLOG(@"EnemyNode %d: ccTouchEnded", self.tag);
    if([self isTouchOnSprite:touch])
    {
        [self squish];
    }
}

@end
