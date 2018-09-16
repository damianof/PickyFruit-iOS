//
//  ScrollingHills.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/29/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ScrollingHills.h"
#import "CCLayerWithWorld.h"
#import "GameManager.h"

@implementation ScrollingHills

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
    _pixelsToMeterRatio = [DevicePositionHelper pixelsToMeterRatio];
    _speed = speed;
    
    _lastSectionY = 0.0f;
    
    _numberOfBodies = 60;
    float unitsBodyWidth = (_unitsScreenRect.size.width / _numberOfBodies);
    _numberOfBodies+=2;
    _bodyWidth = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(unitsBodyWidth, 0)].x;
    
    if ((self = [super init])) 
    {
        [self generateBodies];
        [self scheduleUpdate];
    }
    return self;
}

-(b2Body*)createBodyWithVertices:(b2Vec2[])v
                     numVertices:(int)nv
                  b2Vec2Position:(b2Vec2)b2p
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(b2p.x, b2p.y);
    
    b2PolygonShape shape;
    shape.Set(v, nv); 
    //shape.SetAsBox(.5f, .5f);//These are mid points for our 1m box
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 1.0f;
    fixtureDef.restitution = 0.5f;            
    // categoryBits and maskBits
    //fixtureDef->filter.categoryBits = self.collisionType;
    //fixtureDef->filter.maskBits = self.maskBits;
    
    b2Body *body = _layer.world->CreateBody(&bodyDef);
    body->CreateFixture(&fixtureDef);
    return body;
}

-(b2Vec2)findCentroid:(b2Vec2[])hillVector
                count:(int)count
{
    b2Vec2 retVal = b2Vec2(0,0);
    float area = 0.0f;
    float p1X = 0.0f;
    float p1Y = 0.0f;
    float inv3 = 1.0f/3.0f;
    
    for (int i = 0; i < count; ++i) 
    {
        b2Vec2 p2 = hillVector[i];
        b2Vec2 p3 = i + 
            1 < count 
            ? hillVector[int(i+1)] 
            : hillVector[0];
        
        float e1X = p2.x-p1X;
        float e1Y = p2.y-p1Y;
        float e2X = p3.x-p1X;
        float e2Y = p3.y-p1Y;
        
        float D = (e1X * e2Y - e1Y * e2X);
        float triangleArea = 0.5*D;
        area += triangleArea;
        retVal.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
        retVal.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
    }
    retVal.x*=1.0/area;
    retVal.y*=1.0/area;
    return retVal;
}

-(void)drawHills:(int)numberOfHills
       pixelStep:(int)pixelStep
{
    float hillStartY = 140 + arc4random()*200;
    float hillWidth = [DevicePositionHelper screenRect].size.width / numberOfHills;
    float hillSliceWidth = hillWidth / pixelStep;
    float worldScale = 1;
    
    //std::vector<b2Vec2> hillVector;
    
    
    b2Vec2 pointA;
    b2Vec2 pointB;
    b2Vec2 pointC;
    b2Vec2 pointD;
    
    b2Vec2 vertices[] = {
        pointA,
        pointB,
        pointC,
        pointD,
    };
    
    for (int i = 0; i < numberOfHills; i++) 
    {
        float randomHeight=arc4random()*100;
        if(i != 0)
        {
            hillStartY -= randomHeight;
        }
        
        for (int j = 0; j < hillSliceWidth; j++) 
        {
            //hillVector = new Vector.<b2Vec2>();
            /*
            hillVector.push_back(b2Vec2((j*pixelStep+hillWidth*i)/worldScale,480/worldScale));
            hillVector.push_back(b2Vec2((j*pixelStep+hillWidth*i)/worldScale,(hillStartY+randomHeight*Math.cos(2*Math.PI/hillSliceWidth*j))/worldScale));
            hillVector.push_back(b2Vec2(((j+1)*pixelStep+hillWidth*i)/worldScale,(hillStartY+randomHeight*Math.cos(2*Math.PI/hillSliceWidth*(j+1)))/worldScale));
            hillVector.push_back(b2Vec2(((j+1)*pixelStep+hillWidth*i)/worldScale,480/worldScale));
            */
            
            float x1 = (j*pixelStep+hillWidth*i) / worldScale;
            float y1 = 480 / worldScale;
            vertices[0].x = x1;
            vertices[0].y = y1;
            
            float x2 = ((j+1)*pixelStep+hillWidth*i) / worldScale;
            vertices[1].x = x2;
            vertices[1].y = y1;
            
            float y2 = y1 + 1;
            vertices[2].x = x2;
            vertices[2].y = y2; //(hillStartY+randomHeight*cos(2*M_PI/hillSliceWidth*(j+1))) / worldScale;
            
            vertices[3].x = x1;
            vertices[3].y = y2; //(hillStartY+randomHeight*cos(2*M_PI/hillSliceWidth*j)) / worldScale;
            
            
            b2Vec2 bodyPosition = [self findCentroid:vertices count:4];
            /*sliceBody.position.Set(bodyPosition.x,bodyPosition.y);
            
            for(int z=0;z<4;z++)
            {
                //hillVector[z].Subtract(bodyPosition);
                hillVector[z] = hillVector[z] - bodyPosition;
            }*/
            
            [self createBodyWithVertices:vertices numVertices:4 b2Vec2Position:bodyPosition];
        }
        hillStartY += randomHeight;
    }
}

-(void)generateBodies 
{
    [self drawHills:2 pixelStep:10];
    
    /*_bodies = [[CCArray alloc] initWithCapacity:82];
    b2BodyDef bd;
    b2PolygonShape shape;
    float gap = 0.05f; // for debugging leave a gap between the lines
    
    for(int i = 0; i < _numberOfBodies;i++)
    {
        //bd.position.Set((_bodyWidth*i), i % 2 == 0 ? _b2Position.y : _b2Position.y+0.0625); // for debugging each section
        bd.position.Set((_bodyWidth*i), _b2Position.y);
        b2Body *body = _layer.world->CreateBody(&bd);
        body->SetType(b2_kinematicBody);
        
        //shape.SetAsBox(_bodyWidth/2, 0.125, b2Vec2(0.5,0), 0);
        shape.SetAsEdge(b2Vec2(0,0), b2Vec2(_bodyWidth-gap,0));
        
        body->CreateFixture(&shape, 0);
        
        [_bodies addObject:[NSValue valueWithPointer:body]];
    }*/
}

- (void) draw 
{
    /*b2Vec2 p1 = b2Vec2(0, _b2Position.y);
    for(int i = 0; i < _numberOfBodies;i++)
    {
        glColor4f(1.0, 0, 0, 1.0); 
        glLineWidth(2.0f);
        
        b2Vec2 p2 = b2Vec2(_bodyWidth*i, _b2Position.y);
        CGPoint ccp1 = ccp(p1.x * _pixelsToMeterRatio, p1.y * _pixelsToMeterRatio);
        CGPoint ccp2 = ccp(p2.x * _pixelsToMeterRatio, p2.y * _pixelsToMeterRatio);
        
        ccDrawLine( ccp1, ccp2 );
        p1 = p2;
    }*/
    
    //[super draw];
    
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
            _lastSectionY = currentLocation.y + 0.1f;
            if((currentLocation.x + _bodyWidth) < _b2Position.x)
            {
                body->SetAwake(false);
                body->SetTransform(b2Vec2(_bodyWidth*(_numberOfBodies-1), _lastSectionY), 0);
            }
            else
            {
                _lastSectionY = currentLocation.y + 0.1f;
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
