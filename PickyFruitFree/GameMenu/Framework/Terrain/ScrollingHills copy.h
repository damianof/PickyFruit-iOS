//
//  ScrollingHills.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/29/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "DevicePositionHelper.h"

@class CCLayerWithWorld;


@interface ScrollingHills : CCNode
{
    CCLayerWithWorld *_layer;
    int _offsetX;
    int _unitsOffsetX;
    
    UnitsRect _unitsScreenRect;
    UnitsPoint _unitsPosition;
    

    b2Vec2 _b2Position;
    float _bodyWidth;
    int _numberOfBodies;
    CCArray *_bodies;
    float _speed;
    
    float _lastSectionY;
    
    float _pixelsToMeterRatio;
}

@property (nonatomic, assign) float speed;

+(id)createWithLayer:(CCLayerWithWorld*)layer
       unitsPosition:(UnitsPoint)unitsPosition
               speed:(float)speed;
-(id)initWithLayer:(CCLayerWithWorld*)layer
     unitsPosition:(UnitsPoint)unitsPosition
             speed:(float)speed;

-(void)generateBodies;

@end
