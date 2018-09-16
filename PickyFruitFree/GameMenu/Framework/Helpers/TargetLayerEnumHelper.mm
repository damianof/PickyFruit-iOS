//
//  TargetLayerEnumHelper.mm
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TargetLayerEnumHelper.h"
#import "cocos2d.h"
#import "GameLayers.h"
#import "GameMenuLayers.h"
#import "CCLayerWithWorld.h"


@implementation TargetLayerEnumHelper


+(TargetLayerEnum)enumValueFromName:(NSString *)n
{
    TargetLayerEnum retVal = TargetLayerINVALID;
    
    if ([n isEqualToString:@"TargetLayerINVALID"]) {
        retVal = TargetLayerINVALID;
    }
    else if ([n isEqualToString:@"TargetLayerMenuPlay"]) {
        retVal = TargetLayerMenuPlay;
    }
    else if ([n isEqualToString:@"TargetLayerMenuCredits"]) {
        retVal = TargetLayerMenuCredits;
    }
    else if ([n isEqualToString:@"TargetLayerMenuGroupLevels"]) {
        retVal = TargetLayerMenuGroupLevels;
    }
    else if ([n isEqualToString:@"TargetLayerMenuLevels"]) {
        retVal = TargetLayerMenuLevels;
    }
    else if ([n isEqualToString:@"TargetLayerMenuLevelPassed"]) {
        retVal = TargetLayerMenuLevelPassed;
    }
    else if ([n isEqualToString:@"TargetLayerGameLayer1"]) {
        retVal = TargetLayerGameLayer1;
    }
    else if ([n isEqualToString:@"TargetLayerGameLayer2"]) {
        retVal = TargetLayerGameLayer2;
    }
    else if ([n isEqualToString:@"TargetLayerGameLayer3"]) {
        retVal = TargetLayerGameLayer3;
    }
    else if ([n isEqualToString:@"TargetLayerGameLayer4"]) {
        retVal = TargetLayerGameLayer4;
    }
    else if ([n isEqualToString:@"TargetLayerGameLayerTests"]) {
        retVal = TargetLayerGameLayerTests;
    }
    else if ([n isEqualToString:@"TargetLayerMAX"]) {
        retVal = TargetLayerMAX;
    }
    
    return retVal;
}

+(CCLayer*)menuLayerFromEnumValue:(TargetLayerEnum)enumValue
{
    CCLayer *layer = nil;
    
    switch (enumValue) 
    {
        case TargetLayerMenuPlay:
        {
            layer = [GameMenuPlayLayer node];
            break;
        }
        case TargetLayerMenuCredits:
        {
            layer = [GameCreditsLayer node];
            break;
        }
        case TargetLayerMenuGroupLevels:
        {
            layer = [GameMenuGroupLevelsLayer node];
            break;
        }
        case TargetLayerMenuLevels:
        {
            layer = [GameMenuLevelsLayer node];
            break;
        }
        case TargetLayerMenuLevelPassed:
        {
            layer = [GameMenuLevelPassedLayer node];
            break;
        }
        case TargetLayerMenuLevelFailed:
        {
            layer = [GameMenuLevelFailedLayer node];
            break;
        }
        case TargetLayerMenuTest:
        {
            layer = [GameMenuTestLayer node];
            break;
        }
        default:
        {
            NSAssert1(nil, @"TargetLayerEnumHelper: menuLayerFromEnumValue: unsupported TargetLayer %i", enumValue);
            break;
        }
    }
    
    //CCLOG(@"TargetLayerEnumHelper menuLayerFromEnumValue layer retain count %d", layer.retainCount);
    
    return layer;
}


+(CCLayerWithWorld*)gameLayerFromEnumValue:(TargetLayerEnum)enumValue
{
    CCLayerWithWorld *layer = nil;
    
    switch (enumValue) 
    {
        case TargetLayerGameLayer1:
        {
            layer = [GameLayer1 node];
            break;
        }
        case TargetLayerGameLayer2:
        {
            layer = [GameLayer2 node];
            break;
        }
        case TargetLayerGameLayer3:
        {
            layer = [GameLayer3 node];
            break;
        }
        case TargetLayerGameLayer4:
        {
            layer = [GameLayer4 node];
            break;
        }
        case TargetLayerGameLayerTests:
        {
            NSAssert(nil, @"TargetLayerEnumHelper: gameLayerFromEnumValue: TargetLayerGameLayerTests commented out");
            //layer = [GameLayerTests node];
            break;
        }
        default:
        {
            NSAssert1(nil, @"TargetLayerEnumHelper: gameLayerFromEnumValue: unsupported TargetLayer %i", enumValue);
            break;
        }
    }
    
    return layer;
}


@end
