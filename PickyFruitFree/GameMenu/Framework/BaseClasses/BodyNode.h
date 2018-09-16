//
//  BodyNode.h
//
//  Created by Damiano Fusco on 4/1/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"


@interface BodyNode : CCNode 
{
    b2World     *_world;
    b2Body      *_groundBody;
    
    b2Body      *_body;
    b2BodyType  _bodyType;
    bool        _active;
    b2Vec2      _initialPosition;
    bool        _fixedRotation;
    
    CGPoint     _initialAnchorPoint;
    
    bool        _isAwake;
    bool        _jointsDestroyed;
    bool        _fixturesCreated;
    bool        _fixturesReplaced;
    bool        _collisionCheckOn;
    
    bool        _needsJointsDestroyed;
    
    b2Vec2 _screenB2Vec2Size;
    float _offsetX1ForOutsideScreen;
    float _offsetY1ForOutsideScreen;
    float _offsetX2ForOutsideScreen;
    float _offsetY2ForOutsideScreen;
    
    // for caching mouse joint to improve performance:
    b2MouseJoint    *_currentMouseJoint;
    
    // for collision detection and filtering
    uint16 _collisionType, _collidesWithTypes, _maskBits;
    
    NSString *_typeName;
}

//@property (nonatomic, readonly) b2World *world;
@property (nonatomic, readonly) NSString *typeName;

@property (nonatomic, readonly) b2Body *groundBody;
@property (nonatomic, readonly) b2Body *body;
@property (nonatomic, readonly) bool isAwake;
@property (nonatomic, readonly) b2BodyType bodyType;
@property (nonatomic, readonly) b2Vec2 initialPosition;
@property (nonatomic, readonly) uint16 outsideScreenValue;
@property (nonatomic, readonly) bool isOutsideScreen;

@property (nonatomic, readwrite) float offsetX1ForOutsideScreen;
@property (nonatomic, readwrite) float offsetY1ForOutsideScreen;
@property (nonatomic, readwrite) float offsetX2ForOutsideScreen;
@property (nonatomic, readwrite) float offsetY2ForOutsideScreen;

@property (nonatomic, readwrite) uint16 collisionType;
@property (nonatomic, readwrite) uint16 collidesWithTypes;
@property (nonatomic, readwrite) uint16 maskBits;

@property (nonatomic, readwrite) bool jointsDestroyed;
@property (nonatomic, readwrite) bool fixturesCreated;
@property (nonatomic, readwrite) bool fixturesReplaced;
@property (nonatomic, readwrite) bool collisionCheckOn;

@property (nonatomic, readwrite) bool needsJointsDestroyed;

-(void)setTypeName:(NSString*)tn;
-(void)setInitialPosition:(b2Vec2)p;

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t;

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t  
          bodyType:(b2BodyType)bt;

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t
          bodyType:(b2BodyType)bt
            active:(bool)a;

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb 
                 tag:(int)t
            bodyType:(b2BodyType)bt
              active:(bool)a
            position:(b2Vec2)ip;

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb 
                 tag:(int)t
            bodyType:(b2BodyType)bt
              active:(bool)a
            position:(b2Vec2)p
       fixedRotation:(bool)fr;

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb 
               tag:(int)t
          bodyType:(b2BodyType)bt
            active:(bool)a
          position:(b2Vec2)p
     fixedRotation:(bool)fr;

// receive message form UI through CCLayerWithWorld
-(void)receiveMessage:(NSString *)m
           floatValue:(float)fv
          stringValue:(NSString *)sv;

//
-(b2Vec2)getBodyPosition;
-(CGPoint)getBodyPositionInPoints;
-(float)getBodyAngle;
-(float)getBodyAngleInDegrees;
-(void)activateBody;
-(void)deactivateBody;

-(void)awakeBody:(bool)a;
-(void)makeDynamic;
-(void)makeKinematic;
-(void)makeStatic;

-(BodyNode *)getTouchedBodyNode:(UITouch *)touch;

// private:
-(void)createBody;
-(void)destroyBody;
-(void)destroyJoints;

@end
