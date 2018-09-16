//
//  DevicePositionHelper.h
//
//  Created by Damiano Fusco on 4/4/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "MathHelper.h"


struct UnitsPoint {
    float x;
    float y;
};
typedef struct UnitsPoint UnitsPoint;

struct UnitsSize {
    float width;
    float height;
};
typedef struct UnitsSize UnitsSize;

struct UnitsRect {
    UnitsPoint origin;
    UnitsSize size;
};
typedef struct UnitsRect UnitsRect;

struct UnitsBounds {
    float upper;
    float lower;
};
typedef struct UnitsBounds UnitsBounds;

UnitsPoint UnitsPointMake(float x, float y);
UnitsSize UnitsSizeMake(float width, float height);
UnitsRect UnitsRectMake(float x, float y, float width, float height);
UnitsBounds UnitsBoundsMake(float upper, float lower);

UnitsPoint UnitsPointFromString(NSString *strValue);
UnitsSize UnitsSizeFromString(NSString *strValue);
UnitsRect UnitsRectFromString(NSString *strValue);
UnitsBounds UnitsBoundsFromString(NSString *strValue);


@interface DevicePositionHelper : NSObject 
{    
}

+(CGPoint)gradientVector;

+(float)scaleFactor;

+(CGRect)screenRect;
+(CGPoint)screenCenter;
+(UnitsRect)screenUnitsRect;
+(UnitsPoint)screenUnitsCenter;

+(b2Vec2)screenB2Vec2Size;
+(b2Vec2)screenB2Vec2Center;

+(float)unitInPoints;
+(float)unitInPixels;
+(float)unitInBox2D;

+(float)cgFromUnits:(float)u;

+(CGPoint)pointFromUnitsPoint:(UnitsPoint)up;
+(UnitsPoint)unitsPointFromPoint:(CGPoint)p;
+(CGSize)sizeFromUnitsSize:(UnitsSize)us;
+(UnitsSize)unitsSizeFromSize:(CGSize)s;
+(CGPoint)pointFromUnitsBounds:(UnitsBounds)ub;
+(UnitsBounds)unitsBoundsFromPoint:(CGPoint)p;

+(b2Vec2)b2Vec2FromUnitsPoint:(UnitsPoint)up;
+(b2Vec2)b2Vec2FromUnitsSize:(UnitsSize)us;
+(b2Vec2)b2Vec2FromUnitsBounds:(UnitsBounds)ub;

+(CGRect)rectFromUnitsRect:(UnitsRect)ur;
+(UnitsRect)unitsRectFromRect:(CGRect)r;

// from box2dhelper:
+(float)pointsToMeterRatio;

// returns the pixels-to-meter ratio scaled to the device's pixel size
+(float)pixelsToMeterRatio;

+(float)directionMultipler;

// converts a point coordinate to Box2D meters 
+(b2Vec2)b2Vec2FromPoint:(CGPoint)point;

// converts a size to Box2D meters 
+(b2Vec2)b2Vec2FromSize:(CGSize)size;

// converts a box2d position to point coordinates 
+(CGPoint)pointFromb2Vec2:(b2Vec2)vec;

// returns the location in Box2D way
+(b2Vec2)locationInWorld:(CGPoint)location;

+(b2Vec2)locationInWorldFromTouch:(UITouch *)touch;

+(CGPoint)locationFromTouch:(UITouch *)touch;

+(b2Body *)getTouchedBody:(b2World *)w
                    point:(b2Vec2)p;

+(bool)checkIfTouchedBody:(b2World *)w
                    point:(b2Vec2)p
                     body:(b2Body*)b;

+(CGPoint)pointRandomWithinUnitsRect:(UnitsRect)ur;
+(b2Vec2)b2Vec2RandomWithinUnitsRect:(UnitsRect)ur;

+(float)deviceWidthRatio;
+(float)deviceHeightRatio;

+(float)pixelsToMove;

+(b2Vec2)actorb2Vec2Position:(UnitsPoint)up
                     fromTop:(bool)fromTop
               unitsFromEdge:(float)unitsFromEdge
                unitsYOffset:(float)unitsYOffset;


@end
