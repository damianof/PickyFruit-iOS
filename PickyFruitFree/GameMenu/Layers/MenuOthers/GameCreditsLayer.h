//
//  GameCreditsLayer.h
//  PickyFruit
//
//  Created by Damiano Fusco on 2/26/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "cocos2d.h"


@interface GameCreditsLayer : CCLayer <MFMailComposeViewControllerDelegate>
{
    int _tagTouched;
    CCSprite *_spriteTouched;
}

@end
