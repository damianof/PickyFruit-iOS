//
//  ScrollingGround.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/29/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ScrollingGround.h"
#import "CCLayerWithWorld.h"
#import "GameManager.h"

@implementation ScrollingGround

@synthesize speed = _speed;

+(id)createWithLayer:(CCLayerWithWorld*)layer
       unitsPosition:(UnitsPoint)unitsPosition
               speed:(float)speed
{
    return [[[self alloc] initWithLayer:layer
                          unitsPosition:unitsPosition
                                  speed:speed] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
     unitsPosition:(UnitsPoint)unitsPosition
             speed:(float)speed
{
    _layer = layer;
    _unitsPosition = unitsPosition;
    _b2Position = [DevicePositionHelper b2Vec2FromUnitsPoint:_unitsPosition];
    _unitsScreenRect = [DevicePositionHelper screenUnitsRect];
    _speed = speed;
    
    _numberOfBodies = 5;
    int unitsBodyWidth = _unitsScreenRect.size.width / _numberOfBodies;
    _numberOfBodies+=2;
    _bodyWidth = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(unitsBodyWidth, 0)].x;
    
    if ((self = [super init])) 
    {
        [self generateBodies];
        [self scheduleUpdate];
    }
    return self;
}

-(void)generateBodies 
{
    _bodies = [[CCArray alloc] initWithCapacity:7];
    b2BodyDef bd;
    b2EdgeShape shape;
    
    for(int i = 0; i < _numberOfBodies;i++)
    {
        //bd.position.Set((_bodyWidth*i), i % 2 == 0 ? _b2Position.y : _b2Position.y+0.0625); // for debugging each section
        bd.position.Set((_bodyWidth*i), _b2Position.y);
        b2Body *body = _layer.world->CreateBody(&bd);
        body->SetType(b2_kinematicBody);
        
        //shape.SetAsBox(_bodyWidth/2, 0.125, b2Vec2(0.5,0), 0);
        shape.Set(b2Vec2(0,0), b2Vec2(_bodyWidth,0));
        
        body->CreateFixture(&shape, 0);
        
        [_bodies addObject:[NSValue valueWithPointer:body]];
    }
}

- (void) draw 
{
    /*glBindTexture(GL_TEXTURE_2D, _stripes.texture.name);
     glDisableClientState(GL_COLOR_ARRAY);
     
     glColor4f(1, 1, 1, 1);
     glVertexPointer(2, GL_FLOAT, 0, _hillVertices);
     glTexCoordPointer(2, GL_FLOAT, 0, _hillTexCoords);
     glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nHillVertices);*/
    
    /*for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {
     glColor4f(1.0, 0, 0, 1.0); 
     ccDrawLine(_hillKeyPoints[i-1], _hillKeyPoints[i]);     
     
     glColor4f(1.0, 1.0, 1.0, 1.0);
     
     CGPoint p0 = _hillKeyPoints[i-1];
     CGPoint p1 = _hillKeyPoints[i];
     int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
     float dx = (p1.x - p0.x) / hSegments;
     float da = M_PI / hSegments;
     float ymid = (p0.y + p1.y) / 2;
     float ampl = (p0.y - p1.y) / 2;
     
     CGPoint pt0, pt1;
     pt0 = p0;
     for (int j = 0; j < hSegments+1; ++j) {
     
     pt1.x = p0.x + j*dx;
     pt1.y = ymid + ampl * cosf(da*j);
     
     ccDrawLine(pt0, pt1);
     
     pt0 = pt1;
     
     }
     }*/
}

- (void)update:(ccTime)dt 
{   
    if([GameManager sharedInstance].running)
    {
        int direction = -1;
        b2Vec2 b2DirectionToTravel = b2Vec2((direction * self.speed), 0);
        b2DirectionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
        
        for (NSValue *bodyValue in _bodies)
        {
            b2Body *body = (b2Body*)[bodyValue pointerValue];
            b2Vec2 currentLocation = body->GetPosition();
            
            if((currentLocation.x + _bodyWidth) < _b2Position.x)
            {
                body->SetAwake(false);
                body->SetTransform(b2Vec2(_bodyWidth*(_numberOfBodies-1), currentLocation.y), 0);
            }
            else
            {
                body->SetLinearVelocity(b2DirectionToTravel);
            }
        }
    }
}

- (void)dealloc 
{
    CCLOG(@"ScrollingGround: dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [_bodies release];
    _bodies = nil;
    _layer = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

@end
