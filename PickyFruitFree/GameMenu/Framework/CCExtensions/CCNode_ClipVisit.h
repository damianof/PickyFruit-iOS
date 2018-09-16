//
//  CCNode_ClipVisit.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/14/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCNode (ClipVisit)

-(void)preVisitWithClippingRect:(CGRect)rect;
-(void)postVisit;

@end
