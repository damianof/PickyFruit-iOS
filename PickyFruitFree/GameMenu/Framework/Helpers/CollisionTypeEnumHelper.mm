//
//  CollisionTypeEnumHelper.mm
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "CollisionTypeEnumHelper.h"


@implementation CollisionTypeEnumHelper


+(CollisionTypeEnum)enumValueFromName:(NSString *)n
{
    CollisionTypeEnum retVal = CollisionTypeZERO;
    
    if ([n isEqualToString:@"CollisionTypeZERO"]) {
        retVal = CollisionTypeZERO;
    }
    
    // world
    else if ([n isEqualToString:@"CollisionTypeWorldFloor"]) {
        retVal = CollisionTypeWorldFloor;
    }
    else if ([n isEqualToString:@"CollisionTypeWorldTop"]) {
        retVal = CollisionTypeWorldTop;
    }
    else if ([n isEqualToString:@"CollisionTypeWorldLeft"]) {
        retVal = CollisionTypeWorldLeft;
    }
    else if ([n isEqualToString:@"CollisionTypeWorldRight"]) {
        retVal = CollisionTypeWorldRight;
    }
    
    // actors
    else if ([n isEqualToString:@"CollisionTypeTruck"]) {
        retVal = CollisionTypeTruck;
    }
    else if ([n isEqualToString:@"CollisionTypeTruckDriver"]) {
        retVal = CollisionTypeTruckDriver;
    }
    else if ([n isEqualToString:@"CollisionTypeChain"]) {
        retVal = CollisionTypeChain;
    }
    else if ([n isEqualToString:@"CollisionTypeFruit"]) {
        retVal = CollisionTypeFruit;
    }
    else if ([n isEqualToString:@"CollisionTypeHail"]) {
        retVal = CollisionTypeHail;
    }
    //else if ([n isEqualToString:@"CollisionTypeBug"]) {
    //    retVal = CollisionTypeBug;
    //}
    
    // obstacles
    else if ([n isEqualToString:@"CollisionTypeObstacleWall"]) {
        retVal = CollisionTypeObstacleWall;
    }
    else if ([n isEqualToString:@"CollisionTypeObstacleHCart"]) {
        retVal = CollisionTypeObstacleHCart;
    }
    else if ([n isEqualToString:@"CollisionTypeEnemy"]) {
        retVal = CollisionTypeEnemy;
    }
    
    else if ([n isEqualToString:@"CollisionTypeALL"]) {
        retVal = CollisionTypeALL;
    }
    
    return retVal;
}

+(uint16)valueFromName:(NSString *)n
{
    uint16 retVal = 0x0000;
    
    bool negate = false;
    if ([[n substringToIndex:1] isEqualToString:@"~"]) {
        n = [n substringFromIndex:1];
        negate = true;
    }
    
    retVal = [self enumValueFromName:n];
    
    if(negate)
    {
        retVal = ~retVal;
    }
    
    return retVal;
}


@end
