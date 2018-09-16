//
//  TreeSystemNode.mm
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TreeSystemNode.h"
#import "MathHelper.h"
#import "DevicePositionHelper.h"
#import "CCLayerWithWorld.h"
#import "UserInterfaceLayer.h"
#import "GameManager.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "FruitMessageEnum.h"

#import "TreeSystemInfo.h"
#import "TreeInfo.h"
#import "TreeNode.h"
#import "FruitNodeForTree.h"


@implementation TreeSystemNode

@synthesize 
treeSpeed = _treeSpeed;

+(id)createWithLayer:(CCLayerWithWorld*)layer
      treeSystemInfo:(TreeSystemInfo*)tsi
{
    return [[[self alloc] initWithLayer:layer
                         treeSystemInfo:tsi] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
    treeSystemInfo:(TreeSystemInfo*)tsi
{
    if((self = [super init]))
    {
        GameManager *sharedGameManager = [GameManager sharedGameManager];
        
        _layer = layer;
        _info = tsi;
        _treesCreated = false;
        
        _treeLayer = [[CCNode alloc] init];
        [self addChild:_treeLayer z:1 tag:987001];
        _fruitLayer = [[CCNode alloc] init];
        [self addChild:_fruitLayer z:2 tag:987002];
        
        _screenRect = [DevicePositionHelper screenRect];
        UnitsSize screenSize = [DevicePositionHelper screenUnitsRect].size;
        _pixelsToMove = [DevicePositionHelper pixelsToMove];
        _treeSpeed = _info.speed;
        
        //_screenCenter = [DevicePositionHelper screenCenter];
        //CCLOG(@"ParallaxBackground: %f %f", _screenRect.size.width, _screenRect.size.height);
        
        _treesPool = [[NSMutableArray arrayWithCapacity:30] retain];
        _fruitTagMultipler = 1;
        _totFruitClones = 0;
        _fruitCloneTags = [[NSMutableDictionary dictionaryWithCapacity:50] retain];
        _fruitsPool = [[NSMutableArray arrayWithCapacity:50] retain];
        
        TreeNode* previousTree = nil;
        for (TreeInfo *treeInfo in _info.treesInfo) 
        {
            UnitsPoint unitsPoint = UnitsPointMake(screenSize.width, 5);
            b2Vec2 treeInitialPosition = [DevicePositionHelper b2Vec2FromUnitsPoint:unitsPoint];
            if(previousTree != nil)
            {
                float prevx = previousTree.body->GetPosition().x;
                float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
                treeInitialPosition = b2Vec2(prevx+prevw+2, treeInitialPosition.y);
            }
            
            TreeNode *tree = [TreeNode createWithLayer:_layer
                                              treeInfo:treeInfo
                                              position:treeInitialPosition];
            tree.speed = _treeSpeed;
            tree.sprite.opacity = 0;
            [tree setTreeSystemNode:self];
            [_treeLayer addChild:tree z:treeInfo.z tag:treeInfo.tag];
            
            previousTree = tree;
            [_treesPool addObject:tree];
            
            // add fruits to fruits pool
            for (ActorInfo *fi in treeInfo.actorsInfo) 
            {
                b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:treeInfo.fruitRegion];
                FruitNodeForTree *fruit = [FruitNodeForTree createWithLayer:_layer
                                                                       info:fi
                                                            initialPosition:fruitPosition];
                fruit.parentTreeTag = treeInfo.tag;
                fruit.sprite.opacity = 0;
                [fruit setTreeSystemNode:self];
                [_fruitsPool addObject:fruit];
                NSString* key = [NSString stringWithFormat:@"%d_%@", treeInfo.tag, fi.frameName];
                [_fruitCloneTags setValue:[NSNumber numberWithInt:(fi.tag+1000)] forKey:key];
            }
        }

        // add additional fruit based on game levels amounts
        TreeInfo *lastTreeInfo = (TreeInfo*)[_info.treesInfo lastObject];
        ActorInfo *modelInfo = (ActorInfo *)[lastTreeInfo.actorsInfo lastObject];
        ActorInfo *infoToUse = NULL;
        TreeInfo *randomTreeInfo = NULL;
        int tagIncreaser = 10000;
        int tag2Increaser = 20000;
        for (LevelGoal *goal in sharedGameManager.currentGameLevel.levelGoals)
        {
            bool found = false;
            for (TreeInfo *treeInfo in _info.treesInfo) 
            {
                for (ActorInfo *fi in treeInfo.actorsInfo) 
                {
                    if ([goal.fruitName isEqualToString:fi.frameName]) {
                        found = true;
                        infoToUse = [fi cloneWithNewTag:fi.tag+(tagIncreaser++)];
                        break;
                    }
                }
                if(found)
                {
                    break;
                }
            }
            
            int fruitCounterStart = 1; // start at one if found = true
            if(found == false)
            {
                fruitCounterStart = 0;
                // if goal fruit is not part of the tree info, create a new one
                infoToUse = [modelInfo cloneWithNewTag:modelInfo.tag + (tag2Increaser++)];             
                infoToUse.frameName = goal.fruitName;
            }
            
            // spread the target number of fruits randomly on the trees
            for(int i = fruitCounterStart; i <= goal.target; i++)
            {
                infoToUse = [infoToUse cloneWithNewTag:infoToUse.tag + i];             
                int randomIndex = [MathHelper randomNumberBetween:0 andMax:_info.treesInfo.count-1];
                randomTreeInfo = [_info.treesInfo objectAtIndex:randomIndex];
                b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:randomTreeInfo.fruitRegion];
                fruitPosition = b2Vec2(fruitPosition.x+0.5, fruitPosition.y+0.5);
                FruitNodeForTree *newfruit = [FruitNodeForTree createWithLayer:_layer
                                                                       info:infoToUse
                                                            initialPosition:fruitPosition];
                newfruit.tag = infoToUse.tag;
                newfruit.parentTreeTag = randomTreeInfo.tag;
                newfruit.sprite.opacity = 0;
                [newfruit setTreeSystemNode:self];
                [_fruitsPool addObject:newfruit];
                
                //CCLOG(@"Fruit Goal added: %@ tag %d tag %d (counter %d)", infoToUse.frameName, infoToUse.tag, newfruit.tag, i);
                
                newfruit = NULL;
                
                //if(found == false)
                {
                    //NSString* key = [NSString stringWithFormat:@"%d_%@", randomTreeInfo.tag, infoToUse.frameName];
                    //[_fruitCloneTags setValue:[NSNumber numberWithInt:(infoToUse.tag+1000)] forKey:key];
                }
            }
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
            //if([_treeLayer getChildByTag:tree.info.tag] == nil)
            {
                //CCLOG(@"AddTree %d", tree.info.tag);
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
    //CCLOG(@"TreeSystem: onEnter");
    
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
    
    // TODO: need to find how to get the last tree without risking to get a fruit
    //int lastTreeTag = ((TreeInfo*)[_info.treesInfo lastObject]).tag;
    TreeNode* previousTree = (TreeNode*)[_treesPool lastObject]; //(TreeNode*)[_treeLayer getChildByTag:lastTreeTag];
    CCARRAY_FOREACH(_treeLayer.children, child)
    {
        if(child!= nil 
           && [child isKindOfClass:[TreeNode class]])
        {
            TreeNode* tree = ((TreeNode*)child);
            tree.body->SetAwake(false);
            _elapsed += dt;
            b2Vec2 bodyPosition = tree.body->GetPosition();

            
            //if(self.outsideScreenValue != OutsideLeft)
            int spriteWidth = [DevicePositionHelper b2Vec2FromSize:tree.sprite.boundingBox.size].x;
            if(bodyPosition.x > (tree.offsetX1ForOutsideScreen - spriteWidth - 5))
            {
                if(tree.fruitCreated == false)
                {
                    [self emitFruit:tree];
                }
                else
                {
                    //[tree updatePosition];
                    //b2Vec2 position = tree.body->GetPosition();
                    ////b2Vec2 position = _anchorBody->GetPosition();
                    //float px = position.x;
                    //float py = position.y;
                    int direction = -1;
                    /*b2Vec2 desiredLocation = b2Vec2(px + (direction * (tree.speed)), py);
                    b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - px,
                                                      desiredLocation.y - py);*/
                    b2Vec2 directionToTravel = b2Vec2((direction * (tree.speed * _pixelsToMove)), 0);
                    directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
                    
                    //CCLOG(@"SetupOscillation %f %f; %f %f", _upperBounds, _lowerBounds, position.x, directionToTravel.x);
                    //_lastPositionX = px;
                    tree.body->SetLinearVelocity(directionToTravel);
                }
            }
            else
            {
                [tree unscheduleAllSelectors];
                
                // recreate additional fruits by recreating the ones that have been picked
                [self recreateMissingFruit:tree];
                
                b2Vec2 newPosition = tree.initialPosition;
                //if(previousTree != nil)
                //{
                float prevx = previousTree.body->GetPosition().x;
                float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
                newPosition = b2Vec2(prevx+prevw+2, newPosition.y);
                //}
                
                tree.body->SetTransform(newPosition, 0);
                //[self reorderChild:tree z:200];
                //[tree scheduleUpdate];
            }
            
            previousTree = tree;
        }
    }
}

-(void)addFruit:(FruitNodeForTree *)fruit
           tree:(TreeNode*)tree
{
    // attach fruit to tree using a joint
    b2Vec2 treePosition = tree.body->GetPosition();
    
    if(fruit.parentTreeTag == tree.tag
       && fruit.jointsDestroyed == false)
    {
        if([_fruitLayer getChildByTag:fruit.info.tag] == nil)
        {
            b2Vec2 p = b2Vec2(fruit.initialPosition.x + treePosition.x, fruit.initialPosition.y);
            fruit.initialPosition = p;
            
            //CCLOG(@"AddFruit %d z %d", fruit.tag, fruit.info.z);
            [_fruitLayer addChild:fruit z:fruit.info.z tag:fruit.info.tag];
            
            // TODO; Need to figure out how to set position
            //[fruit setInitialPosition:p];
            fruit.sprite.opacity = 255;
            
            b2Vec2 fruitCenter = fruit.body->GetWorldCenter();
            b2RevoluteJointDef jointDef;
            jointDef.Initialize(tree.body, fruit.body, fruitCenter);
            _layer.world->CreateJoint(&jointDef);
        }
    }
}

-(void)emitFruit:(TreeNode*)tree
{
    // CCLOG(@"emitFruit tree initialPosition %f %f", self.initialPosition.x, self.initialPosition.y);
    for(FruitNodeForTree *fruit in _fruitsPool)
    {
        //CCLOG(@"emitFruit: fruitsPool %@ tag %d tag %d", fruit.info.frameName, fruit.info.tag, fruit.tag);
        [self addFruit:fruit 
                  tree:tree];
    }
    
    tree.fruitCreated = true;
}

-(void)recreateMissingFruit:(TreeNode*)tree
{
    // recreate additional fruits by recreating the ones that have been picked/destroyed
    //CCLOG(@"Tree %@: recreateMissingFruit: children count %d (total clones %d)", self.info.frameName, self.children.count, _totFruitClones);
    
    CCNode *node;
    CCARRAY_FOREACH(_fruitLayer.children, node)
    {
        if ([node isKindOfClass:[FruitNodeForTree class]]) 
        {
            FruitNodeForTree *fruit = (FruitNodeForTree *)node;
            if(fruit.parentTreeTag == tree.tag
               && fruit.jointsDestroyed 
               && fruit.hasClone == false)
            {
                b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:tree.info.fruitRegion];

                NSString* key = [NSString stringWithFormat:@"%d_%@", tree.tag, fruit.info.frameName];
                int cloneTag = [[_fruitCloneTags valueForKey:key] intValue] + _totFruitClones;
                ActorInfo* cloneInfo = [fruit.info cloneWithNewTag:cloneTag];
                
                FruitNodeForTree *cloneFruit = [FruitNodeForTree createWithLayer:_layer
                                                                            info:cloneInfo
                                                                 initialPosition:fruitPosition];
                cloneFruit.isClone = true;
                cloneFruit.parentTreeTag = tree.tag;
                cloneFruit.sprite.opacity = 0;
                [cloneFruit setTreeSystemNode:self];
                [_fruitsPool addObject:cloneFruit];
                cloneInfo = nil;
                cloneFruit = nil;
                fruit.hasClone = true;
                _totFruitClones++;
                //CCLOG(@"Tree %@: Cloning fruit %d (z %d) with new tag %d (z %d) (children %d, total clones %d)", tree.info.frameName, fruit.tag, fruit.info.z, cloneInfo.tag, cloneInfo.z, self.children.count, _totFruitClones);
            }
        }
    }
    
    tree.fruitCreated = false;
}


/*-(void)countFruits
{
    int totSaved = 0;
    int totRotten = 0;
    
    CCNode *node;
    CCARRAY_FOREACH(_fruitLayer.children, node)
    {
        if ([node isKindOfClass:[FruitNodeForTree class]]) 
        {
            FruitNodeForTree *fruit = (FruitNodeForTree *)node;
            if(fruit.inTruck)
            {
                totSaved++;
            }
            if(fruit.rottenState == RottenStateInit)
            {
                totRotten++;
            }
        }
    }
    _totFruitsSaved = totSaved;
    _totFruitsRotten = totRotten;
}*/

-(void)dealloc
{
    // TODO: might need to implement remove bodies here to remove/destroy the trees
    [_fruitCloneTags release];
    [_fruitsPool release];
    [_treesPool release];
    [_fruitLayer release];
    [_treeLayer release];
    
    _fruitCloneTags = nil;
    _fruitsPool = nil;
    _treesPool = nil;
    
    _treeLayer = nil;
    _fruitLayer = nil;
    
    _layer = nil;
    _info = nil;
    
    [super dealloc];
}

@end
