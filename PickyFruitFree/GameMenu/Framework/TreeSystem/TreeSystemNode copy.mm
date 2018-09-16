//
//  TreeSystemNode.mm
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TreeSystemNode.h"
#import "DevicePositionHelper.h"
#import "CCLayerWithWorld.h"

#import "TreeSystemInfo.h"
#import "TreeInfo.h"
#import "TreeNode.h"

//#import "BackgroundSpriteEnum.h"

@implementation TreeSystemNode

@synthesize 
totFruitsSaved = _totFruitsSaved;

+(id)createWithLayer:(CCLayerWithWorld*)layer
      treeSystemInfo:(TreeSystemInfo*)tsi
{
    return [[[self alloc] initWithLayer:(CCLayerWithWorld*)layer
                         treeSystemInfo:tsi] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
    treeSystemInfo:(TreeSystemInfo*)tsi
{
    if((self = [super init]))
    {
        _layer = layer;
        _info = tsi;
        _treesCreated = false;
        
        _screenRect = [DevicePositionHelper screenRect];
        UnitsSize screenSize = [DevicePositionHelper screenUnitsRect].size;
        float screenWidth = _screenRect.size.width;
        float pixelsToMove = (screenWidth / 320) * CC_CONTENT_SCALE_FACTOR();
        _treeSpeed = pixelsToMove * _info.speed;
        
        //_screenCenter = [DevicePositionHelper screenCenter];
        //CCLOG(@"ParallaxBackground: %f %f", _screenRect.size.width, _screenRect.size.height);
        
        _treesPool = [[NSMutableArray arrayWithCapacity:30] retain];
        TreeNode* previousTree = nil;
        for (TreeInfo *ti in _info.treesInfo) 
        {
            UnitsPoint unitsPoint = UnitsPointMake(screenSize.width, 5);
            b2Vec2 p = [DevicePositionHelper b2Vec2FromUnitsPoint:unitsPoint];
            if(previousTree != nil)
            {
                float prevx = previousTree.body->GetPosition().x;
                float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
                p = b2Vec2(prevx+prevw+2, p.y);
            }
            
            TreeNode *tree = [TreeNode createWithLayer:_layer
                                              treeInfo:ti
                                              position:p];
            tree.speed = _treeSpeed;
            tree.sprite.opacity = 0;
            [tree setTreeSystemNode:self];
            [self addChild:tree z:ti.z tag:ti.tag];
            
            previousTree = tree;
            //[self addChild:fruit z:fi.z tag:fi.tag];
            [_treesPool addObject:tree];
        }
        
        [self scheduleUpdate];
    }
    
    return self;
}

/*-(TreeNode *)addTree:(TreeInfo *)ti
            position:(b2Vec2)p
{
    TreeNode *tree = [TreeNode createWithLayer:_layer
                                      treeInfo:ti
                                      position:p];
    tree.speed = _treeSpeed;
    [tree setTreeSystemNode:self];
    [self addChild:tree z:ti.z tag:ti.tag];
    
    return tree;
}*/

-(void)emitTrees
{
    if(_treesCreated == false)
    {
        for(TreeNode *tree in _treesPool)
        {
            //b2Vec2 p = b2Vec2(tree.initialPosition.x + treePosition.x, tree.initialPosition.y);
            //[self addFruit:fruit 
            //      position:p];
            //if([self getChildByTag:tree.info.tag] == nil)
            {
                CCLOG(@"AddTreet %d", tree.info.tag);
                //[self addChild:tree z:tree.info.z tag:tree.info.tag];
                
                // TODO; Need to figure out how to set position
                //[fruit setInitialPosition:p];
                tree.sprite.opacity = 255;
            }
        }
        _treesCreated = true;
    }
    /*UnitsSize screenSize = [DevicePositionHelper screenUnitsRect].size;
    TreeNode* previousTree = nil;
    for (TreeInfo *info in _info.treesInfo) 
    {
        // TODO: need to take in account y offset
        //UnitsPoint unitsPoint = UnitsPointMake(screenSize.width+(24*(info.tag-1)), 5);
        UnitsPoint unitsPoint = UnitsPointMake(screenSize.width, 5);
        b2Vec2 p = [DevicePositionHelper b2Vec2FromUnitsPoint:unitsPoint];
        if(previousTree != nil)
        {
            float prevx = previousTree.body->GetPosition().x;
            float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
            p = b2Vec2(prevx+prevw+10, p.y);
        }
        
        CCLOG(@"emitTrees: tree %i initialPosition %f %f", info.tag, p.x, p.y);
        previousTree = [self addTree:info 
             position:p];
    }
     */
    
    //[self scheduleUpdate];
}

-(void)onEnter
{
    [super onEnter];
    CCLOG(@"TreeSystem: onEnter");
    [self emitTrees];
}

-(void)update:(ccTime)dt
{
    [self updateTreePosition:dt];
}

-(void)updateTreePosition:(ccTime)dt
{
    NSObject *child;
    //TreeNode* previousTree = nil;
    //TreeNode* previousTree = (TreeNode*)[self.children lastObject];
    TreeNode* previousTree = (TreeNode*)[self getChildByTag:3];
    CCARRAY_FOREACH(self.children, child)
    {
        if(child!= nil 
           && [child isKindOfClass:[TreeNode class]])
        {
            TreeNode* tree = ((TreeNode*)child);
            tree.body->SetAwake(false);
            _elapsed += dt;
            b2Vec2 bodyPosition = tree.body->GetPosition();
            b2Vec2 newPosition = tree.initialPosition;
            //if(previousTree != nil)
            //{
            float prevx = previousTree.body->GetPosition().x;
            float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
            newPosition = b2Vec2(prevx+prevw+2, newPosition.y);
            //}
            
            //if(self.outsideScreenValue != OutsideLeft)
            int spriteWidth = [DevicePositionHelper b2Vec2FromSize:tree.sprite.boundingBox.size].x;
            if(bodyPosition.x > (tree.offsetX1ForOutsideScreen - spriteWidth - 5))
            {
                if(tree.fruitCreated == false)
                {
                    [tree emitFruit];
                }
                else
                {
                    //[tree updatePosition];
                    b2Vec2 position = tree.body->GetPosition();
                    //b2Vec2 position = _anchorBody->GetPosition();
                    float px = position.x;
                    float py = position.y;
                    int direction = -1;
                    b2Vec2 desiredLocation = b2Vec2(px + (direction * (tree.speed)), py);
                    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                                      desiredLocation.y - py);
                    
                    directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
                    
                    //CCLOG(@"SetupOscillation %f %f; %f %f", _upperBounds, _lowerBounds, position.x, directionToTravel.x);
                    //_lastPositionX = px;
                    tree.body->SetLinearVelocity(directionToTravel);
                }
            }
            else
            {
                [tree unscheduleAllSelectors];
                //CCLOG(@"Tree %d: IsAwake %d", tree.tag, tree.body->IsAwake());
                //CCLOG(@"Tree %d: outsideScreenValue %d; position %.f %.f", tree.tag, tree.outsideScreenValue, bodyPosition.x, bodyPosition.y);
                int tot = [tree countFruits]; //WithinOtherNodeSprite:[_layer.truckNode sprite]];
                [self addFruitsSaved:tot];
                
                // recreate additional fruits by recreating the ones that have been picked
                [tree recreateMissingFruit];
                
                
                tree.body->SetTransform(newPosition, 0);
                //[self reorderChild:tree z:200];
                //[tree scheduleUpdate];
            }
            
            previousTree = tree;
        }
    }
}

-(void)addFruitsSaved:(int)value
{
    _totFruitsSaved += value;
}

-(void)dealloc
{
    [super dealloc];
}

@end
