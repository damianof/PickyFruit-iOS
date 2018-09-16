//
//  FruitSlotInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/23/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
//#import <Foundation/Foundation.h>
//#import "cocos2d.h"
#import "Box2D.h"


@interface FruitSlotInfo : NSObject
{
    b2Vec2 _position;
    bool _filled;
}

@property (nonatomic, readonly) b2Vec2 position;
@property (nonatomic, readwrite) bool filled;

-(void)setNewPosition:(b2Vec2)p;

+(id)createWithPosition:(b2Vec2)position;
-(id)initWithPosition:(b2Vec2)position;



@end
