//
//  WorldHelper.h
//
//  Created by Damiano Fusco on 4/11/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"


@interface WorldHelper : NSObject {
    
}

+(void)initializeMouseJointsDictionary;

+(void)destroyMouseJointsDictionary;

// mouse joints methods
+(b2MouseJoint *)createMouseJoint:(b2World *)w
                    mouseJointDef:(b2MouseJointDef)mjd
                          bodyTag:(int)t;

+(void)destroyMouseJointByTag:(b2World *)w
                          tag:(int)t;

+(b2MouseJoint *)getMouseJointForBodyNode:(b2World *)w
                                      tag:(int)t;

@end
