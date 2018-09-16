//
//  ActorInfo.m
//  GameMenu
//
//  Created by Damiano Fusco on 5/7/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ActorInfo.h"
#import "JointInfo.h"
#import "GDataXMLNode.h"
#import "GameStateXmlHelper.h"


@implementation ActorInfo


@synthesize 
    typeName = _typeName,
    tag = _tag,
    z = _z,
    framesFileName = _framesFileName,
    imageFormat = _imageFormat,
    frameName = _frameName,
    anchorPoint = _anchorPoint,
    unitsPosition = _unitsPosition,
    unitsBounds = _unitsBounds,
    positionFromTop = _positionFromTop,
    angle = _angle,
    verticesFile = _verticesFile,
    makeDynamic = _makeDynamic,
    makeKinematic = _makeKinematic,
    
    collisionType = _collisionType,
    collidesWithTypes = _collidesWithTypes,
    maskBits = _maskBits;


-(b2Vec2)b2AnchorPoint
{
    return b2Vec2(self.anchorPoint.x, self.anchorPoint.y);
}

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
            unitsBounds:(UnitsBounds)ub
{
    return [[[self alloc] initWithTypeName:tn
                                       tag:t
                                         z:z
                            framesFileName:ffn
                               imageFormat:format
                                 frameName:fn 
                               anchorPoint:ap 
                             unitsPosition:up
                           positionFromTop:pft
                                     angle:a
                               unitsBounds:ub] autorelease];
}

+(ActorInfo*)createFruitInfo:(NSString*)fn
                         tag:(int)tagValue
{
    ActorInfo *actorInfo = [[ActorInfo alloc] initWithTypeName:@"FruitNode"
                                                           tag:tagValue
                                                             z:102
                                                framesFileName:kFramesFileFruit32
                                                   imageFormat:kImageFormatPvrCcz
                                                     frameName:fn 
                                                   anchorPoint:cgzero 
                                                 unitsPosition:cgzero 
                                               positionFromTop:false   
                                                         angle:0
                                                   unitsBounds:ubzero];
    
    //actorInfo.verticesFile = @"Fruit32Vertices.plist";
    actorInfo.makeDynamic = false;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = CollisionTypeFruit;
    actorInfo.collidesWithTypes = CollisionTypeZERO;
        //CollisionTypeHail 
        //& CollisionTypeObstacleHCart;
    actorInfo.maskBits = CollisionTypeALL
        & ~CollisionTypeWorldLeft
        & ~CollisionTypeWorldRight;
    return actorInfo;
}

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
          unitsBounds:(UnitsBounds)ub
{
    if ((self = [super init])) 
    {
        self.typeName = tn,
        self.framesFileName = ffn,
        self.imageFormat = format,
        self.frameName = fn,
        
        self.tag = t,
        self.z = z,
        self.anchorPoint = ap,
        self.unitsPosition = up,
        self.positionFromTop = pft,
        self.angle = a,
        self.unitsBounds = ub;
    }    
    return self; 
}


-(ActorInfo*)cloneWithNewTag:(int)tag
{
    ActorInfo *actorInfo = [[ActorInfo alloc] initWithTypeName:self.typeName
                                                           tag:tag
                                                             z:self.z
                                                framesFileName:self.framesFileName
                                                   imageFormat:self.imageFormat
                                                     frameName:self.frameName 
                                                   anchorPoint:self.anchorPoint 
                                                 unitsPosition:self.unitsPosition 
                                               positionFromTop:self.positionFromTop   
                                                         angle:self.angle
                                                   unitsBounds:self.unitsBounds];
    
    actorInfo.verticesFile = self.verticesFile;
    actorInfo.makeDynamic = self.makeDynamic;
    actorInfo.makeKinematic = self.makeKinematic;
    actorInfo.collisionType = self.collisionType;
    actorInfo.collidesWithTypes = self.collidesWithTypes;
    actorInfo.maskBits = self.maskBits;
    return actorInfo;
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    //CCLOG(@"ActorInfo dealloc: _framesFileName %@ Retain Count %d", _framesFileName, _framesFileName.retainCount);
    
    [_framesFileName release];
    [_imageFormat release];
    [_typeName release];
    [_frameName release];
    [_verticesFile release];
    
    _framesFileName = nil;
    _imageFormat = nil;
    _typeName = nil;
    _frameName = nil;
    _verticesFile = nil;
    
    [super dealloc];
}


@end
