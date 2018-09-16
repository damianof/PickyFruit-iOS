//
//  ActorInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevicePositionHelper.h"


@class JointInfo;
@class GDataXMLElement;


@interface ActorInfo : NSObject 
{
    NSString *_typeName; // "GenericNode" or "TruckNode" etc 
    
    NSString *_framesFileName; // "xyz.plist" 
    NSString *_imageFormat; // "png" or "pvr.ccz"

    NSString * _frameName; // "GrayClouds" 
    CGPoint _anchorPoint;
    UnitsPoint _unitsPosition;
    float _angle;
    UnitsBounds _unitsBounds;
    bool _positionFromTop; 
    int _z;
    int _tag;
    
    // body stuff
    NSString *_verticesFile;
    bool _makeDynamic;
    bool _makeKinematic;
    
    uint16 _collisionType, _collidesWithTypes, _maskBits;
}

@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *framesFileName;
@property (nonatomic, copy) NSString *imageFormat;
@property (nonatomic, copy) NSString *frameName;
@property (nonatomic, copy) NSString *verticesFile;

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) UnitsPoint unitsPosition;
@property (nonatomic, assign) UnitsBounds unitsBounds;
@property (nonatomic, assign) bool positionFromTop;
@property (nonatomic, assign) float angle;
@property (nonatomic, assign) int z;
@property (nonatomic, readwrite) int tag;

@property (nonatomic, assign) bool makeDynamic;
@property (nonatomic, assign) bool makeKinematic;

@property (nonatomic, assign) uint16 collisionType;
@property (nonatomic, assign) uint16 collidesWithTypes;
@property (nonatomic, assign) uint16 maskBits;

@property (nonatomic, readonly) b2Vec2 b2AnchorPoint;


+(id)createWithTypeName:(NSString *)tn
                    tag:(int)t
                      z:(int)z
         framesFileName:(NSString *)ffn
            imageFormat:(NSString *)format
              frameName:(NSString *)fn 
            anchorPoint:(CGPoint)ap 
          unitsPosition:(UnitsPoint)up
        positionFromTop:(bool)pft
                  angle:(float)a
            unitsBounds:(UnitsBounds)ub;

+(ActorInfo*)createFruitInfo:(NSString*)fn
                         tag:(int)tagValue;


-(id)initWithTypeName:(NSString *)tn
                  tag:(int)t
                    z:(int)z
       framesFileName:(NSString *)ffn
          imageFormat:(NSString *)format
            frameName:(NSString *)fn 
          anchorPoint:(CGPoint)ap 
        unitsPosition:(UnitsPoint)up
      positionFromTop:(bool)pft
                angle:(float)a
          unitsBounds:(UnitsBounds)ub;

-(ActorInfo*)cloneWithNewTag:(int)tag;


@end
