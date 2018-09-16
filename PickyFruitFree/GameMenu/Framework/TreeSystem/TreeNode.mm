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
//#import "OutsideScreenEnum.h"
#import "FruitSlotInfo.h"

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
    
    _initialAnchorPoint = ti.anchorPoint;
    
    // Sprite
    CCSprite *s = [CCSprite spriteWithSpriteFrameName:_info.frameName];
    s.tag = _info.tag;

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
        self.fruitCreated = false;
        // create array of fruit slots
        // fruit region size should be multiples of five
        int multiple = 5;
        int numberOfCols = (_info.fruitRegion.size.width/multiple);
        int numberOfRows = (_info.fruitRegion.size.height/multiple);
        _maxFruitSlots = numberOfCols * numberOfRows;
        _fruitSlots = [[CCArray alloc] initWithCapacity:_maxFruitSlots];
        
        UnitsPoint regionOrigin = _info.fruitRegion.origin;
        
        // create a 4x3 grid where to place the fruits
        int c = 0, r = 0;
        for(int i = 0; i < _maxFruitSlots; i++)
        {
            b2Vec2 slotPos = [DevicePositionHelper b2Vec2FromUnitsPoint:UnitsPointMake(regionOrigin.x+(c*multiple), regionOrigin.y+(r*multiple))];
            slotPos = b2Vec2(slotPos.x+0.5f, slotPos.y+0.5f);
            float offsetx = i % 2 == 0 ? 0 : [MathHelper randomFloatBetween:-0.5f andMax:0.5f];
            float offsety = i % 2 == 0 ? 0 : [MathHelper randomFloatBetween:-0.5f andMax:0.5f];
            slotPos = b2Vec2(slotPos.x+offsetx, slotPos.y+offsety);
            FruitSlotInfo *slotInfo = [FruitSlotInfo createWithPosition:slotPos];
            [_fruitSlots addObject:slotInfo];
            slotInfo = nil;
            
            c++;
            if(c == numberOfCols)
            {
                c = 0; // reset col index
                r++;
                if(r == numberOfRows){
                    r = 0; // reset row index
                }
            }
        }
        
        [self createBody];
        [self makeKinematic];
        self.body->SetAwake(false);
    }
    return self;
}

-(void)setTreeSystemNode:(TreeSystemNode*)tsn
{
    _treeSystemNode = tsn;
}

-(void)onEnter
{
    [super onEnter];
    self.body->SetAwake(false);
    //CCLOG(@"TreeNode: IsAwake %d", self.body->IsAwake());
    
    anchorPoint_ = _initialAnchorPoint;
    [_sprite setAnchorPoint:_initialAnchorPoint];
}

/*-(void)draw
{
    //[super draw];
    //self.sprite.opacity = 0.5f;
    
    CGPoint currentPos = [DevicePositionHelper pointFromb2Vec2:self.body->GetPosition()];
    
    // draw a ine to show where the fruit region is
    
    glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 1.0f); 
    
    CGPoint p1 = [DevicePositionHelper pointFromUnitsPoint:_info.fruitRegion.origin];
    CGSize sz = [DevicePositionHelper sizeFromUnitsSize:_info.fruitRegion.size];
    p1.x += currentPos.x;
    //p1.y += currentPos.y;
    
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    //ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);
    
    CGPoint prp = cgzero;
    for(int i = 0; i < _maxFruitSlots; i++)
    {
        FruitSlotInfo *slotInfo = (FruitSlotInfo*)[_fruitSlots objectAtIndex:i];
        CGPoint rp = [DevicePositionHelper pointFromb2Vec2:slotInfo.position];
        rp.x += currentPos.x;
        if(i > 0)
        {
            ccDrawLine(prp, rp);
        }
        prp = rp;
    }
    
    //CCLOG(@"Tree Draw: %f %f %f %f", p1.x, p1.y, sz.width, sz.height);
    //CGPoint p2 = CGPointMake(currentPos.x+100,currentPos.y-100);
    //ccDrawLine(currentPos, p2);
}*/

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
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
    [self removeBodies];
    
    [_info release];
    _info = nil;
    
    [_fruitSlots release];
    _fruitSlots = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(bool)treeHasSlotsAvailable
{
    bool retVal = false;
    for(int i = 0; i < _fruitSlots.count; i++)
    {
        FruitSlotInfo* slotInfo = (FruitSlotInfo*)[_fruitSlots objectAtIndex:i];
        if(!slotInfo.filled)
        {
            retVal = true;
            break;
        }
    }
    return retVal;
}

-(FruitSlotInfo*)recursiveGetRandomFruitSlot // recursive function. Make sure you  check treeHasSlotsAvailable before calling this
{    
    // for fun, avoid the top-left corner by starting at 1
    // and the the bottom-right corner by ending at _fruitSlots.count-1
    int randomIndex = [MathHelper randomNumberBetween:1 andMax:(_fruitSlots.count-1)];
    FruitSlotInfo *slotInfo = (FruitSlotInfo*)[_fruitSlots objectAtIndex:randomIndex];
    //CCLOG(@"Tree %d: recursiveGetRandomFruitSlot: randomIndex %d", self.info.tag, randomIndex);
    
    while(slotInfo.filled)
    {
        if(_fruitSlotsRecursionCounter < _maxFruitSlots) // control max number of recurions to avoid application stalling
        {
            _fruitSlotsRecursionCounter++;
            slotInfo = nil;
            slotInfo = [self recursiveGetRandomFruitSlot];
        }
        else
        {
            CCLOG(@"Tree %d: recursiveGetRandomFruitSlot: max recursion reached", self.info.tag);
            slotInfo = (FruitSlotInfo*)[_fruitSlots objectAtIndex:randomIndex];
            slotInfo.filled = false;
        }
    }
    
    return slotInfo;
}

-(FruitSlotInfo*)getRandomFruitSlot 
{    
    //NSAssert1([self treeHasSlotsAvailable] == true, @"Tree %d: Tree has no available slots", self.info.tag);
    FruitSlotInfo *slotInfo = [self recursiveGetRandomFruitSlot];    
    _fruitSlotsRecursionCounter = 0;
    return slotInfo;
}

-(void)resetSlots
{
    for(int i = 0; i < _fruitSlots.count; i++)
    {
        FruitSlotInfo *slotInfo = (FruitSlotInfo *)[_fruitSlots objectAtIndex:i];
        slotInfo.filled = false;
    } 
}

@end
