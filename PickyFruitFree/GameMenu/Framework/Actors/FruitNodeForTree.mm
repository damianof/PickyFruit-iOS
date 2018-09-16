//
//  FruitNodeForTree.mm
//  TestPhysics
//
//  Created by Damiano Fusco on 3/28/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "FruitNodeForTree.h"
#import "GameManager.h"
#import "CollisionTypeEnum.h"
#import "ActorInfo.h"
#import "TruckNode.h"
#import "TractorNode.h"
#import "TreeSystemNode.h"
#import "FruitSlotInfo.h"

#import "SimpleAudioEngine.h"

#define kTagParticleSystemRottening 5431
#define kTagParticleSystemExploding 5432

#define kDensity 0.3f
#define kFriction 0.3f
#define kRestitution 0.25f

@implementation FruitNodeForTree

@synthesize info = _info,
    isClone = _isClone,
    hasClone = _hasClone,
    inTruck = _inTruck,
    parentTreeTag = _parentTreeTag,
    rottenState = _rottenState,
    explosionState = _explosionState;

/*-(FruitSlotInfo *)slotInfo
{
    return _fruitSlotInfo;
}*/

-(void)setSlotInfo:(FruitSlotInfo *)si
{
    _fruitSlotInfo = si;
}


+(id)createWithLayer:(CCLayerWithWorld*)layer
                info:(ActorInfo*)info
     initialPosition:(b2Vec2)ip
{
    return [[[self alloc] initWithLayer:layer
                                   info:info
                        initialPosition:ip] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
              info:(ActorInfo*)info
   initialPosition:(b2Vec2)ip
{
    self.info = info;
    _layer = layer;
    
    _currentMouseJoint = NULL;

    // hard-coded b2 anchor point
    _initialAnchorPoint = cgcenter;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:info.frameName];
    s.scale = 0.25f;
    s.tag = info.tag;
    
    b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[s boundingBox].size];
     b2FixtureDef *fd = new b2FixtureDef();
     fd->density = kDensity;
     fd->friction = kFriction;
     fd->restitution = kRestitution;
     //fd->filter.categoryBits = xxxx;
     b2CircleShape *sh = new b2CircleShape();
     sh->m_radius = spriteSizeInMeters.x * 0.5f;
     //fd->shape = shape;
    
    
    // fruit node has density=2, friction=0.2, restitution=0.2
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:ip 
                             sprite:s
                                  z:info.z
                    spriteFrameName:info.frameName
                                tag:info.tag
                         fixtureDef:fd
                              shape:sh]))
    {
        //
        self.isClone = false;
        self.hasClone = false;
        self.inTruck = false;
        self.collisionType = info.collisionType; //CollisionTypeFruit;
        self.collidesWithTypes = info.collidesWithTypes; //CollisionTypeObstacleHCart;
        self.maskBits = info.maskBits; //CollisionTypeALL;
        
        self.rottenState = RottenStateINVALID;
        self.explosionState = ExplosionStateINVALID;
        
        [self scheduleUpdate];
    }
    return self;
}

-(void)dealloc
{
    //CCLOG(@"FruitNode dealloc %@", _spriteFrameName);
    CCLOG(@"FruitNode dealloc %@ _info retainCount %d", _spriteFrameName, _info.retainCount); 
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:YES];
    
    [_info release];
    _info = nil;
    
    _fruitSlotInfo = nil;
    _sprite = nil;
    _treeSystemNode = nil;
    
    [super dealloc];
}

-(void)setTreeSystemNode:(TreeSystemNode*)tsn
{
    // weak reference, no need to release
    _treeSystemNode = tsn;
}

-(void)syncSize
{
    //_sprite.scale *= self.scale;
}

-(void)onEnter
{
    [super onEnter];
    
    _body->SetAngularDamping(0.2f);
    anchorPoint_ = _initialAnchorPoint;
    
    /*
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"Fruits32Vertices.plist"
                                                   size:[_sprite boundingBox].size
                                                 anchor:_initialAnchorPoint];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.body 
                                           forShapeName:_spriteFrameName
                                   overrideCategoryBits:self.collisionType 
                                       overrideMaskBits:self.maskBits];
    */
    
    [self createFixture];
    
    [_sprite setAnchorPoint:_initialAnchorPoint];

    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 
                                              swallowsTouches:NO];
    
    [self makeDynamic];
    
    [self.sprite runAction:[CCScaleTo actionWithDuration:0.25f scale:1.0f]];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(int)checkIfInTrailer
{
    int trailerNum = [_layer.tractorNode checkIfFruitIsInTrailer:self];
    return trailerNum;
}

-(void)privateIncreaseDestroyedFruits:(NSString*)fruitFrameName
{
    // send delayed message (0.5 secons) to increase destroyed fruits to manager 
    // so that user can see the fruit exploding
    [[GameManager sharedInstance] increaseDestroyedFruits:fruitFrameName
                                                withDelay:kDelayToIncreaseDestroyedFruits];
}

-(void)privateIncreaseSavedFruits:(NSString*)fruitFrameName
{
    [[GameManager sharedInstance] increaseSavedFruits:fruitFrameName
                                            withDelay:kDelayToIncreaseSavedFruits];
}

-(void)privateDecreaseSavedFruits:(NSString*)fruitFrameName
{
    [[GameManager sharedInstance] decreaseSavedFruits:fruitFrameName
                                            withDelay:kDelayToDecreaseSavedFruits];
}

-(void)update:(ccTime)delta
{
    if (self.jointsDestroyed 
        && self.collisionCheckOn
        && self.outsideScreenValue != OutsideScreenINVALID)
    {
        // clear slot
        _fruitSlotInfo.filled = false;
        
        /*// if fruit goes outside screen and was in truck, decrease saved fruit and destroy it
        if(self.inTruck)
        {
            [self privateDecreaseSavedFruits:self.info.frameName];
        }
        [self privateIncreaseDestroyedFruits:self.info.frameName];*/
        
        // clear slot
        _fruitSlotInfo.filled = false;
        [self privateIncreaseDestroyedFruits:self.info.frameName];

        [_layer destroyBodyNodeWithSprite:self];
        return;
    }
    
    if (self.jointsDestroyed
        && self.inTruck == false
        //&& self.collisionCheckOn
        )
    {
        //_sprite.color = ccBLUE;
        if([self checkIfInTrailer] > -1)
        {
            // clear slot
            _fruitSlotInfo.filled = false;
            
            //self.collisionCheckOn = false;
            self.inTruck = true;
            [self privateIncreaseSavedFruits:self.info.frameName];
            
            [[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxFruitFalling];
        }
	}
    /*else if (self.jointsDestroyed
        && self.inTruck)
    {
        //_sprite.color = ccBLUE;
        if([self checkIfInTrailer] == -1)
        {
            //self.collisionCheckOn = false;
            self.inTruck = false;
            [_treeSystemNode decreaseSavedFruits];
        }
	}*/
    
    if (self.rottenState == RottenStateInit)
    {
        self.rottenState = RottenStateStarted;
        
        /*id action1 = [CCBlink actionWithDuration:0.25f blinks:3];
        id action2 = [CCTintBy actionWithDuration:2.0f red:-255 green:-125 blue:-125];
        id seq = [CCSequence actions:action1, action2, nil];
        [self.sprite runAction:[CCRepeat actionWithAction:seq times:1]];*/
        
        CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:kFramesFileFruitRottening];
        [ps setTexture:_sprite.texture withRect:_sprite.textureRect];
        ps.positionType = kCCPositionTypeGrouped;
        ps.position = self.sprite.position;
        ps.autoRemoveOnFinish = true;
        [self addChild:ps z:self.info.z+1 tag:kTagParticleSystemRottening];
        self.sprite.opacity = 0;
    }
    else if (self.rottenState == RottenStateStarted)
    {
        CCNode* ps = [self getChildByTag:kTagParticleSystemRottening];
        if(!ps || self.outsideScreenValue == OutsideScreenLeft)
        {
            // clear slot
            _fruitSlotInfo.filled = false;
            [self privateIncreaseDestroyedFruits:self.info.frameName];
            
            [_layer destroyBodyNodeWithSprite:self];
            return;
        }
        
        ps.position = self.sprite.position;
        ps.rotation = self.sprite.rotation;
    }
    
    if(self.explosionState == ExplosionStateInit)
    {
        // clear slot
        _fruitSlotInfo.filled = false;
        
        if(self.inTruck)
        {
            [self privateDecreaseSavedFruits:self.info.frameName];
        }
        // increase destroyed fruits
        [self privateIncreaseDestroyedFruits:self.info.frameName];
        
        self.explosionState = ExplosionStateStarted;
        CCParticleSystemQuad *expl = [CCParticleSystemQuad particleWithFile:kFramesFileFruitExploding];
        [expl setTexture:_sprite.texture withRect:_sprite.textureRect];
        expl.position = self.sprite.position;
        expl.autoRemoveOnFinish = true;
        [_layer addChild:expl z:self.info.z+1 tag:kTagParticleSystemExploding];
        
        [_layer destroyBodyNodeWithSprite:self];
    }
}

// collision
-(void) onOverlapBody:(BodyNodeWithSprite *)bn
                 fixt:(b2Fixture*)fixt
{
    //_touchesOtherFruitInTruck
    
    /*if(bn.collisionType == CollisionTypeFruit) {
        CCLOG(@"FruitNode is overlapping with another fruit.");
        FruitNodeForTree *otherFruit = (FruitNodeForTree*)bn;
        if(otherFruit.inTruck)
        {
            _sprite.color = ccGREEN;
            CCLOG(@"FruitNode is overlapping with another fruit that is in the trailer so marking this one inTruck also.");
            _touchesOtherFruitInTruck = true;
        }
    }*/
    
    /*if(bn.collisionType == CollisionTypeTruck) {
		//CCLOG(@"FruitNode is overlapping with the truck.");
        if (self.jointsDestroyed 
            && [self isWithinRect:_layer.truckNode.truckBedRect]
            )
        {
            _sprite.color = ccBLUE;
            self.collisionCheckOn = false;
            self.inTruck = true;
            //self.maskBits &= ~CollisionTypeFruit;
            //self.body->SetActive(false);
            
            //_sprite.anchorPoint = CGPointMake(0,1);
        }
        
        if(self.jointsDestroyed == false
           && bn.collisionType == CollisionTypeEnemy)
        {
            CCLOG(@"Collided with enemy ------------");
            ccColor3B c = {125,0,125};
            _sprite.color = c;
            self.rottening = true;
            self.collisionCheckOn = false;
        }
    }*/
}

-(void) onSeparateBody:(BodyNodeWithSprite *)bn
                  fixt:(b2Fixture*)fixt
{
    /*if(bn.collisionType == CollisionTypeFruit) {
        FruitNodeForTree *otherFruit = (FruitNodeForTree*)bn;
        if(otherFruit.inTruck == true)
        {
            _sprite.color = ccWHITE;
            _touchesOtherFruitInTruck = false;
        }
    }*/
    /*if (bn.collisionType == CollisionTypeTruck) {
        _sprite.color = ccWHITE;
    }*/
}

-(void) onCollideBody:(BodyNodeWithSprite *)bn 
                 fixt:(b2Fixture*)fixt
            withForce:(float)f 
    withFrictionForce:(float)ff
{
    // if other body has collision check on
    if(bn.collisionCheckOn || bn.collisionType == CollisionTypeZERO)
    {
        if(bn.collisionType == CollisionTypeZERO
           || bn.collisionType == CollisionTypeTruckDriver
           || bn.collisionType == CollisionTypeHail)
        {
            // explode fruit 
            self.collisionCheckOn = false;
            self.explosionState = ExplosionStateInit;
            
            [[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxFruitSmash];
        }
        
        // rotten fruit on Enemy collision
        else if(//self.jointsDestroyed == false
                bn.collisionType == CollisionTypeEnemy
                && self.rottenState == RottenStateINVALID)
        {
            //self.collisionCheckOn = false;
            //CCLOG(@"FruitNodeForTree onCollideBody: Collided with enemy ------------");
            self.rottenState = RottenStateInit;
        }
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    /*CGPoint location = [touch locationInView:[touch view]];	
    location = [[CCDirector sharedDirector] convertToGL:location];
    CGRect rect = [_sprite boundingBox];
    CCLOG(@"FruitNode %d: ccTouchBegan: touch (%.2f, %.2f); or (%.2f, %.2f); sz (%.2f, %.2f)", self.tag, location.x, location.y, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    if (CGRectContainsPoint(rect, location)) {
        CCLOG(@"Contains");
        _sprite.color = ccRED;
    }
    
    CGRect touchRect = CGRectMake(location.x-16,location.y-16, 32, 32);
    if (CGRectIntersectsRect(rect, touchRect)) {
        CCLOG(@"Intersects");
        _sprite.color = ccBLUE;
    }*/
        
    return YES;
}

-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    //CCLOG(@"FruitNode %d: ccTouchEnded", self.tag);
    
    if(self.jointsDestroyed == false)
    {
        //CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        //CGRect rect = [_sprite boundingBox];     
        //CGRect touchRect = CGRectMake(location.x-16,location.y-16, 32, 32);
        //if (CGRectIntersectsRect(rect, touchRect))
        if ([self isTouchOnSprite:touch])
        {
            // stop collision with enemy
            self.maskBits = _info.maskBits 
                & ~CollisionTypeEnemy;
            
            //_sprite.color = ccBLUE;
            //CCLOG(@"FruitNodeForTree %d: ccTouchEnded: destroy joints", self.tag);
            
            [self destroyJoints]; // this might be better
            //self.needsJointsDestroyed = true;
            
            // stop rottening if fruit is picked up
            CCNode* ps = [self getChildByTag:kTagParticleSystemRottening];
            if (ps && self.rottenState != RottenStateINVALID) {
                self.rottenState = RottenStateINVALID;
                self.sprite.opacity = 255;
                [ps removeFromParentAndCleanup:true];
            }
            
            _sprite.scale = kFloat0Point5;
            //CCLOG(@"ccTouchEnded shrink fruit");
            b2Vec2 spriteSizeInMeters = [DevicePositionHelper b2Vec2FromSize:[_sprite boundingBox].size];
            b2FixtureDef *fd = new b2FixtureDef();
            fd->density = kDensity;
            fd->friction = kFriction;
            fd->restitution = kRestitution;
            //fd->filter.categoryBits = xxxx;
            b2CircleShape *sh = new b2CircleShape();
            sh->m_radius = spriteSizeInMeters.x * 0.4f;
            //fd->shape = shape;
            
            [self setNewFixtureDef:fd
                             shape:sh];
            
            self.fixturesReplaced = false;
            
            //[self destroyFixture];
            [self replaceFixture];
            
            self.body->ApplyAngularImpulse(-0.005f);
                        
            //[_layer destroyBodyNodeFixtures:self];
            //[_layer replaceBodyNodeFixtures:self];
            
            //CCLOG(@"ccTouchEnded IsLocked %d", _layer.world->IsLocked());
            
            //if(self.sprite && self.body->GetJointList())
            //{
            //    //CCLOG(@"Hail has collided with a chain!");
            //    if (std::find(_bodyNodesWithJointsToDestroy.begin(), _bodyNodesWithJointsToDestroy.end(), chainCollided) == /_bodyNodesWithJointsToDestroy.end()) 
            //    {
            //        _bodyNodesWithJointsToDestroy.push_back(self);
            //    }
            //}
        }
    }
}

@end
