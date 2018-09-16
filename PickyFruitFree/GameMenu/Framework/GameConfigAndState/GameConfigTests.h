//
//  GameConfigTests.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/15/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameConfigAndState;
@class GDataXMLElement;
@class ActorInfo;

@interface GameConfigTests : NSObject


+(ActorInfo*)enemyNodeInfo:(NSString*)fn
            framesFileName:(NSString*)ffn
               imageFormat:(NSString*)imageFormat;


@end
