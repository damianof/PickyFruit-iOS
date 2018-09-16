//
//  RotatingCartNode.h
//  GameMenu
//
//  Created by Damiano Fusco on 5/9/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GB2ShapeCache.h"
#import "BodyNodeWithSprite.h"

@class ActorInfo;


@interface RotatingCartNode : BodyNodeWithSprite 
{
    int _direction;
    float _pixelsToMove;
    
    float _currentAngle;
    float _finalAngle;
    float _angleIncrement;
    
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


-(void)updatePosition;


@end
