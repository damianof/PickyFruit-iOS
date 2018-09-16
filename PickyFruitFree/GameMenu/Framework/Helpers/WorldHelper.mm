//
//  WorldHelper.mm
//
//  Created by Damiano Fusco on 4/11/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "WorldHelper.h"


static NSMutableDictionary *_dictMouseJoints;

@implementation WorldHelper

+(void)initializeMouseJointsDictionary
{
    if(_dictMouseJoints==false)
    {
        //CCLOG(@"WorldHelper: initializing _dictMouseJoints");
        _dictMouseJoints = [[NSMutableDictionary alloc] init];
    }
}

+(void)destroyMouseJointsDictionary
{
    [_dictMouseJoints release];
    _dictMouseJoints = nil;
}

// new function for multi-touch
+(b2MouseJoint *)createMouseJoint:(b2World *)w
                    mouseJointDef:(b2MouseJointDef)mjd
                          bodyTag:(int)t
{
    //CCLOG(@"WorldHelper: createMouseJoint %d", t);
    
    // make sure any existing mousejoint on this body is destroyed
    [self destroyMouseJointByTag:w tag:t];
    
    // create joint and add to dictionary
    NSString *k = [[NSNumber numberWithInt:t] stringValue];
    b2Joint *j = w->CreateJoint(&mjd);
    //bool retVal = false;
    if(j)
    {
        NSValue *jv = [NSValue valueWithPointer:j];
        [_dictMouseJoints setObject:jv forKey:k];
        //retVal = true;
    }
    //return retVal;
    return (b2MouseJoint *)j;
}

+(void)destroyMouseJointByTag:(b2World *)w
                          tag:(int)t
{
    //CCLOG(@"WorldHelper: destroyMouseJointByTag %d", t);
    
    NSString *k = [[NSNumber numberWithInt:t] stringValue];
    
    if([_dictMouseJoints objectForKey:k])
    {
        NSValue *mjv = (NSValue *)[_dictMouseJoints objectForKey:k];
        
        if(w && mjv)
        {
            b2Joint *j = (b2Joint *)[mjv pointerValue];
            w->DestroyJoint(j);
            
            [_dictMouseJoints removeObjectForKey:k];
        }
    }
}

+(b2MouseJoint *)getMouseJointForBodyNode:(b2World *)w
                                      tag:(int)t
{
    //CCLOG(@"WorldHelper: getMouseJointForBodyNode %d", t);
    
    b2MouseJoint *retVal = NULL;
    NSString *k = [[NSNumber numberWithInt:t] stringValue];
    if([_dictMouseJoints objectForKey:k])
    {
        NSValue *mjv = (NSValue *)[_dictMouseJoints objectForKey:k];
        if([mjv pointerValue])
        {
            b2Joint *j = (b2Joint *)[mjv pointerValue];
            retVal = (b2MouseJoint *)j;
        }
    }
    return retVal;
}


@end
