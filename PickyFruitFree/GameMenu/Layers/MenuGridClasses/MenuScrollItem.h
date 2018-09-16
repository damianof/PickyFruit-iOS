//
//  MenuScrollItem.h
//  MEM2
//
//  Created by Damiano Fusco on 2/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface MenuScrollItem : CCNode
{
    NSInvocation *_invocation;
#if NS_BLOCKS_AVAILABLE
	// used for menu items using a block
	void (^block_)(id sender);
#endif
    
    CCSprite *_sprite;
    /*CCLabelBMFont *_label;
    CCLabelBMFont *_labelReqScore;
    CCLabelBMFont *_labelReqStars;*/
    
    bool _enabled;
    int _groupNumber;
}

@property (nonatomic, readwrite) ccColor3B color;
//@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) int groupNumber;
@property (nonatomic, readonly) bool enabled;

+(id)createWithFntFile:(NSString*)fntFile
              fontSize:(float)fontSize
               enabled:(bool)enabled 
                number:(int)number
             labelText:(NSString*)labelText
      reqScoreToEnable:(int)reqScoreToEnable
      reqStarsToEnable:(int)reqStarsToEnable
                 stars:(int)stars
                target:(id)target
              selector:(SEL)selector;

-(id)initWithFntFile:(NSString*)fntFile
            fontSize:(float)fontSize
             enabled:(bool)enabled 
              number:(int)number
           labelText:(NSString*)labelText
    reqScoreToEnable:(int)reqScoreToEnable
    reqStarsToEnable:(int)reqStarsToEnable
               stars:(int)stars
              target:(id)target
            selector:(SEL)selector;

-(void)activate;

@end
