//
//  CollisionTypeEnumHelper.h
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollisionTypeEnum.h"
#import "Box2D.h"


@interface CollisionTypeEnumHelper : NSObject {
    
}

+(CollisionTypeEnum)enumValueFromName:(NSString *)n;

+(uint16)valueFromName:(NSString *)n;

@end
