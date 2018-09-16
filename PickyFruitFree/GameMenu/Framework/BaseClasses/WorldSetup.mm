//
//  WorldSetup.mm
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "WorldSetup.h"
#import "CollisionTypeEnum.h"


@implementation WorldSetup


@synthesize 
    groundBody = _groundBody;


+(id)setupWorldWithWorld:(b2World *)w
            unitsYOffset:(int)uyo 
           unitsFromEdge:(int)ufe
{
    return [[[self alloc] initWorldWithWorld:w
                                unitsYOffset:uyo 
                               unitsFromEdge:ufe] autorelease];
}

-(id)initWorldWithWorld:(b2World *)w
           unitsYOffset:(int)uyo 
          unitsFromEdge:(int)ufe
{
    if((self = [super init]))
    {
        _world = w; // week reference for convenience
        _unitsYOffset = uyo;
        _unitsFromEdge = ufe;
        
        // Create the static bodies
        [self createStaticBodies];
    }
    
    return self;
}

-(void)dealloc
{
    //CCLOG(@"WorldSetup: dealloc");
    [self stopAllActions];
	[self unscheduleAllSelectors];
    
    [super dealloc];
}

// helper method that creates a static body with the vertice sinfo passed in
-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
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
    
    b2Body *body = _world->CreateBody(&bodyDef);
    body->CreateFixture(&fixtureDef);
    return body;
}

-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
                            numVertices:(int)nv
                          pointPosition:(CGPoint)pp
{
    b2Vec2 b2p = [DevicePositionHelper b2Vec2FromPoint:pp];
    return [self createStaticBodyWithVertices:v numVertices:nv b2Vec2Position:b2p];
}

-(b2Body *)createStaticBodyWithVertices:(b2Vec2[])v
                            numVertices:(int)nv
                          unitsPosition:(UnitsPoint)up
{
    b2Vec2 b2p = [DevicePositionHelper b2Vec2FromUnitsPoint:up];
    return [self createStaticBodyWithVertices:v numVertices:nv b2Vec2Position:b2p];
}

-(void)createStaticBodies
{
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    _groundBody = _world->CreateBody(&groundBodyDef);
    
    b2EdgeShape groundBox;
    
    UnitsSize screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    
    b2Vec2 b2DpointA1 = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(_unitsFromEdge,_unitsYOffset)];
    b2Vec2 b2DpointA2 = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(screenUnitsSize.width-_unitsFromEdge,_unitsYOffset)];
    b2Vec2 b2DpointB1 = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(_unitsFromEdge,screenUnitsSize.height-_unitsFromEdge)];
    b2Vec2 b2DpointB2 = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(screenUnitsSize.width-_unitsFromEdge,screenUnitsSize.height-_unitsFromEdge)];
    b2Vec2 b2DpointC1 = b2DpointA1;
    b2Vec2 b2DpointC2 = b2DpointB1;
    b2Vec2 b2DpointD1 = b2DpointA2;
    b2Vec2 b2DpointD2 = b2DpointB2;
    
    // bottom
    //groundBox.SetAsEdge(b2DpointA1, b2DpointA2);
    b2FixtureDef def;
	/*def.shape = &groundBox;
    def.density = 0;
    def.filter.categoryBits = CollisionTypeWorldFloor;
    _groundBody->CreateFixture(&def);*/
    
    // top
    groundBox.Set(b2DpointB1, b2DpointB2);
    def.shape = &groundBox;
    def.density = 0;
    def.filter.categoryBits = CollisionTypeWorldTop;
    _groundBody->CreateFixture(&def);
    
    // left
    groundBox.Set(b2DpointC1, b2DpointC2);
    def.shape = &groundBox;
    def.density = 0;
    def.filter.categoryBits = CollisionTypeWorldLeft;
    _groundBody->CreateFixture(&def);
    
    // right
    groundBox.Set(b2DpointD1, b2DpointD2);
    def.shape = &groundBox;
    def.density = 0;
    def.filter.categoryBits = CollisionTypeWorldRight;
    def.filter.maskBits = 
        CollisionTypeALL // don't let anybody out but
        //& ~CollisionTypeTruck // let the truck out
        & ~CollisionTypeChain // let the chain out
        & ~CollisionTypeFruit // let the fruit out
        & ~CollisionTypeHail; // let the hail out
    _groundBody->CreateFixture(&def);
    
    // another shape:
    /*b2Vec2 pointA = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(5,5)]; //[Box2DHelper pointToMeters:CGPointMake(50,50)];
    b2Vec2 pointB = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(55,5)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,50)];
    b2Vec2 pointC = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(55,7)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,64)];
    b2Vec2 pointD = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(5,9)]; //[Box2DHelper pointToMeters:CGPointMake(50,64)];
    
    // create horiz shape
    int numVertices = 4;
    b2Vec2 vertices[] = {
        pointA,
        pointB,
        pointC,
        pointD,
    };
    CGPoint position = cgzero;
    [self createStaticBodyWithVertices:vertices numVertices:numVertices pointPosition:position];*/
    
    
    // another shape:
    /*pointA = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(15,15)]; //[Box2DHelper pointToMeters:CGPointMake(50,50)];
    pointB = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(55,15)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,50)];
    pointC = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(55,17)]; //[Box2DHelper pointToMeters:CGPointMake(screenSize.width-100,64)];
    pointD = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(15,17)]; //[Box2DHelper pointToMeters:CGPointMake(50,64)];
    
    // create ground
    numVertices = 4;
    b2Vec2 vertices2[] = {
        pointA,
        pointB,
        pointC,
        pointD,
    };
    position = cgzero;
    [self createStaticBodyWithVertices:vertices2 numVertices:numVertices andPosition:position];*/
    
    
    // create a shape for fun
    /*pointA = [Box2DHelper pointToMeters:CGPointMake(64,64)];
    pointB = [Box2DHelper pointToMeters:CGPointMake(128,64)];
    pointC = [Box2DHelper pointToMeters:CGPointMake(128,128)];
    pointD = [Box2DHelper pointToMeters:CGPointMake(64,128)];
    
    numVertices = 4;
    b2Vec2 vertices2[] = {
        pointA,
        pointB,
        pointC,
        pointD,
    };
    
    position = CGPointMake(32, 32);
    [self createStaticBodyWithVertices:vertices2 numVertices:numVertices andPosition:position];*/
}


@end
