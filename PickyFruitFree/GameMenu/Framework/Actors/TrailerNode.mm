//
//  TrailerNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/1/2012.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TrailerNode.h"
#import "WorldHelper.h"
#import "CollisionTypeEnum.h"
#import "ChainNode.h"
#import "TractorWheelNode.h"
#import "TractorNode.h"


typedef enum{
    TrailerTagINVALID = 0,
    TrailerTagWheelMiddle,
    //TrailerTagChain,
    TrailerTagMAX
} TrailerTags;


@implementation TrailerNode


@synthesize 
info = _info;

-(TractorWheelNode *)wheel
{
    return _wheelMiddleNode;
}

-(CGRect)trailerBedRect
{
    CGRect box = [_sprite boundingBox];
    float yposincr = 17;
    float h = 15 + (_heightRows*10);
    return CGRectMake(box.origin.x+18, box.origin.y+yposincr, box.size.width*0.55f, h);
}

-(void)setTractorNode:(TractorNode*)tn
{
    _tractorNode = tn;
}

+(id)createWithLayer:(CCLayerWithWorld *)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip
{
    return [[[self alloc] initWithLayer:layer
                                   info:info
                        initialPosition:ip] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld *)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip
{
    self.info = info;
    _currentMouseJoint = NULL;
    
    // set anchor point
    _initialAnchorPoint = info.anchorPoint;
    
    self.collisionType = info.collisionType;
    self.collidesWithTypes = info.collidesWithTypes;
    self.maskBits = info.maskBits; 
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.tag = info.tag;
    s.opacity = 0;
        
    // Trailer node
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:ip 
                             sprite:s
                                  z:info.z
                    spriteFrameName:info.frameName  
                                tag:info.tag
                         fixtureDef:nil
                              shape:nil]))
    {
        // need to slightly increase left side offset
        // so that is not considered offscreen when just simply touching the left border
        self.offsetX1ForOutsideScreen = -0.1f;
        self.collisionCheckOn = true;
        _height = [s boundingBox].size.height;
        
        // attach back wheel
        uint16 wheelMaskBits = CollisionTypeALL
            & ~CollisionTypeTruck
            & ~CollisionTypeFruit;
        
        b2Vec2 wheelPosition = b2Vec2(0, 0);
        
        // attach middle wheel
        _wheelMiddleNode = [TractorWheelNode createWithLayer:layer
                                                 position:_initialPosition 
                                                       tag:TrailerTagWheelMiddle 
                                                      name:@"TractorFrontWheel"
                                             collisionType:self.collisionType
                                         collidesWithTypes:self.collidesWithTypes
                                                  maskBits:wheelMaskBits];
        _wheelMiddleNode.sprite.opacity = 0;
        //wheelPosition = b2Vec2(_initialPosition.x * 0.98f, wheelY);
        float wheelY = _initialPosition.y + (_spriteSizeInMeters.y / 2 * 0.2f);
        wheelPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x / 2) * 0.97f, wheelY);
        [_wheelMiddleNode setInitialPosition:wheelPosition];
        [self addChild:_wheelMiddleNode z:(info.z + 1) tag:TrailerTagWheelMiddle];
        
        /*// attach a chain to trailer, with a position 
        // slightly hight than half the size of the sprite (0.75)

        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ChainRingB-16"];
        b2Vec2 chainRingSize = [DevicePositionHelper b2Vec2FromSize:frame.rect.size];
        offset = chainRingSize.x/2;
        b2Vec2 chainPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0) + offset, 
                                      _initialPosition.y + (_spriteSizeInMeters.y * 0.9) - offset);
        //b2Vec2 chainPosition = self.initialPosition + b2Vec2(0.5f,self.spriteSizeInMeters.y*0.75f);
        // x 0.546610169491525
        b2Vec2 endRingPosition = b2Vec2(_initialPosition.x + (_spriteSizeInMeters.x * 0.52) + offset, 
                                      _initialPosition.y + (_spriteSizeInMeters.y * 0.9) - offset);
        //b2Vec2 endRingPosition = self.initialPosition + b2Vec2(5.5f,self.spriteSizeInMeters.y*0.75f);
        
        ActorInfo* chainInfo = [self getInfoForChain];
        _trailerChain = [ChainNode createWithLayer:layer
                                            info:chainInfo
                                 initialPosition:chainPosition];
        // chain needs additional parameters to be set:
        [_trailerChain setNumberOfRings:7 isLoose:true endRingPosition:endRingPosition];
        [self addChild:_trailerChain z:chainInfo.z tag:TrailerTagChain];
        */
        
        // run update only once to make wheels visible
        [self scheduleUpdate];
    }
    return self;
}

/*-(void)draw
{
    // draw a ine to show where the Trailer bed is
    glLineWidth(1.0f);
    glColor4f(0.9f, 0.9f, 0.9f, 0.2f); 
    
    CGRect test = self.trailerBedRect; //CGRectMake(0.0, 40.0, 192.0, 112.0);
    CGPoint p1 = test.origin; //_trailerBedRect.origin;
    CGSize sz = test.size; //_trailerBedRect.size;
    
    //[super draw];
    
    //ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    //ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    //ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    //ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);
    
    //CCLOG(@"Trailer Draw: %f %f %f %f", p1.x, p1.y, sz.width, sz.height);
}*/

/*-(ActorInfo*)getInfoForChain
{
    uint16 collidesWithTypes = CollisionTypeALL
        & ~CollisionTypeTruck
        & ~CollisionTypeFruit;
    uint16 maskBits = CollisionTypeALL // collides with everyone but
        & ~CollisionTypeTruck // not with trailer
        & ~CollisionTypeFruit; // and not with fruit
    
    CGPoint ap = cgcenter;
    UnitsPoint up = UnitsPointMake(0,0); //13, 15+_unitsYOffset);
    UnitsBounds ub = UnitsBoundsMake(0,0); //UnitsBoundsFromString(ubStr);
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:@"ChainNode"
                                                     tag:TrailerTagChain
                                                       z:(self.info.z + 1)
                                        spriteFramesFile:@"Chain16.plist"
                                               frameName:@"ChainRingB-16" 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:false
                                                   angle:0
                                             unitsBounds:ub];
    
    //actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = false;
    actorInfo.makeKinematic = false;
    actorInfo.collisionType = self.collisionType;
    actorInfo.collidesWithTypes = collidesWithTypes;
    actorInfo.maskBits = maskBits;
    
    return actorInfo; 
}*/

-(void)removeBodies
{
    for (int bnt = (TrailerTagINVALID + 1); bnt < TrailerTagMAX; bnt++) 
    {
        CCNode *node = [self getChildByTag:bnt];
        
        if(node && [node isKindOfClass:[BodyNodeWithSprite class]])
        {
            BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
            if(node)
            {
                [node destroyFixture];
                [node destroyBody];
                [node removeFromParentAndCleanup:YES];
            }
        }
    }
}

-(void)dealloc
{
    //CCLOG(@"TrailerNode dealloc");
    
    [self stopAllActions];
	[self unscheduleAllSelectors];
    [self removeBodies];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [_info release];
    _info = nil;
    
    [super dealloc];
}

-(void)update:(ccTime)delta
{
    // unschedule so that Update is called only once
    [self unscheduleAllSelectors];
    self.body->SetAwake(false);
    
    if(_wheelMiddleNode.sprite.opacity != 255)
    {
        _wheelMiddleNode.sprite.opacity = 255;
    }
}

-(void)onEnter
{
    _sprite.opacity = 255;
    [super onEnter];
    
    self.body->SetAwake(false);
    
    
    // trailer prismatic joint with ground
    /*b2PrismaticJointDef pjd;
    b2Vec2 selfWorldCenter = self.body->GetWorldCenter();
    pjd.Initialize(self.body, _layer.groundBody, selfWorldCenter, b2Vec2(0, 0));
    _world->CreateJoint(&pjd);*/
    
    /*// attach chain on the back
     jointDef.Initialize(self.body, _trailerChain.firstBodyNode.body, _trailerChain.firstBodyNode.body->GetWorldCenter());
     _world->CreateJoint(&jointDef);
     // attach chain on the front
     jointDef.Initialize(self.body, _trailerChain.lastBodyNode.body, _trailerChain.lastBodyNode.body->GetWorldCenter());
     _world->CreateJoint(&jointDef);
     */
        
    b2RevoluteJointDef jointDef;
    
    // attach middle wheel
    b2Vec2 wheelcenter = _wheelMiddleNode.body->GetWorldCenter();
    wheelcenter = b2Vec2(wheelcenter.x+0.02f, wheelcenter.y-0.01f);
    jointDef.Initialize(self.body, _wheelMiddleNode.body, wheelcenter);
    _world->CreateJoint(&jointDef);
    
    anchorPoint_ = _initialAnchorPoint;
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"TrailerVertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:@"Trailer"
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

-(void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)increaseFruitCount
{
    _fruitsInTrailer++;
    _heightRows = (_fruitsInTrailer / 5);
    _heightRows = _heightRows > 6 
        ? 6 
        : (_heightRows > 0 ? _heightRows : 0);
    CCLOG(@"_fruitsInTrailer %d _heightRows %d", _fruitsInTrailer, _heightRows);
}

// collision
-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
	// check if world left is touching the Trailer
	if (fixt && fixt->GetFilterData().categoryBits == CollisionTypeWorldLeft) 
    {
		/*CCLOG(@"TrailerNode touches world left.");
        if(_sprite)
        {
            _sprite.color = ccBLUE;
        }*/
        
        // push the tractor a little bit to the right
        [_tractorNode giveImpulseToRight];
    }
}

-(void)onSeparateBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
    /*// check if world left is touching the Trailer
	if (fixt && fixt->GetFilterData().categoryBits == CollisionTypeWorldLeft) 
    {	
		CCLOG(@"TrailerNode separated from world left.");
        if(_sprite)
        {
            _sprite.color = ccWHITE;
        }
	}*/
}

@end
