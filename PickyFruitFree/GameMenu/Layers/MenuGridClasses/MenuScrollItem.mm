//
//  MenuScrollItem.m
//  MEM2
//
//  Created by Damiano Fusco on 2/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "MenuScrollItem.h"
#import "ImageGrayscaleHelper.h"
#import "GameManager.h"


@implementation MenuScrollItem


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

-(int)groupNumber
{
    return _groupNumber;
}

+(id)createWithFntFile:(NSString*)fntFile
              fontSize:(float)fontSize
               enabled:(bool)enabled 
                number:(int)number
             labelText:(NSString*)labelText
      reqScoreToEnable:(int)reqScoreToEnable
      reqStarsToEnable:(int)reqStarsToEnable
                 stars:(int)stars
                target:(id)target
              selector:(SEL)selector
{
    return [[[self alloc] initWithFntFile:fntFile 
                                 fontSize:fontSize
                                  enabled:enabled
                                   number:number
                                labelText:labelText
                         reqScoreToEnable:reqScoreToEnable
                         reqStarsToEnable:reqStarsToEnable
                                    stars:stars
                                   target:target
                                 selector:selector] autorelease];
}

-(id)initWithFntFile:(NSString*)fntFile
            fontSize:(float)fontSize
             enabled:(bool)enabled 
              number:(int)number
           labelText:(NSString*)labelText
    reqScoreToEnable:(int)reqScoreToEnable
    reqStarsToEnable:(int)reqStarsToEnable
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
        _groupNumber = number;
        self.tag = number;
        
        /*// create sprite
        if(_enabled)
        {
            // if enabled:
            NSString *frameName = [[NSString alloc] initWithFormat:@"ButtonGroupLevels%d", number];
            _sprite = [[CCSprite alloc] initWithSpriteFrameName:frameName];
            [frameName release];
            frameName = nil;
        }
        else
        {
            // if not enabled: 
            _sprite = [[CCSprite alloc] initWithSpriteFrameName:@"ButtonGroupLevels-disabled"];
        }*/
        
        // button sprite:
        NSString *frameName = [[NSString alloc] initWithFormat:@"ButtonGroupLevels%d", number];
        _sprite = [[CCSprite alloc] initWithSpriteFrameName:frameName];
        [frameName release];
        frameName = nil;
        
        //(buttonLevelTapped:)];
        _sprite.anchorPoint = cgzero;
        [self addChild:_sprite z:kInt0 tag:kInt0];
        
        int spriteWidth = _sprite.boundingBox.size.width;
        int spriteHeight = _sprite.boundingBox.size.height;
        int labelX = spriteWidth * 0.48f;
        int labelY = spriteHeight * kFloat0Point25;
        
        // create label
        CCLabelBMFont *label = [[CCLabelBMFont alloc] initWithString:labelText fntFile:fntFile];
        label.scale = fontSize;
        label.anchorPoint = cgcenterzero;
        //_label.color = ccBLUE;
        label.position = ccp(labelX, labelY);
        [self addChild:label z:kInt2 tag:kInt1];
        [label release];
        label = nil;
        
        if(_enabled == false)
        {
            //_sprite.color = ccc3(204, 204, 204);
            CCSprite *spriteDisabled = [[CCSprite alloc] initWithSpriteFrameName:@"ButtonGroupLevels-disabled"];
            spriteDisabled.anchorPoint = _sprite.anchorPoint;
            spriteDisabled.position = _sprite.position;
            spriteDisabled.opacity = 204; // 223
            [self addChild:spriteDisabled z:kInt1 tag:kInt2];
            [spriteDisabled release];
            spriteDisabled = nil;
            
            CCLabelBMFont *labelReqHeader = [[CCLabelBMFont alloc] initWithString:@"Need a score of:" fntFile:fntFile];
            labelReqHeader.scale = fontSize * kFloat0Point5;
            labelReqHeader.anchorPoint = cgcenterzero;
            labelReqHeader.position = ccp(labelX, spriteHeight * kFloat0Point8);
            [self addChild:labelReqHeader z:kInt2 tag:kInt3];
            [labelReqHeader release];
            labelReqHeader = nil;
            
            NSString* reqScoreText = [[NSString alloc] initWithFormat:@"%d", reqScoreToEnable];
            CCLabelBMFont *labelReqScore = [[CCLabelBMFont alloc] initWithString:reqScoreText fntFile:fntFile];
            labelReqScore.scale = fontSize * kFloat0Point5;
            [reqScoreText release];
            reqScoreText = nil;
            labelReqScore.anchorPoint = cgcenterzero;
            labelReqScore.position = ccp(labelX, spriteHeight * kFloat0Point7);
            [self addChild:labelReqScore z:kInt2 tag:kInt4];
            [labelReqScore release];
            labelReqScore = nil;
            
            NSString* reqStarsText = [[NSString alloc] initWithFormat:@"or %d stars", reqStarsToEnable];
            CCLabelBMFont *labelReqStars = [[CCLabelBMFont alloc] initWithString:reqStarsText fntFile:fntFile];
            labelReqStars.scale = fontSize * kFloat0Point5;
            [reqStarsText release];
            reqStarsText = nil;
            labelReqStars.anchorPoint = cgcenterzero;
            labelReqStars.position = ccp(labelX, spriteHeight * kFloat0Point6);
            [self addChild:labelReqStars z:kInt2 tag:kInt5];
            [labelReqStars release];
            labelReqStars = nil;
            
            CCLabelBMFont *labelReqFooter = [[CCLabelBMFont alloc] initWithString:@"to enable" fntFile:fntFile];
            labelReqFooter.scale = fontSize * kFloat0Point5;
            labelReqFooter.anchorPoint = cgcenterzero;
            labelReqFooter.position = ccp(labelX, spriteHeight * kFloat0Point5);
            [self addChild:labelReqFooter z:kInt2 tag:kInt6];
            [labelReqFooter release];
            labelReqFooter = nil;
        }
        
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
    CCLOG(@"MenuScrollItem dealloc");
    
    [_invocation release];
    
#if NS_BLOCKS_AVAILABLE
	[block_ release];
#endif
    
    [_sprite release];
    _sprite = nil;
    
    /*[_label release];
    _label = nil;
    
    if(!_enabled)
    {
        [_labelReq release];
        _labelReq = nil;
    }*/
    
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
