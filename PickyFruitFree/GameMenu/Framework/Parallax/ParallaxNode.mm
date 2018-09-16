//
//  ParallaxNode.mm
//  TestBox2D
//
//  Created by Damiano Fusco on 3/21/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParallaxNode.h"
#import "BackgroundSpriteEnum.h"
#import "DevicePositionHelper.h"
#import "ParallaxInfo.h"
#import "ParallaxSpriteInfo.h"
#import "GameManager.h"


typedef enum{
    ParallaxNodeTagINVALID = 0,
    ParallaxNodeTagBatchNode,
    ParallaxNodeTagMAX
} ParallaxNodeTags;


@implementation ParallaxNode


+(id)createWithInfo:(ParallaxInfo*)pi
{
    return [[[self alloc] initWithInfo:pi] autorelease];
}

-(id)initWithInfo:(ParallaxInfo*)pi
{
    if((self = [super init]))
    {
        _info = pi;
        _framesFileName = [_info.framesFileName copy];
        
        //_screenRect = [DevicePositionHelper screenRect];
        //_screenCenter = [DevicePositionHelper screenCenter];
        //CCLOG(@"ParallaxBackground: %f %f", _screenRect.size.width, _screenRect.size.height);
        
        // add frames file
        if ([pi.imageFormat isEqualToString:kImageFormatPvrCcz]) 
        {
            //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:pi.framesFileName] z:0 tag:ParallaxNodeTagBatchNode]; 
        }
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:pi.framesFileName];
        
        //CCTexture2D *gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:pi.textureImage];
        //[self addChild:[CCSpriteBatchNode batchNodeWithTexture:gameArtTexture]];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:pi.framesFileName];
        
        //int yposition = 0;
        //int screenHeight = _screenRect.size.height;
        //int z = 0;
        //float factor = 0;
        
        int spriteCount = pi.spritesInfo.count;
        UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
        
        for (ParallaxSpriteInfo *info in pi.spritesInfo) 
        {
            UnitsPoint unitsPosition = info.unitsPosition;
            if(info.positionFromTop)
            {
                unitsPosition = UnitsPointMake(unitsPosition.x, // + pi.unitsFromEdge, 
                                               screenUnitsSize.height-unitsPosition.y); //pi.unitsFromEdge);
            }
            else
            {
                unitsPosition = UnitsPointMake(unitsPosition.x, // + pi.unitsFromEdge, 
                                               unitsPosition.y + pi.unitsYOffset);
            }
            
            CGPoint position = [DevicePositionHelper pointFromUnitsPoint:unitsPosition];
            
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:info.frameName];
            sprite.anchorPoint = info.anchorPoint;
            sprite.position = position;
            sprite.tag = info.tag;
            sprite.parallaxSpeed = info.speedFactor;
            [self addChild:sprite z:info.z tag:info.tag];
            
            if(info.speedFactor > kFloat0)
            {
                // reflected sprite for infinite scrolling
                CCSprite *spriteRef = [CCSprite spriteWithSpriteFrameName:info.frameName];
                spriteRef.anchorPoint = info.anchorPoint;
                spriteRef.position = CGPointMake([sprite boundingBox].size.width-1, position.y);
                
                spriteRef.tag = info.tag + spriteCount;
                spriteRef.flipX = YES;
                spriteRef.parallaxSpeed = info.speedFactor;
                [self addChild:spriteRef z:info.z tag:info.tag+kInt0];
            }
        }
        
        _speed = 1;
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)dealloc
{
    CCLOG(@"ParallaxNode dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:_framesFileName];
    
    [_framesFileName release];
    _framesFileName = nil;
    
    _info = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(void)onExit
{
    CCLOG(@"ParallaxNode onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super onExit];
}

-(void)update:(ccTime)delta
{
    if([GameManager sharedInstance].running)
    {
        id node = nil;
        //CCARRAY_FOREACH([_spriteBatch children], sprite)
        CCARRAY_FOREACH([self children], node)
        {   
            if([node isKindOfClass:[CCSprite class]])
            {
                CCSprite *sprite = (CCSprite*)node;
                if(sprite.parallaxSpeed > kFloat0)
                {
                    CGPoint pos = sprite.position;
                    pos.x -= (_speed * sprite.parallaxSpeed);
                    // reposition when they go off screen
                    if(pos.x < -[sprite boundingBox].size.width)
                    {
                        pos.x += ([sprite boundingBox].size.width * kInt2) - kInt2;
                    }
                    //CCLOG(@"Position: speed %f.1 x %f.1 %f", _speed, sprite.parallaxSpeed, pos.x);
                    sprite.position = pos;
                }
            }
        }
    }
}

@end
