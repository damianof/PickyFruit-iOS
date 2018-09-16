//
//  ActorProtocol.h
//
//  Created by Damiano Fusco on 5/8/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "CCLayerWithWorld.h"
#import "ActorInfo.h"


@protocol ActorProtocol <NSObject>

+(id)createWithLayer:(CCLayerWithWorld*)layer
                info:(ActorInfo*)ai
     initialPosition:(b2Vec2)ip;

-(id)initWithLayer:(CCLayerWithWorld*)layer
              info:(ActorInfo*)ai
   initialPosition:(b2Vec2)ip;

@end
