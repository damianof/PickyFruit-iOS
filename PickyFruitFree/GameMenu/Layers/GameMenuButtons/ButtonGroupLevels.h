//
//  ButtonGroupLevels.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface ButtonGroupLevels : CCNode 
{
    int _groupNumber;
}

+(id)buttonGroupWithName:(NSString *)name 
               andNumber:(int)number;

-(id)initWithName:(NSString *)name 
        andNumber:(int)number;

-(void)buttonTapped:(id)sender;


@end
