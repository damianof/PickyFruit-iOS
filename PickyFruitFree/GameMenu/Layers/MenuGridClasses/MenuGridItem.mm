//
//  MenuGridItem.m
//  MEM2
//
//  Created by Damiano Fusco on 2/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "MenuGridItem.h"
#import "GameManager.h"


@implementation MenuGridItem


-(ccColor3B)color
{
    return _sprite.color;
}

-(void)setColor:(ccColor3B)newcolor
{
    _sprite.color = newcolor;
}

-(CGRect)boundingBox
{
    return _sprite.boundingBox;
}

-(bool)enabled
{
    return _enabled;
}

+(id)createWithFntFile:(NSString*)fntFile
              fontSize:(float)fontSize
               enabled:(bool)enabled 
                number:(int)number
                 stars:(int)stars
                target:(id)target
              selector:(SEL)selector
{
    return [[[self alloc] initWithFntFile:fntFile 
                                 fontSize:fontSize
                                  enabled:enabled
                                   number:number
                                    stars:stars
                                   target:target
                                 selector:selector] autorelease];
}

-(id)initWithFntFile:(NSString*)fntFile
            fontSize:(float)fontSize
             enabled:(bool)enabled 
              number:(int)number
               stars:(int)stars
              target:(id)target
            selector:(SEL)selector
{
    if ( (self = [super init]) )
	{
        NSMethodSignature * sig = nil;
		
		if(target && selector) 
        {
			sig = [target methodSignatureForSelector:selector];
			
			_invocation = nil;
			_invocation = [NSInvocation invocationWithMethodSignature:sig];
			[_invocation setTarget:target];
			[_invocation setSelector:selector];
#if NS_BLOCKS_AVAILABLE
			if ([sig numberOfArguments] == 3) 
#endif
                [_invocation setArgument:&self atIndex:2];
			
			[_invocation retain];
		}
        
        // set enabled property
        _enabled = enabled;
        self.tag = number;
        
        // create sprite
        if(_enabled)
        {
            // if enabled:
            NSString *frameName = [[NSString alloc] initWithFormat:@"ButtonLevel-stars%d", stars];
            _sprite = [[CCSprite alloc] initWithSpriteFrameName:frameName];
            [frameName release];
            frameName = nil;
        }
        else
        {
            // if not enabled:
            _sprite = [[CCSprite alloc] initWithSpriteFrameName:@"ButtonLevel-disabled"];
        }
        //(buttonLevelTapped:)];
        _sprite.anchorPoint = cgzero;
        [self addChild:_sprite z:kInt0 tag:kInt0];
        
        // create label
        NSString* strLevelText = [[NSString alloc] initWithFormat:kStringFormatInt, number];
        _label = [[CCLabelBMFont alloc] initWithString:strLevelText fntFile:fntFile];
        _label.scale = fontSize;
        [strLevelText release];
        strLevelText = nil;
        _label.anchorPoint = cgcenterzero;
        //_label.color = ccWHITE;
        _label.position = ccp(_sprite.boundingBox.size.width * kFloat0Point4, _sprite.boundingBox.size.height * kFloat0Point025);
        [self addChild:_label z:kInt1 tag:kInt1];
        
        /*// show stars count
         for(int i = 1; i <= gameLevel.stateStars; i++)
         {
         CCSprite *star = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameButtonLevelStarOverlay];
         int starWidth = [star boundingBox].size.width;
         star.anchorPoint = starsIconAnchorPoint;
         star.position = CGPointMake(((i-1)*starWidth/2), 0);
         [menuItem addChild:star z:i tag:gameLevel.number];
         [star release];
         star = nil;
         }*/
	}
    
	return self;
}

-(void)dealloc
{
    CCLOG(@"MenuGridItem dealloc");
    
    [_invocation release];
    
#if NS_BLOCKS_AVAILABLE
	[block_ release];
#endif
    
    [_sprite release];
    _sprite = nil;
    
    [_label release];
    _label = nil;
    
    [super removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

-(void)activate
{
	if(_enabled
       && _invocation 
       && _invocation.target)
    {
        [_invocation invoke];
    }
}

@end
