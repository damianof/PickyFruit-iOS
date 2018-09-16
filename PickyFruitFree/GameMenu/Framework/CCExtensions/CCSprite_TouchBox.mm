//
//  CCSprite_TouchBox.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/14/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
/*
#import "CCSprite_TouchBox.h"


@implementation CCSprite (TouchBox)


-(bool)isWithinRect:(CGRect)rect
{
    return CGRectIntersectsRect(self.boundingBox, rect);
}

//-(bool)isWithinOtherSprite:(CCSprite *)otherSprite
//{
//CGRect otherRect = [otherSprite boundingBox];
//return [self isWithinRect:otherRect]; //CGRectIntersectsRect([self box], otherRect);
//}

-(bool)isTouchOnSprite:(UITouch*)touch
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    CGRect rect = self.boundingBox;
    int width = rect.size.width;
    int height = rect.size.height;
    int halfWidth = width * kFloat0Point5;
    int halfHeight = height * kFloat0Point5;
    CGRect touchRect = CGRectMake(location.x-halfWidth,location.y-halfHeight, width, height);
    bool retVal = [self isWithinRect:touchRect];
    return retVal;
}
@end*/
