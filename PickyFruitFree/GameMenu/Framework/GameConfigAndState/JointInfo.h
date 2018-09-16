//
//  JointInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "DevicePositionHelper.h"


@interface JointInfo : NSObject 
{
    NSString *_typeName; // "Prismatic" etc 
    NSString *_joinWith; // "Ground" 
    
    b2Vec2 _worldAxis;
}

@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *joinWith;

@property (nonatomic, assign) b2Vec2 worldAxis;


+(id)createWithTypeName:(NSString *)tn;
-(id)initWithTypeName:(NSString *)tn;


@end
