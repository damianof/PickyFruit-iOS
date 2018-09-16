//
//  DevicePositionHelper.mm
//
//  Created by Damiano Fusco on 4/4/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
#import "DevicePositionHelper.h"
#import "QueryCallback.h"

// box2d constants:
const float kPointsToMeterRatio = 32.0f;
static float _pixelsToMeterRatio;
static float _directionMultipler;

static CGPoint _gradientVector = cgzero;

// screen constants:
static CGRect screenRectInstance;
static CGPoint screenCenterInstance;

// Units stuff (I'm using a Units system where each unit is 8 points in size, scaled based on device):
const int kPointsPerUnit = 8;
static int numberOfUnitsByDevice;
static int unitInPoints; // it will be always 8 (kPointsPerUnit)
static int unitInPixels; // it will be either 8 (low res devices) or 16 (high-res devices)

CG_INLINE UnitsPoint
upp(float x, float y)
{
    UnitsPoint p; p.x = x; p.y = y; return p;
}

// Units inline functions:
UnitsPoint UnitsPointMake(float x, float y)
{
    UnitsPoint p; p.x = x; p.y = y; return p;
};

UnitsSize UnitsSizeMake(float width, float height)
{
    UnitsSize us; us.width = width; us.height = height; return us;
};

UnitsRect UnitsRectMake(float x, float y, float width, float height)
{
    UnitsRect r; r.origin = UnitsPointMake(x, y); r.size = UnitsSizeMake(width, height); return r;
};

UnitsRect UnitsRectMake(UnitsPoint origin, UnitsSize size)
{
    UnitsRect r; r.origin = origin; r.size = size; return r;
};

UnitsBounds UnitsBoundsMake(float upper, float lower)
{
    UnitsBounds p; p.upper = upper; p.lower = lower; return p;
};


UnitsPoint UnitsPointFromString(NSString *strValue)
{
    // go through CG halper method to convert form string
    CGPoint tmp = CGPointFromString(strValue);
    UnitsPoint value = UnitsPointMake(tmp.x, tmp.y);
    return value;
};

UnitsSize UnitsSizeFromString(NSString *strValue)
{
    // go through CG halper method to convert form string
    CGSize tmp = CGSizeFromString(strValue);
    UnitsSize value = UnitsSizeMake(tmp.width, tmp.height);
    return value;
};

UnitsRect UnitsRectFromString(NSString *strValue)
{
    // go through CG halper method to convert form string
    CGRect tmp = CGRectFromString(strValue);
    UnitsPoint origin = UnitsPointMake(tmp.origin.x, tmp.origin.y);
    UnitsSize size = UnitsSizeMake(tmp.size.width, tmp.size.height);
    UnitsRect value = UnitsRectMake(origin, size);
    return value;
};

UnitsBounds UnitsBoundsFromString(NSString *strValue)
{
    // go through CG halper method to convert form string
    CGPoint tmp = CGPointFromString(strValue);
    UnitsBounds value = UnitsBoundsMake(tmp.x, tmp.y);
    return value;
};

@implementation DevicePositionHelper

+(CGPoint)gradientVector
{
    if(_gradientVector.x == 0 
       && _gradientVector.y == 0)
    {
        _gradientVector = ccp([self screenRect].size.width * kFloat0Point5, [self screenRect].size.height * kFloat0Point5);
    }
    
    return _gradientVector;
}

+(float)scaleFactor
{
    return CC_CONTENT_SCALE_FACTOR();
}

#pragma mark Box2D

// returning correctly scaled pointsToMeter and pixelsToMeter ratios based on device
+(float) pointsToMeterRatio
{
	return (kPointsToMeterRatio);
}

+(float)pixelsToMeterRatio
{
    if(_pixelsToMeterRatio == kFloat0)
    {
        _pixelsToMeterRatio = ([DevicePositionHelper scaleFactor] * kPointsToMeterRatio);
    }
    
    return _pixelsToMeterRatio;
}

+(float)directionMultipler
{
    if(_directionMultipler == kFloat0)
    {
        // 60 frames per second * PTM_RATIO
        _directionMultipler = 60.0f / [DevicePositionHelper pixelsToMeterRatio];
    }
    return _directionMultipler;
}

+(b2Vec2) b2Vec2FromPoint:(CGPoint)point
{
	return b2Vec2(point.x / kPointsToMeterRatio, point.y / kPointsToMeterRatio);
}

+(b2Vec2) b2Vec2FromSize:(CGSize)size
{
	return b2Vec2(size.width / kPointsToMeterRatio, size.height / kPointsToMeterRatio);
}

+(b2Vec2)screenB2Vec2Size
{
    CGSize size = [self screenRect].size;
    b2Vec2 b2Vec2Size = [DevicePositionHelper b2Vec2FromSize:size];
    return b2Vec2Size;
}

+(b2Vec2)screenB2Vec2Center
{
    CGPoint screenCenter = [self screenCenter];
    b2Vec2 b2Vec2Center = [self b2Vec2FromPoint:screenCenter];
    return b2Vec2Center;
}

//+(b2Vec2) b2Vec2FromPixels:(CGPoint)point
//{
//    return b2Vec2(point.x / [Box2DHelper pixelsToMeterRatio], point.y / [Box2DHelper pixelsToMeterRatio]);
//}

+(CGPoint) pointFromb2Vec2:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), kPointsToMeterRatio);
}

//+(CGPoint) pixelsFromb2Vec2:(b2Vec2)vec
//{
//	return ccpMult(CGPointMake(vec.x, vec.y), [Box2DHelper pixelsToMeterRatio]);
//}

+(b2Vec2)locationInWorld:(CGPoint)point
{
    CGPoint glLocation = [[CCDirector sharedDirector] convertToGL:point];
    b2Vec2 locationWorld = [self b2Vec2FromPoint:glLocation];
    return locationWorld;
}

+(b2Vec2)locationInWorldFromTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:[touch view]];
    return [self locationInWorld:location];
}

+(CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

#pragma mark Screen

+(CGRect)screenRect
{
    if(CGRectIsEmpty(screenRectInstance))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        screenRectInstance = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }
    return screenRectInstance;
}

+(CGPoint)screenCenter
{
    if(CGPointEqualToPoint(screenCenterInstance, CGPointZero))
    {
        CGSize halfScreenSize = CGSizeMultiply([self screenRect].size, 0.5f);
        //CGSize screenSize = [self screenRect].size * kTwoInverted;
        screenCenterInstance = CGPointMake(halfScreenSize.width, halfScreenSize.height);
    }
    return screenCenterInstance;
}

+(UnitsRect)screenUnitsRect
{
    CGRect screenRect = [DevicePositionHelper screenRect];
    UnitsPoint screenUnitsPoint = [DevicePositionHelper unitsPointFromPoint:screenRect.origin];
    UnitsSize screenUnitsSize = [DevicePositionHelper unitsSizeFromSize:screenRect.size];
    
    return UnitsRectMake(screenUnitsPoint, screenUnitsSize);
}

+(UnitsPoint)screenUnitsCenter
{
    CGPoint screenCenter = [self screenCenter];
    UnitsPoint unitsPoint = [self unitsPointFromPoint:screenCenter];
    return unitsPoint;
}

#pragma mark Units
+(int)numberOfUnitsByDevice
{
    if(numberOfUnitsByDevice == 0)
    {
        CGSize screenSize = [self screenRect].size;
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPhone) 
        {
            numberOfUnitsByDevice = screenSize.height / kPointsPerUnit;
        }        else if (idiom == UIUserInterfaceIdiomPad)
        {
            // use same as iphone retina
            numberOfUnitsByDevice = screenSize.height / (kPointsPerUnit * 2);
        }
        else
        {
            NSAssert(idiom == UIUserInterfaceIdiomPhone, @"DevicePositionHelper numberOfUnitsByDevice: Unknown device idiom.");
        }
    }
    return numberOfUnitsByDevice;
}

+(float)unitInPoints
{
    if(unitInPoints == 0)
    {
        // dimension in points of single unit
        CGSize screenSize = [self screenRect].size;
        unitInPoints = screenSize.height / [self numberOfUnitsByDevice];
    }
    return unitInPoints;
}

+(float)unitInPixels
{
    if(unitInPixels == 0)
    {
        // dimension in pixels of single unit
        unitInPixels = [self unitInPoints] * [DevicePositionHelper scaleFactor];
    }
    return unitInPixels;
}

+(float)unitInBox2D
{
    float cg = [self cgFromUnits:1];
    b2Vec2 b2v = [self b2Vec2FromPoint:CGPointMake(cg, 0)];
    return b2v.x;
}

+(float)cgFromUnits:(float)u
{
    int unit = [self unitInPoints];
    float retVal = u * unit;
    return retVal;
}

+(CGPoint)pointFromUnitsPoint:(UnitsPoint)up
{
    int unit = [self unitInPoints];
    
    float pointsX = up.x * unit;
    float pointsY = up.y * unit;
    
    CGPoint retVal = CGPointMake(pointsX, pointsY);
    return retVal;
}

+(UnitsPoint)unitsPointFromPoint:(CGPoint)p
{
    int unit = [self unitInPoints];
    
    float unitsX = p.x / unit;
    float unitsY = p.y / unit;
    
    UnitsPoint retVal = UnitsPointMake(unitsX, unitsY);
    return retVal;
}

+(CGSize)sizeFromUnitsSize:(UnitsSize)us
{
    int unit = [self unitInPoints];
    
    float pointsW = us.width * unit;
    float pointsH = us.height * unit;
    
    CGSize retVal = CGSizeMake(pointsW, pointsH);
    return retVal;
}

+(UnitsSize)unitsSizeFromSize:(CGSize)s
{
    int unit = [self unitInPoints];
    
    float unitsW = s.width / unit;
    float unitsH = s.height / unit;
    
    UnitsSize retVal = UnitsSizeMake(unitsW, unitsH);
    return retVal;
}

+(CGRect)rectFromUnitsRect:(UnitsRect)ur
{
    CGPoint point = [self pointFromUnitsPoint:ur.origin];
    CGSize size = [self sizeFromUnitsSize:ur.size];
    CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
    return rect;
}

+(UnitsRect)unitsRectFromRect:(CGRect)r
{
    UnitsPoint up = [self unitsPointFromPoint:r.origin];
    UnitsSize us = [self unitsSizeFromSize:r.size];
    UnitsRect ur = UnitsRectMake(up.x, up.y, us.width, us.height);
    return ur;
}

+(CGPoint)pointFromUnitsBounds:(UnitsBounds)ub
{
    int unit = [self unitInPoints];
    
    float pointsX = ub.upper * unit;
    float pointsY = ub.lower * unit;
    
    CGPoint retVal = CGPointMake(pointsX, pointsY);
    return retVal;
}

+(UnitsBounds)unitsBoundsFromPoint:(CGPoint)p
{
    int unit = [self unitInPoints];
    
    float unitsUpper = p.x / unit;
    float unitsLower = p.y / unit;
    
    UnitsBounds retVal = UnitsBoundsMake(unitsUpper, unitsLower);
    return retVal;
}

+(b2Vec2)b2Vec2FromUnitsPoint:(UnitsPoint)up
{
    CGPoint point = [self pointFromUnitsPoint:up];
    b2Vec2 vec = [self b2Vec2FromPoint:point];
    return vec;
}

+(b2Vec2)b2Vec2FromUnitsSize:(UnitsSize)us
{
    CGSize size = [self sizeFromUnitsSize:us];
    b2Vec2 vec = [self b2Vec2FromSize:size];
    return vec;  
}

+(b2Vec2)b2Vec2FromUnitsBounds:(UnitsBounds)ub
{
    CGPoint point = [self pointFromUnitsBounds:ub];
    b2Vec2 vec = [self b2Vec2FromPoint:point];
    return vec;
}


+(b2Body *)getTouchedBody:(b2World *)w
                    point:(b2Vec2)p
{
    //b2Vec2 p = [Box2DHelper locationInWorldFromTouch:t];
    
    QueryCallback callback(p);
    b2AABB aabb;
    b2Vec2 d;
    d.Set(0.005f, 0.005f);
    aabb.lowerBound = p - d;
    aabb.upperBound = p + d;
    
    w->QueryAABB(&callback, aabb);
    
    b2Body *retVal = callback.body; 
    return retVal;
}

+(bool)checkIfTouchedBody:(b2World *)w
                    point:(b2Vec2)p
                     body:(b2Body*)b
{
    QueryCallback callback(p);
    b2AABB aabb;
    b2Vec2 d;
    d.Set(0.005f, 0.005f);
    aabb.lowerBound = p - d;
    aabb.upperBound = p + d;
    
    w->QueryAABB(&callback, aabb);
    
    b2Body *tb = callback.body;
    bool retVal = tb == b;
    return retVal;
}

+(CGPoint)pointRandomWithinUnitsRect:(UnitsRect)ur
{
    int startx = ur.origin.x;
    int endx = ur.origin.x+ur.size.width;
    int starty = ur.origin.y; 
    int endy = ur.origin.y+ur.size.height; 
    
    int x = [MathHelper randomNumberBetween:startx andMax:endx];
    int y = [MathHelper randomNumberBetween:starty andMax:endy];
    
    CGPoint position = [DevicePositionHelper pointFromUnitsPoint:UnitsPointMake(x,y)];
    return position;
}

+(b2Vec2)b2Vec2RandomWithinUnitsRect:(UnitsRect)ur
{
    int startx = ur.origin.x;
    int endx = ur.origin.x+ur.size.width;
    int starty = ur.origin.y; 
    int endy = ur.origin.y+ur.size.height; 
    
    int x = [MathHelper randomNumberBetween:startx andMax:endx];
    int y = [MathHelper randomNumberBetween:starty andMax:endy];
    
    b2Vec2 b2Vec2position = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(x,y)];
    return b2Vec2position;
}

+(float)deviceWidthRatio
{
    // assumes landscape mode only
    float ratio = 1.0f;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        ratio = [self screenRect].size.width / 960.0f; // around 1.07
    }
    return ratio; 
}

+(float)deviceHeightRatio
{
    // assumes landscape mode only
    float ratio = 1.0f;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        ratio = [self screenRect].size.height / 640.0f; // around 1.2
    }
    return ratio; 
}

+(float)pixelsToMove
{
    float screenWidth = [DevicePositionHelper screenRect].size.width;
    float pixelsToMove = (screenWidth / 320) * [DevicePositionHelper scaleFactor];
    return pixelsToMove;
}

+(b2Vec2)actorb2Vec2Position:(UnitsPoint)up
                     fromTop:(bool)fromTop
               unitsFromEdge:(float)unitsFromEdge
                unitsYOffset:(float)unitsYOffset
{
    UnitsSize sus = [DevicePositionHelper screenUnitsRect].size;
    if(fromTop)
    {
        up = UnitsPointMake(up.x + unitsFromEdge, 
                            sus.height-up.y-unitsFromEdge);
    }
    else
    {
        up = UnitsPointMake(up.x + unitsFromEdge, 
                            up.y + unitsYOffset);
    }
    b2Vec2 p = [DevicePositionHelper b2Vec2FromUnitsPoint:up];
    return p;
}

@end
