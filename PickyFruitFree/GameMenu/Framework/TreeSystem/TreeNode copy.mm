//
//  TreeNode.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/17/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//
#import "TreeNode.h"
#import "MathHelper.h"
#import "CCLayerWithWorld.h"
#import "FruitNodeForTree.h"
#import "ActorInfo.h"
#import "TreeInfo.h"
#import "TreeSystemNode.h"
#import "OutsideScreenEnum.h"


@implementation TreeNode

@synthesize info = _info,
speed = _speed,
fruitCreated = _fruitCreated;

+(id)createWithLayer:(CCLayerWithWorld*)layer
            treeInfo:(TreeInfo*)ti
            position:(b2Vec2)p
{
    return [[[self alloc] initWithLayer:layer
                               treeInfo:ti
                               position:p] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
          treeInfo:(TreeInfo*)ti
          position:(b2Vec2)p
{
    self.info = ti;
    _initialPosition = p;
    
    _currentMouseJoint = NULL;
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:_info.spriteFramesFile];
    
    _initialAnchorPoint = ti.anchorPoint;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:_info.frameName];
    s.tag = _info.tag;

    // fruit node has density=2, friction=0.2, restitution=0.2
    if((self = [super initWithLayer:layer
                        anchorPoint:_initialAnchorPoint
                           position:p 
                             sprite:s
                                  z:_info.z
                    spriteFrameName:_info.frameName 
                                tag:_info.tag
                         fixtureDef:nil
                              shape:nil]))
    {
        _tagMultipler = 1;
        _totFruitClones = 0;
        _fruitCreated = false;
        _cloneTags = [[NSMutableDictionary dictionaryWithCapacity:50] retain];
        _fruitsPool = [[NSMutableArray arrayWithCapacity:50] retain];
        for (ActorInfo *fi in _info.actorsInfo) 
        {
            b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:_info.fruitRegion];
            fruitPosition.x += _initialPosition.x; // need to do this after tree body is created           
            FruitNodeForTree *fruit = [FruitNodeForTree createWithLayer:_layer
                                                                   info:fi
                                                        initialPosition:fruitPosition];
            fruit.parentTreeTag = _info.tag;
            fruit.sprite.opacity = 0;
            //[self addChild:fruit z:fi.z tag:fi.tag];
            [_fruitsPool addObject:fruit];
            NSString* key = [NSString stringWithFormat:@"%d_%@", _info.tag, fi.frameName];
            [_cloneTags setValue:[NSNumber numberWithInt:(fi.tag+1)] forKey:key];
        }
        
        [self createBody];
        [self makeKinematic];
        self.body->SetAwake(false);
        //[self scheduleUpdate];
    }
    return self;
}

-(void)setTreeSystemNode:(TreeSystemNode*)tsn
{
    _treeSystemNode = tsn;
}

-(void)addFruit:(FruitNodeForTree *)fruit
       position:(b2Vec2)p
{
    //FruitNodeForTree *fruit = [FruitNodeForTree createWithLayer:_layer
    //                                                      info:ai
    //                                           initialPosition:p];
    //[self addChild:fruit z:ai.z tag:ai.tag];
    
    // attach fruit to tree using a joint
    if(fruit.jointsDestroyed == false)
    {
        if([self getChildByTag:fruit.info.tag] == nil)
        {
            CCLOG(@"AddFruit %d z %d", fruit.tag, fruit.info.z);
            [self addChild:fruit z:fruit.info.z tag:fruit.info.tag];
        
            // TODO; Need to figure out how to set position
            //[fruit setInitialPosition:p];
            fruit.sprite.opacity = 255;
        
            b2Vec2 fruitCenter = fruit.body->GetWorldCenter();
            b2RevoluteJointDef jointDef;
            jointDef.Initialize(self.body, fruit.body, fruitCenter);
            _world->CreateJoint(&jointDef);
        }
    }
}

-(void)emitFruit
{
   // CCLOG(@"emitFruit tree initialPosition %f %f", self.initialPosition.x, self.initialPosition.y);
    b2Vec2 treePosition = self.body->GetPosition();
    
    //int i = -1;
    /*for (ActorInfo *info in _info.actorsInfo) 
    {
        b2Vec2 p = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:_info.fruitRegion];
        p.x += treePosition.x;
        
        CCLOG(@"Tree %i: emitFruit fruit position %f %f", self.tag, p.x, p.y);
        
        [self addFruit:info 
              position:p];
    }*/
    
    for(FruitNodeForTree *fruit in _fruitsPool)
    {
        b2Vec2 p = b2Vec2(fruit.initialPosition.x + treePosition.x, fruit.initialPosition.y);
        [self addFruit:fruit 
              position:p];
    }
    
    _fruitCreated = true;
}

-(void)onEnter
{
    [super onEnter];
    self.body->SetAwake(false);
    //CCLOG(@"TreeNode: IsAwake %d", self.body->IsAwake());
    
    //_body->SetAngularDamping(2.0f);
    anchorPoint_ = _initialAnchorPoint;
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

/*-(void)update:(float)dt
{
    self.body->SetAwake(false);
    _elapsed += dt;
    b2Vec2 bodyPosition = self.body->GetPosition();
    //if(self.outsideScreenValue != OutsideLeft)
    int spriteWidth = [DevicePositionHelper b2Vec2FromSize:self.sprite.boundingBox.size].x;
    if(bodyPosition.x > (_offsetX1ForOutsideScreen - spriteWidth - 5))
    {
        if(_fruitCreated == false)
        {
            [self emitFruit];
            
        }
        [self updatePosition];
    }
    else
    {
        [self unscheduleAllSelectors];
        CCLOG(@"Tree %d: IsAwake %d", self.tag, self.body->IsAwake());
        CCLOG(@"Tree %d: outsideScreenValue %d; position %.f %.f", self.tag, self.outsideScreenValue, bodyPosition.x, bodyPosition.y);
        int tot = [self countFruitsWithinOtherNodeSprite:[_layer.truckNode sprite]];
        [_treeSystemNode addFruitsSaved:tot];
        
        // recreate additional fruits by recreating the ones that have been picked
        [self recreateMissingFruit];
        
        self.body->SetTransform(_initialPosition, 0);
        [self scheduleUpdate];
    }
}*/

-(void)recreateMissingFruit
{
    // recreate additional fruits by recreating the ones that have been picked/destroyed
    
    //CCLOG(@"Tree %@: recreateMissingFruit: children count %d (total clones %d)", self.info.frameName, self.children.count, _totFruitClones);
    
    CCNode *node;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node isKindOfClass:[FruitNodeForTree class]]) 
        {
            FruitNodeForTree *fruit = (FruitNodeForTree *)node;
            if(fruit.parentTreeTag == _info.tag
               && fruit.jointsDestroyed 
               && fruit.hasClone == false)
            {
                //CCLOG(@"recreateMissingFruit: fruit %@ tag %d", fruit.info.frameName, fruit.tag);
                b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:_info.fruitRegion];
                fruitPosition.x += _initialPosition.x;
                
                NSString* key = [NSString stringWithFormat:@"%d_%@", _info.tag, fruit.info.frameName];
                int cloneTag = [[_cloneTags valueForKey:key] intValue] + _totFruitClones;
                //CCLOG(@"recreateMissingFruit: _tagCloneFruit %d", _tagCloneFruit);
                ActorInfo* cloneInfo = [fruit.info cloneWithNewTag:cloneTag];
                
                FruitNodeForTree *cloneFruit = [FruitNodeForTree createWithLayer:_layer
                                                                            info:cloneInfo
                                                                 initialPosition:fruitPosition];
                cloneFruit.isClone = true;
                cloneFruit.parentTreeTag = _info.tag;
                cloneFruit.sprite.opacity = 0;
                //[self addChild:cloneFruit z:cloneInfo.z tag:cloneInfo.tag];
                [_fruitsPool addObject:cloneFruit];
                cloneInfo = nil;
                cloneFruit = nil;
                fruit.hasClone = true;
                _totFruitClones++;
                CCLOG(@"Tree %@: Cloning fruit %d (z %d) with new tag %d (z %d) (children %d, total clones %d)", self.info.frameName, fruit.tag, fruit.info.z, cloneInfo.tag, cloneInfo.z, self.children.count, _totFruitClones);
            }
        }
    }
    
    _fruitCreated = false;
}

-(void)updatePosition
{
    b2Vec2 position = self.body->GetPosition();
    //b2Vec2 position = _anchorBody->GetPosition();
    float px = position.x;
    float py = position.y;
    
    int direction = -1;
    
    //if(!_flipping && !_reverting)
    {
        //CCLOG(@"direction %d, _pixelsToMove %f", _direction, _pixelsToMove);
        
        b2Vec2 desiredLocation = b2Vec2(px + (direction * (self.speed)), py);
        b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                          desiredLocation.y - py);
        
        directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
        
        //CCLOG(@"SetupOscillation %f %f; %f %f", _upperBounds, _lowerBounds, position.x, directionToTravel.x);
        //_lastPositionX = px;
        self.body->SetLinearVelocity(directionToTravel);
        
        /*
        // TO move all children along with this tree, in case they are not attached with joint, use the following:
        NSObject *child;
        CCARRAY_FOREACH(self.children, child)
        {
            if([child isKindOfClass:[BodyNode class]])
            {
                BodyNode* bn = ((BodyNode*)child);
                if(bn.bodyType != b2_dynamicBody)
                {
                    bn.body->SetLinearVelocity(directionToTravel);
                }
            }
        }*/
    }
}

/*-(int)countFruitsWithinOtherNodeSprite:(CCSprite*)otherNodeSprite
{
    int totFruit = 0;
    
    CCNode *node;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node isKindOfClass:[FruitNodeForTree class]]) {
            FruitNodeForTree *fruit = (FruitNodeForTree *)node;
            if(fruit.jointsDestroyed
               && [fruit isWithinOtherSprite:otherNodeSprite])
            {
                totFruit++;
            }
        }
    }
    return totFruit;
}*/

-(int)countFruits
{
    int totFruit = 0;
    
    CCNode *node;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node isKindOfClass:[FruitNodeForTree class]]) {
            FruitNodeForTree *fruit = (FruitNodeForTree *)node;
            if(fruit.inTruck)
            {
                totFruit++;
            }
        }
    }
    return totFruit;
}

/*-(void)draw
{
    CGPoint currentPos = [DevicePositionHelper pointFromb2Vec2:self.body->GetPosition()];
    
    // draw a ine to show where the fruit region is
    
    glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1f); 
    
    CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:_info.fruitRegion.origin];
    CGSize sz = [DevicePositionHelper sizeFromUnitsSize:_info.fruitRegion.size];
    p1.x += currentPos.x;
    //p1.y += currentPos.y;
    
    [super draw];
    
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);
    
    //CCLOG(@"Draw: Current Pos: %f %f", currentPos.x, currentPos.y);
    //CGPoint p2 = CGPointMake(currentPos.x+100,currentPos.y-100);
    //ccDrawLine(currentPos, p2);
}*/

-(void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)removeBodies
{
    for (CCNode* item in [self children]) 
    {
        if([item isKindOfClass:[BodyNodeWithSprite class]])
        {
            BodyNodeWithSprite* node = (BodyNodeWithSprite*)item;
            //BodyNodeWithSprite *node = (BodyNodeWithSprite *)[self getChildByTag:bnt];
            [node destroyFixture];
            [node destroyBody];
            [node removeFromParentAndCleanup:YES];
        }
    }
}

-(void)dealloc
{
    //CCLOG(@"TreeNode dealloc %@", _spriteFrameName);
    [self stopAllActions];
	[self unscheduleAllSelectors];
    
    [_cloneTags release];
    [_fruitsPool release];
    
    [self removeBodies];
    
    _cloneTags = nil;
    _fruitsPool = nil;
    [super dealloc];
}

@end
