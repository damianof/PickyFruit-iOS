//
//  TargetLayerEnumHelper.h
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetLayerEnum.h"

@class CCLayer;
@class CCLayerWithWorld;


@interface TargetLayerEnumHelper : NSObject {
    
}

+(TargetLayerEnum)enumValueFromName:(NSString *)n;

+(CCLayer*)menuLayerFromEnumValue:(TargetLayerEnum)enumValue;

+(CCLayerWithWorld*)gameLayerFromEnumValue:(TargetLayerEnum)enumValue;

@end
