//
//  BodyNodeWithSprite.h
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BodyNode.h"
//#import "cocos2d.h"
#import "Box2D.h"

@class BodyNode;
@class CCLayerWithWorld;


@interface BodyNodeWithSprite : BodyNode 
{
    CCLayerWithWorld *_layer; // weak reference
    
    NSString *_spriteFrameName;
    CCSprite *_sprite;
    b2Vec2 _spriteSizeInMeters;
    
    b2FixtureDef *_fixtureDef;
    b2Fixture *_fixture;
    b2Shape *_shape;
    
    b2FixtureDef *_newFixtureDef;
    b2Shape *_newShape;

    bool _impulseAppliedAt;
}

@property (nonatomic, readonly) CCSprite  *sprite;
@property (nonatomic, readonly) b2Vec2 spriteSizeInMeters;
@property (nonatomic, readonly) bool impulseAppliedAt;


+(id)createWithLayer:(CCLayerWithWorld*)layer
         anchorPoint:(CGPoint)ap
            position:(b2Vec2)ip
              sprite:(CCSprite *)s
                   z:(int)z   
     spriteFrameName:(NSString *)sfn 
                 tag:(int)t
              center:(b2Vec2)c
               angle:(float)a;


+(id)createWithLayer:(CCLayerWithWorld*)layer
         anchorPoint:(CGPoint)ap
            position:(b2Vec2)ip 
              sprite:(CCSprite *)s
                   z:(int)z   
     spriteFrameName:(NSString *)sfn 
                 tag:(int)t
          fixtureDef:(b2FixtureDef *)fd
               shape:(b2Shape *)sh;

-(id)initWithLayer:(CCLayerWithWorld*)layer
       anchorPoint:(CGPoint)ap
          position:(b2Vec2)ip 
            sprite:(CCSprite *)s
                 z:(int)z  
   spriteFrameName:(NSString *)sfn
               tag:(int)t
        fixtureDef:(b2FixtureDef *)fd
             shape:(b2Shape *)sh;


-(void)syncWithBody;
-(void)syncSize;

-(void)onOverlapBody:(BodyNodeWithSprite *)bn
                fixt:(b2Fixture*)fixt;
-(void)onSeparateBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt;
-(void)onCollideBody:(BodyNodeWithSprite *)bn 
                fixt:(b2Fixture*)fixt
           withForce:(float)f 
   withFrictionForce:(float)ff;

//-(bool)isWithinOtherSprite:(CCSprite *)otherSprite;
-(bool)isWithinRect:(CGRect)rect;
-(bool)isTouchOnSprite:(UITouch*)touch;

// shoud be private:
-(void)setSpriteSize:(CCSprite *)s;
-(void)removeSprite;
-(void)setNewFixtureDef:(b2FixtureDef *)fd
                  shape:(b2Shape *)sh;
-(void)createFixture;
-(void)destroyFixture;
-(void)replaceFixture;

-(void)applyImpulse:(int)x 
              delta:(float)dt;

@end
