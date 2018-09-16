//
//  BodyNode.mm
//
//  Created by Damiano Fusco on 4/1/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "BodyNode.h"
#import "DevicePositionHelper.h"
#import "OutsideScreenEnum.h"


@implementation BodyNode


@synthesize 
    groundBody = _groundBody,
    isAwake = _isAwake,
    bodyType = _bodyType,
    body = _body,
    initialPosition = _initialPosition,
    jointsDestroyed = _jointsDestroyed,
    fixturesCreated = _fixturesCreated,
    fixturesReplaced = _fixturesReplaced,
    collisionCheckOn = _collisionCheckOn,
    needsJointsDestroyed = _needsJointsDestroyed,
    offsetX1ForOutsideScreen = _offsetX1ForOutsideScreen,
    offsetY1ForOutsideScreen = _offsetY1ForOutsideScreen,
    offsetX2ForOutsideScreen = _offsetX2ForOutsideScreen,
    offsetY2ForOutsideScreen = _offsetY2ForOutsideScreen,

    collisionType = _collisionType,
    collidesWithTypes = _collidesWithTypes,
    maskBits = _maskBits;

-(NSString*)typeName
{
    return _typeName;
}

-(void)setTypeName:(NSString*)tn
{
    if(_typeName)
    {
        [_typeName release];
        _typeName = nil;
    }
    _typeName = [tn retain];
}

-(void)setInitialPosition:(b2Vec2)p
{
    _initialPosition = p;
}

-(uint16)outsideScreenValue
{
    b2Vec2 bodyPosition = [self getBodyPosition];
    uint16 retVal = OutsideScreenINVALID;
    
    if(bodyPosition.x < (0 + _offsetX1ForOutsideScreen))
    {
        retVal = OutsideScreenLeft;
    }
    else if(bodyPosition.x > (_screenB2Vec2Size.x + _offsetX2ForOutsideScreen))
    {
        retVal = OutsideScreenRight;
    }
    
    if(bodyPosition.y < (0 + _offsetY1ForOutsideScreen))
    {
        retVal &= OutsideScreenDown;
    }
    else if(bodyPosition.y > (_screenB2Vec2Size.y + _offsetY2ForOutsideScreen))
    {
        retVal &= OutsideScreenUp;
    }
    
    return retVal;
}

-(bool)isOutsideScreen
{
    return (self.outsideScreenValue != OutsideScreenINVALID);
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb  
                                    tag:t 
                               bodyType:b2_dynamicBody
                                 active:true
                               position:b2Vec2(0,0)
                          fixedRotation:false] autorelease];
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t 
            bodyType:(b2BodyType)bt
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb 
                                    tag:t  
                               bodyType:bt
                                 active:true
                               position:b2Vec2(0,0)
                          fixedRotation:false] autorelease];
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t 
            bodyType:(b2BodyType)bt
              active:(bool)a
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb 
                                    tag:t 
                               bodyType:bt
                                 active:a
                               position:b2Vec2(0,0)
                          fixedRotation:false] autorelease];
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb 
                 tag:(int)t
            bodyType:(b2BodyType)bt
              active:(bool)a
            position:(b2Vec2)p
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb
                                    tag:t
                               bodyType:bt
                                 active:a
                               position:p
                          fixedRotation:false] autorelease];
}

+(id)createWithWorld:(b2World *)w
          groundBody:(b2Body *)gb
                 tag:(int)t 
            bodyType:(b2BodyType)bt
              active:(bool)a
            position:(b2Vec2)p
       fixedRotation:(bool)fr
{
    return [[[self alloc] initWithWorld:w
                             groundBody:gb 
                                    tag:t 
                               bodyType:bt
                                 active:a
                               position:p
                          fixedRotation:fr] autorelease];
}

-(id)initWithWorld:(b2World *)w
        groundBody:(b2Body *)gb
               tag:(int)t
          bodyType:(b2BodyType)bt
            active:(bool)a
          position:(b2Vec2)p
     fixedRotation:(bool)fr
{
    if((self = [super init]))
    {
        self.tag = t;
        _jointsDestroyed = false;
        _fixturesCreated = false;
        _fixturesReplaced = false;
        _collisionCheckOn = true;
        _currentMouseJoint = NULL;
        
        _needsJointsDestroyed = false;
        
        _world = w;
        _groundBody = gb;
        
        _bodyType = bt;
        _active = a;
        _initialPosition = p;
        _fixedRotation = fr;
        
        _screenB2Vec2Size = [DevicePositionHelper screenB2Vec2Size];
    }
    
    return self;
}

-(void)dealloc
{
    //CCLOG(@"BodyNode dealloc");
    [_typeName release];
    _typeName = nil;
    
    // remove body from world
	[self destroyBody];
    
    _world = NULL;
    _groundBody = NULL;
    _body = NULL;

    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	
	// skip if the body already exists
	if (_body)
    {
		return;
	}
	
	// if physics manager is defined now
	if (_world)
	{
		// create the body
		[self createBody];
	}
}

-(void) onExit
{
	//CCLOG(@"BodyNode onExit");
    [super onExit];
	
	// destroy the body
	[self destroyBody];
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
	
	// get rid of the physics manager reference too
	_world = NULL;
}

-(void)createBody
{
    // Body:
    if(_body)
    {
        return;
    }
    
    b2BodyDef bodyDef;
    bodyDef.awake = false;
    bodyDef.userData = self; // BodyNode;
    bodyDef.active = _active;
    bodyDef.type = _bodyType;
    bodyDef.position = _initialPosition;
    bodyDef.fixedRotation = _fixedRotation;
    
    _body = _world->CreateBody(&bodyDef);
}

-(void)destroyJoints
{
    if(_jointsDestroyed == false)
    {
        // for each attached joint
        b2JointEdge *nextJoint;
        _jointsDestroyed = true;
        for (b2JointEdge *joint = _body->GetJointList(); joint; joint = nextJoint)
        {
            // get the next joint ahead of time to avoid a bad pointer when joint is destroyed
            nextJoint = joint->next;
            
            _world->DestroyJoint(joint->joint);
            
            /*// get the joint sprite
             CCSprite<CCJointSprite> *sprite = (CCSprite<CCJointSprite> *)(joint->joint->GetUserData());
             
             // if the sprite exists
             if (sprite)
             {
             // remove the sprite
             [sprite removeFromParentAndCleanup:YES];
             }*/
        }
    }
    
    self.needsJointsDestroyed = false;
}

-(void)destroyBody
{
	// if body exists
	if (_body)
	{
		[self destroyJoints];
		
		// destroy the body
        _body->SetUserData(NULL);
		_world->DestroyBody(_body);
		_body = NULL;
	}
	
	// be inactive
	_active = false;
}

-(b2Vec2)getBodyPosition
{
    if(_body != NULL)
    {
        return _body->GetPosition();
    }
    else
    {
        return b2Vec2(0,0);
    }
}

-(CGPoint)getBodyPositionInPoints
{
    b2Vec2 bodyPos = [self getBodyPosition];
    return [DevicePositionHelper pointFromb2Vec2:bodyPos];
}

-(float)getBodyAngle
{
    if(_body != NULL)
    {
        return _body->GetAngle();
    }
    else
    {
        return 0;
    }
}

-(float)getBodyAngleInDegrees
{
    float bodyAngle = [self getBodyAngle];
    float retVal = -1 * CC_RADIANS_TO_DEGREES(bodyAngle);
    return retVal;
}

-(void)activateBody
{
    if(_body != NULL)
    {
        return _body->SetActive(true);
    }
}

-(void)deactivateBody
{
    if(_body != NULL)
    {
        return _body->SetActive(false);
    }
}

-(void)awakeBody:(bool)a
{
    _isAwake = a;
    if(a)
    {
        _body->SetAwake(a);
    }
}

-(void)makeDynamic
{
    if(_bodyType != b2_dynamicBody)
    {
        _body->SetType(b2_dynamicBody);
        _bodyType = b2_dynamicBody;
    }
}

-(void)makeKinematic
{
    if(_bodyType != b2_kinematicBody)
    {
        _body->SetType(b2_kinematicBody);
        _bodyType = b2_kinematicBody;
    }
}

-(void)makeStatic
{
    if(_bodyType != b2_staticBody)
    {
        _body->SetType(b2_staticBody);
        _bodyType = b2_staticBody;
    }
}

-(BodyNode *)getTouchedBodyNode:(UITouch *)touch
{
    b2Vec2 p = [DevicePositionHelper locationInWorldFromTouch:touch];
    
    bool test = [DevicePositionHelper checkIfTouchedBody:_world 
                                                   point:p
                                                    body:_body];
    
    BodyNode *retVal = NULL;
    if (test)
	{
        //CCLOG(@"BodyNode: getTouchedBodyNode %d ", test);
        retVal = self;
    }
    
    return retVal;
}

-(void)receiveMessage:(NSString *)m
           floatValue:(float)fv
          stringValue:(NSString *)sv
{
    // must override in subclass
}

@end
