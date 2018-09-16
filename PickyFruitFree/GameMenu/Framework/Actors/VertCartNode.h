//
//  VertCartNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GB2ShapeCache.h"
#import "BodyNodeWithSprite.h"
#import "DevicePositionHelper.h"

@class ActorInfo;


@interface VertCartNode : BodyNodeWithSprite 
{
    UnitsBounds _unitsBounds;
    b2Vec2 _bounds;
    float _lastPositionY;
    int _direction;
    
    float _pixelsToMove;
    
    bool _flipping;
    bool _reverting;
    float _currentAngle;
    float _finalAngle;
    float _angleIncrement;
    float _revertIncrement;
    
    int _touchcount;
    bool _hasFruit;
    float _elapsed;
    float _fruitTouchElapsed;
}

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip;

-(void)setUnitsBounds:(UnitsBounds)ub;
-(void)updatePosition;
-(void)performFlip;
-(void)revertFlip:(b2Vec2)p;


@end
