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
    _speed = speed;
    
    _numberOfBodies = 30;
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
-(b2Body*)createBodyWithVertices:(b2Vec2[])v
                     numVertices:(int)nv
                  b2Vec2Position:(b2Vec2)b2p
{
    b2BodyDef bodyDef;
    //bodyDef.type = b2_staticBody;
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

-(void)drawHills:(int)numberOfHills
       pixelStep:(int)pixelStep
{
    float hillStartY = 0; //140 + arc4random()*200;
    float hillWidth = [DevicePositionHelper screenRect].size.width / numberOfHills;
    float hillSliceWidth = hillWidth / pixelStep;
    float worldScale = [DevicePositionHelper pixelsToMeterRatio];
    
    //std::vector<b2Vec2> hillVector;
    
    b2Vec2 pointA;
    b2Vec2 pointB;
    b2Vec2 pointC;
    b2Vec2 pointD;
    
    /*b2Vec2 pointA = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(5,5)]; //[Box2DHelper pointToMeters:CGPointMake(50,50)];
    b2Vec2 pointB = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(10,5)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,50)];
    b2Vec2 pointC = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(10,7)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,64)];
    b2Vec2 pointD = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(5,9)]; //[Box2DHelper pointToMeters:CGPointMake(50,64)];*/
    

    /*int randomHeight=[MathHelper randomNumberBetween:6 andMax:12];;
    hillStartY = 0.0f;
    //float y2 = hillStartY + (randomHeight*cos(2*M_PI/hillSliceWidth));
    //float y2b = hillStartY + (randomHeight*cos(2*M_PI/hillSliceWidth*0.5));
    float y2 = hillStartY + randomHeight;
    randomHeight=[MathHelper randomNumberBetween:6 andMax:12];;
    float y2b = hillStartY + randomHeight;
    b2Vec2 vertices[] = {
        b2Vec2(10.0f / worldScale, hillStartY / worldScale),
        b2Vec2(30.0f / worldScale, hillStartY / worldScale),
        b2Vec2(30.0f / worldScale, y2 / worldScale),
        b2Vec2(10.0f / worldScale, y2b / worldScale)
    };
    
    b2Vec2 bodyPosition = b2Vec2(2,4);
    [self createBodyWithVertices:vertices numVertices:4 b2Vec2Position:bodyPosition];
    */
    
    int i = 0;
    float x1 = 10.0 + (i*pixelStep);
    float x2 = x1 + hillSliceWidth;
    float y2 = hillStartY + [MathHelper randomNumberBetween:6 andMax:12];
    float y2b = hillStartY + [MathHelper randomNumberBetween:6 andMax:12];
    
    pointA = b2Vec2(x1 / worldScale, hillStartY / worldScale);
    pointB = b2Vec2(x2 / worldScale, hillStartY / worldScale);
    pointC = b2Vec2(x2 / worldScale, y2 / worldScale);
    pointD = b2Vec2(x1 / worldScale, y2b / worldScale);
    
    b2Vec2 vertices[] = {
        pointA,
        pointB,
        pointC,
        pointD
    };
    
    b2Vec2 bodyPosition = b2Vec2(2,4);
    [self createBodyWithVertices:vertices numVertices:4 b2Vec2Position:bodyPosition];
    
    
    /*b2Vec2 bodyPosition = b2Vec2(10.0f,0.0f);
    for (int i = 0; i < numberOfHills; i++) 
    {
        float randomHeight=arc4random()*100;
        if(i != 0)
        {
            hillStartY -= randomHeight;
        }
        
        for (int j = 0; j < hillSliceWidth; j++) 
        {            
            float x1 = 10.0 + (j*pixelStep);
            float x2 = x1 + hillSliceWidth;
            float y2 = hillStartY + [MathHelper randomNumberBetween:6 andMax:12];
            float y2b = hillStartY + [MathHelper randomNumberBetween:6 andMax:12];
            
            vertices[0] = b2Vec2(x1 / worldScale, hillStartY / worldScale);
            vertices[1] = b2Vec2(x2 / worldScale, hillStartY / worldScale);
            vertices[2] = b2Vec2(x2 / worldScale, y2 / worldScale);
            vertices[3] = b2Vec2(x1 / worldScale, y2b / worldScale);
            
            
            [self createBodyWithVertices:vertices numVertices:4 b2Vec2Position:bodyPosition];
            bodyPosition = b2Vec2(bodyPosition.x + vertices[0].x, bodyPosition.y);
        }
    }*/
}

-(void)generateBodies 
{
	//[self drawHills:2 pixelStep:10];
    
    _bodies = [[CCArray alloc] initWithCapacity:_numberOfBodies];
    //b2BodyDef bd;
    //b2EdgeShape shape;
    
    float x1 = 0.0f, y1 = 0.0f;
    float x2 = x1 + (_bodyWidth); // (_bodyWidth*0.9f) for debugging
    float y2 = 0.0f;
    float y2b = 0.0f;
    
    for(int i = 0; i < _numberOfBodies;i++)
    {
        //bd.position.Set((_bodyWidth*i), i % 2 == 0 ? _b2Position.y : _b2Position.y+0.0625); // for debugging each section
        /*
        bd.position.Set((_bodyWidth*i), _b2Position.y);
        b2Body *body = _layer.world->CreateBody(&bd);
        body->SetType(b2_kinematicBody);
        //shape.SetAsBox(_bodyWidth/2, 0.125, b2Vec2(0.5,0), 0);
        shape.Set(b2Vec2(0,0), b2Vec2(_bodyWidth,0));
        body->CreateFixture(&shape, 0);
        */
        
        y2 = [MathHelper randomFloatBetween:0.05f andMax:0.15f];
        if(i == 0)
        {
            y2b = [MathHelper randomFloatBetween:0.05f andMax:0.15f];
        }
        
        b2Vec2 pointA = b2Vec2(x1, y1);
        b2Vec2 pointB = b2Vec2(x2, y1);
        b2Vec2 pointC = b2Vec2(x2, y2);
        b2Vec2 pointD = b2Vec2(x1, y2b);
        
        b2Vec2 vertices[] = {
            pointA,
            pointB,
            pointC,
            pointD
        };
        
        b2Vec2 p = b2Vec2((_bodyWidth*i), _b2Position.y);
        b2Body *body = [self createBodyWithVertices:vertices numVertices:4 b2Vec2Position:p];
        body->SetType(b2_kinematicBody);
        [_bodies addObject:[NSValue valueWithPointer:body]];
        
        y2b = y2;
    }
}


/*

 
 -(void)generateBodies 
 {
 //[self drawHills:2 pixelStep:10];
 
 _bodies = [[CCArray alloc] initWithCapacity:32];
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
 */

- (void) draw 
{
    /*
    int vertexCount = 4;
    
    glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1f); 
    
    CGRect test = CGRectMake(0.0, 40.0, 192.0, 112.0);
    CGPoint p1 = test.origin; //_trailerBedRect.origin;
    CGSize sz = test.size; //_trailerBedRect.size;
    
    //[super draw];
    
    const CGPoint squareVertices[] = {
        p1,    // position v0
        CGPointMake(p1.x + sz.width, p1.y + sz.height),    // position v1
        CGPointMake(p1.x, p1.y + sz.height),    // position v2
        CGPointMake(p1.x + sz.width, p1.y + sz.height),    // position v3
    };
    
    ccDrawPoly(squareVertices, vertexCount, false);
    */
    
    /*const GLfloat squareVertices[] = {
        -0.5f, -0.5f,    // position v0
        0.5f, -0.5f,    // position v1
        -0.5f,  0.5f,    // position v2
        0.5f,  0.5f,    // position v3
    };
    
    const GLubyte squareColors[] = {
        255, 255,   0, 255,    // yellow color
        0, 255, 255, 255,    // cyan color
        0,   0,   0,   0,    // black color
        255,   0, 255, 255,    // magenta color
    };
    
    int vertexCount = 4;
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glColor4f(1, 0, 0, 1);
    
    //set the format and location for vertices
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    //glColorPointer(4, GL_FLOAT, 0, squareColors);
    //set the opengl state
    //glEnableClientState(GL_COLOR_ARRAY); 
    
    //glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
    glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    */
    
    /*glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY)
	
    const b2Color& color = b2Color(1.0f, 1.0f, 0.0f);
    
    id bid = nil;
    CCARRAY_FOREACH(_bodies, bid)
    {
        b2Body *b = (b2Body *)bid;
        const b2Transform& xf = b->GetTransform();
        
        //b2Fixture *fixt = b->GetFixtureList();
        for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext())
        {
            b2PolygonShape *shape = (b2PolygonShape*)f->GetShape();
            int32 vertexCount = 4; //shape->m_vertexCount;
            b2Assert(vertexCount <= b2_maxPolygonVertices);
            b2Vec2 old_vertices[b2_maxPolygonVertices];
            for (int32 i = 0; i < vertexCount; ++i)
            {
                old_vertices[i] = b2Mul(xf, shape->m_vertices[i]);
            }
            
            // DrawSolidPolygon
            ccVertex2F vertices[vertexCount];
            for( int i=0;i<vertexCount;i++) {
                b2Vec2 tmp = old_vertices[i];
                tmp = old_vertices[i];
                //tmp *= mRatio;
                vertices[i].x = tmp.x;
                vertices[i].y = tmp.y;
            }
            
            glVertexPointer(2, GL_FLOAT, 0, vertices);
            
            glColor4f(color.r*0.5f, color.g*0.5f, color.b*0.5f,0.5f);
            glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
            
            glColor4f(color.r, color.g, color.b,1);
            glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
        }

    }*/
    
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
