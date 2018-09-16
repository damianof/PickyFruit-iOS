//
//  BodyNode.mm
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "BodyNodeWithSprite.h"
#import "CCLayerWithWorld.h"
#import "DevicePositionHelper.h"


@implementation BodyNodeWithSprite

@synthesize 
    impulseAppliedAt = _impulseAppliedAt,
    spriteSizeInMeters = _spriteSizeInMeters;

-(CCSprite*)sprite
{
    return _sprite;
}

//-(CGRect)box
//{
//   return [_sprite boundingBox];
//}

-(bool)isWithinRect:(CGRect)rect
{
    //return CGRectIntersectsRect(self.box, rect);
    return CGRectIntersectsRect(_sprite.boundingBox, rect);
}

/*-(bool)isWithinOtherSprite:(CCSprite *)otherSprite
{
    CGRect otherRect = [otherSprite boundingBox];
    return [self isWithinRect:otherRect]; //CGRectIntersectsRect([self box], otherRect);
}*/

-(bool)isTouchOnSprite:(UITouch*)touch
{
    //CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    //CGRect rect = self.box;
    //int width = rect.size.width;
    //int height = rect.size.height;
    //int halfWidth = width * 0.5f;
    //int halfHeight = height * 0.5f;
    //CGRect touchRect = CGRectMake(location.x-halfWidth,location.y-halfHeight, width, height);
    //bool retVal = [self isWithinRect:touchRect];
    //return retVal;
    
    return [_sprite isTouchOnSprite:touch];
}

-(void)setLayer:(CCLayerWithWorld*)layer
{
    _layer = layer;
}

+(id)createWithLayer:(CCLayerWithWorld*)layer
         anchorPoint:(CGPoint)ap
            position:(b2Vec2)ip 
              sprite:(CCSprite *)s 
                   z:(int)z 
     spriteFrameName:(NSString *)sfn
                 tag:(int)t
              center:(b2Vec2)c
               angle:(float)a
{
    b2FixtureDef *fd = new b2FixtureDef();
    b2Shape *shape;
    if(s != nil)
    {
        CGSize spriteSize = [s boundingBox].size;
        b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:spriteSize];
        
        b2CircleShape *temp = new b2CircleShape();
        temp->m_radius = spriteSizeInMeters.x * 0.5f;
        shape = temp;
    }
    else
    {
        b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromUnitsSize:UnitsSizeMake(4, 4)];
        
        b2PolygonShape *temp2 = new b2PolygonShape();
        temp2->SetAsBox(spriteSizeInMeters.x * 0.5f, spriteSizeInMeters.y * 0.5f, c, a);
        
        shape = temp2;
    }
    
    return [[[self alloc] initWithLayer:layer
                            anchorPoint:ap
                               position:ip 
                                 sprite:s 
                                      z:z 
                        spriteFrameName:sfn 
                                    tag:t
                             fixtureDef:fd
                                  shape:shape] autorelease];
}

+(id)createWithLayer:(CCLayerWithWorld*)layer
         anchorPoint:(CGPoint)ap
            position:(b2Vec2)ip 
              sprite:(CCSprite *)s 
                   z:(int)z 
     spriteFrameName:(NSString *)sfn
                 tag:(int)t
          fixtureDef:(b2FixtureDef *)fd
               shape:(b2Shape *)sh
{
    return [[[self alloc] initWithLayer:layer
                            anchorPoint:ap
                               position:ip 
                                 sprite:s 
                                      z:z
                        spriteFrameName:sfn 
                                    tag:t
                             fixtureDef:fd
                                  shape:sh] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
       anchorPoint:(CGPoint)ap
          position:(b2Vec2)ip 
            sprite:(CCSprite *)s
                 z:(int)z 
   spriteFrameName:(NSString *)sfn
               tag:(int)t
        fixtureDef:(b2FixtureDef *)fd
             shape:(b2Shape *)sh
{
    // initialize static, then make dynamic when touched
    if((self = [super initWithWorld:layer.world 
                         groundBody:layer.groundBody 
                                tag:t 
                           bodyType:b2_staticBody 
                             active:true 
                           position:ip 
                      fixedRotation:false]))
    {
        _spriteFrameName = sfn;
        _sprite = s;
        
        _layer = layer;
        
        self.tag = t;
        [self setSpriteSize:s];
        _fixtureDef = fd;
        _shape = sh;
        [self addChild:_sprite z:z tag:t];
    }
    return self;
}

// this should be private
-(void)setSpriteSize:(CCSprite *)s
{
    CGSize spriteSize;
    if(s != nil)
    {
        _sprite = s;
        b2Vec2 pos = self.initialPosition;
        _sprite.position = [DevicePositionHelper pointFromb2Vec2:pos];
        spriteSize = [_sprite boundingBox].size;
    }
    else
    {
        UnitsSize defaultSize = UnitsSizeMake(4, 4);
        CGSize s = [DevicePositionHelper sizeFromUnitsSize:defaultSize];
        spriteSize = s; 
    }
    _spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:spriteSize];
}

-(void)removeSprite
{
    /*if(_sprite != nil)
    {
        //CCLOG(@"BodyNodeWithSprite removeSprite");
        [_sprite removeFromParentAndCleanup:YES];
        _sprite = nil;
    }*/
}

-(void)dealloc
{
    //CCLOG(@"BodyNodeWithSprite %@ tag %d dealloc", _spriteFrameName, self.tag);
    [self unscheduleAllSelectors];
    [self stopAllActions];
	
    [self destroyFixture];
    [self removeSprite];
    
    _spriteFrameName = nil;
    _layer = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	
	// skip if the fixture already exists
	if (_fixture)
    {
		return;
	}
    
	// if physics manager is defined now
	if (_world)
	{
		[self createFixture];
	}
}

-(void) onExit
{
	[self unscheduleAllSelectors];
    [self stopAllActions];
    
    // destroy the fixture
	[self destroyFixture];
	
    // call onExit on super (this will destroy the body)
	[super onExit];
}

-(void)createBody
{
    [super createBody];
    // set user data to BodyNodeWithSprite (self)
    self.body->SetUserData(self);
}

-(void)createFixture
{
    //CCLOG(@"BodyNodeWithSprite createFixture");
    
    if(!_fixture)
    {
        if(_fixtureDef && _shape)
        {
            _fixtureDef->shape = _shape;
            
            // categoryBits and maskBits
            _fixtureDef->filter.categoryBits = self.collisionType;
            _fixtureDef->filter.maskBits = self.maskBits;
            
            _fixture = _body->CreateFixture(_fixtureDef);
        }
        
        self.fixturesCreated = true;
    }
}

-(void)replaceFixture
{
    //CCLOG(@"BodyNodeWithSprite createFixture");
    
    [self destroyFixture];
    delete _fixtureDef;
    delete _shape;
    _fixtureDef = NULL;
    _shape = NULL;
    _fixtureDef = _newFixtureDef;
    _shape = _newShape;
    
    [self createFixture];
    self.fixturesReplaced = true;
}

-(void)destroyFixture
{
    if(_fixture)
    {
        //CCLOG(@"BodyNodeWithSprite %@: destroyFixture", _spriteFrameName);
        self.body->DestroyFixture(_fixture);
    }
    delete _fixtureDef;
    delete _shape;
    _fixtureDef = NULL;
    _shape = NULL;
    _fixture = NULL;
}

-(void)setNewFixtureDef:(b2FixtureDef *)fd
                  shape:(b2Shape *)sh
{
    delete _newFixtureDef;
    delete _newShape;
    _newFixtureDef = nil;
    _newShape = nil;
    _newFixtureDef = fd;
    _newShape = sh;
}

-(void)syncWithBody
{
    if(_sprite)
    {
        CGPoint spritePos = [self getBodyPositionInPoints];
        float spriteAngle = [self getBodyAngleInDegrees];
        _sprite.position = spritePos;
        _sprite.rotation = spriteAngle;
    }
    [self syncSize];
}

-(void) syncSize
{
    // must override if needed in subclass
}

// contact
-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn 
                 fixt:(b2Fixture*)fixt
            withForce:(float)f 
    withFrictionForce:(float)ff
{
}

-(void)applyImpulse:(int)x 
              delta:(float)dt
{
    _impulseAppliedAt = dt;
    b2Vec2 impulse = b2Vec2(x,0);
    b2Vec2 point = self.body->GetPosition();
    self.body->ApplyLinearImpulse(impulse, point); 
}


@end
