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
#import "ActorInfo.h"
#import "TreeNode.h"
#import "FruitNodeForTree.h"
#import "FruitSlotInfo.h"



#define kFruitTagIncreaser2 = 20000;

typedef enum{
    TreeSystemTagINVALID = 0,
    TreeSystemTagBatchNode1,
    TreeSystemTagBatchNode2,
    TreeSystemTagTreeLayer,
    TreeSystemTagFruitLayer,
    TreeSystemTagMAX
} TreeSystemTags;


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
        CCLOG(@"TreeSystem: init");
        
        _fruitCloneTags = [[NSMutableDictionary alloc] initWithCapacity:32];
        _treesPool = [[CCArray alloc] initWithCapacity:4];
        _fruitsPool = [[CCArray alloc] initWithCapacity:32];
        
        _framesFileName = [tsi.framesFileName copy];
        
        GameManager *sharedGameManager = [GameManager sharedInstance];
        
        // add frames file
        if ([tsi.imageFormat isEqualToString:kImageFormatPvrCcz]) 
        {
            //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:tsi.framesFileName] z:0 tag:TreeSystemTagBatchNode1]; 
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileFruit32] z:0 tag:TreeSystemTagBatchNode2];
        }
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:tsi.framesFileName];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileFruit32]; 
        
        //CCTexture2D *gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:tsi.textureImage];
        //[self addChild:[CCSpriteBatchNode batchNodeWithTexture:gameArtTexture]];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:tsi.framesFileName];
        
        _layer = layer;
        _info = tsi;
        _treesCreated = false;
        _fruitCloneTagIncreaser = 10000;
        _fruitNewTagIncreaser = 10000;
        _cloneTagIncreaser = 1000;
        
        _treeLayer = [[CCNode alloc] init];
        [self addChild:_treeLayer z:1 tag:TreeSystemTagTreeLayer];
        _fruitLayer = [[CCNode alloc] init];
        [self addChild:_fruitLayer z:2 tag:TreeSystemTagFruitLayer];
        
        _screenRect = [DevicePositionHelper screenRect];
        UnitsSize screenSize = [DevicePositionHelper screenUnitsRect].size;
        _pixelsToMove = [DevicePositionHelper pixelsToMove];
        _treeSpeed = _info.speed;
        
        //_screenCenter = [DevicePositionHelper screenCenter];
        //CCLOG(@"ParallaxBackground: %f %f", _screenRect.size.width, _screenRect.size.height);
        
        _fruitTagMultipler = 1;
        _totFruitClones = 0;
        
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
            
            TreeNode *tree = [[TreeNode alloc] initWithLayer:_layer
                                                    treeInfo:treeInfo
                                                    position:treeInitialPosition];
            tree.speed = _treeSpeed;
            tree.sprite.opacity = 0;
            [tree setTreeSystemNode:self];
            [_treeLayer addChild:tree z:treeInfo.z tag:treeInfo.tag];
            
            previousTree = tree;
            [_treesPool addObject:tree];
            
            // add xml fruits to fruits pool
            for (ActorInfo *fi in treeInfo.actorsInfo) 
            {
                //b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:treeInfo.fruitRegion];
                FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
                fruitSlot.filled = true;
                FruitNodeForTree *fruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                             info:fi
                                                                  initialPosition:fruitSlot.position];
                [fruit setSlotInfo:fruitSlot];
                fruitSlot = nil;
                fruit.parentTreeTag = treeInfo.tag;
                fruit.sprite.opacity = 0;
                [fruit setTreeSystemNode:self];
                [_fruitsPool addObject:fruit];
                [fruit release];
                fruit = nil;
                
                NSString* key = [[NSString alloc] initWithFormat:kStringFormatFruitCloneKey, treeInfo.tag, fi.frameName];
                [_fruitCloneTags setValue:[NSNumber numberWithInt:(fi.tag+_cloneTagIncreaser)] forKey:key];
                [key release];
                key = nil;
            }
            [tree release];
            tree = nil;
        }

        // add additional fruit based on game levels amounts
        TreeInfo *lastTreeInfo = (TreeInfo*)[_info.treesInfo lastObject];
        //ActorInfo *modelInfo = (ActorInfo *)[lastTreeInfo.actorsInfo lastObject];
        int lastFruitTag = ((ActorInfo *)[lastTreeInfo.actorsInfo lastObject]).tag;
        lastTreeInfo = nil;
        TreeInfo *randomTreeInfo = nil;
        for (LevelGoal *goal in sharedGameManager.currentGameLevel.levelGoals)
        {
            ActorInfo *infoToUse = nil;
            bool found = false;
            for (TreeInfo *treeInfo in _info.treesInfo) 
            {
                for (ActorInfo *fi in treeInfo.actorsInfo) 
                {
                    if ([goal.fruitName isEqualToString:fi.frameName]) {
                        found = true;
                        infoToUse = [fi cloneWithNewTag:fi.tag+(_fruitCloneTagIncreaser++)];
                        CCLOG(@"TreeSystem: found goal fruit in xml tree info");
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
                CCLOG(@"TreeSystem: found false: create brand new");
                fruitCounterStart = 0;
                // if goal fruit is not part of the tree info, create a new one
                //infoToUse = [modelInfo cloneWithNewTag:modelInfo.tag + (tag2Increaser++)];             
                //infoToUse.frameName = goal.fruitName;
                infoToUse = [ActorInfo createFruitInfo:goal.fruitName
                                                   tag:lastFruitTag + (_fruitNewTagIncreaser++)];
            }
            
            // spread the target number of fruits randomly on the trees
            for(int i = fruitCounterStart; i <= goal.target; i++)
            {
                CCLOG(@"TreeSystem: spread the goal target number of fruits");
                ActorInfo *newInfo = [infoToUse cloneWithNewTag:infoToUse.tag + i];             
                int randomTreeIndex = [MathHelper randomNumberBetween:0 andMax:_info.treesInfo.count-1];
                randomTreeInfo = [_info.treesInfo objectAtIndex:randomTreeIndex];
                //CCLOG(@"randomTreeIndex %d", randomTreeIndex);
                
                //b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:randomTreeInfo.fruitRegion];
                //fruitPosition = b2Vec2(fruitPosition.x+0.5, fruitPosition.y+0.5);
                TreeNode *tree = (TreeNode *)[_treeLayer getChildByTag:randomTreeInfo.tag];
                FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
                fruitSlot.filled = true;                
                FruitNodeForTree *newfruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                                info:newInfo
                                                                     initialPosition:fruitSlot.position];
                [newfruit setSlotInfo:fruitSlot];
                newfruit.tag = newInfo.tag;
                newfruit.parentTreeTag = randomTreeInfo.tag;
                newfruit.sprite.opacity = 0;
                [newfruit setTreeSystemNode:self];
                [_fruitsPool addObject:newfruit];
                
                //CCLOG(@"Fruit Goal added: %@ tag %d tag %d (counter %d)", newInfo.frameName, newInfo.tag, newfruit.tag, i);
                [newfruit release];
                newfruit = nil;
                
                if(found == false)
                {
                    //NSString* key = [NSString initWithFormat:@"%d_%@", randomTreeInfo.tag, newInfo.frameName];
                    //[_fruitCloneTags setValue:[NSNumber numberWithInt:(newInfo.tag+1000)] forKey:key];
                    
                    NSString* key = [[NSString alloc] initWithFormat:kStringFormatFruitCloneKey, tree.tag, newInfo.frameName];
                    [_fruitCloneTags setValue:[NSNumber numberWithInt:(newInfo.tag+_cloneTagIncreaser)] forKey:key];
                    [key release];
                    key = nil;
                }
                [newInfo release];
                newInfo =nil;
            }
            
            [infoToUse release];
            infoToUse = nil;
        }
        
        //modelInfo = nil;
        randomTreeInfo = nil;
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)emitTrees
{
    if([GameManager sharedInstance].running)
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
}

-(void)dealloc
{
    CCLOG(@"TreeSystem: dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileFruit32];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:_framesFileName];
    
    [_treeLayer removeAllChildrenWithCleanup:YES];
    [_fruitLayer removeAllChildrenWithCleanup:YES];
    
    [_framesFileName release];
    _framesFileName = nil;
    
    [_fruitCloneTags release];
    _fruitCloneTags = nil;
    [_fruitsPool release];
    _fruitsPool = nil;
    [_treesPool release];
    _treesPool = nil;
    [_fruitLayer release];
    _fruitLayer = nil;
    [_treeLayer release];
    _treeLayer = nil;
    
    _layer = nil;
    _info = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

-(void)onEnter
{
    [super onEnter];
    //CCLOG(@"TreeSystem: onEnter");
    
    [self emitTrees];
}

-(void)onExit
{
    CCLOG(@"TreeSystem: onExit");
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super onExit];
}

-(void)update:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        [self updateTreePosition:dt];
    }
}

-(void)updateTreePosition:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        id child = nil;
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
}

-(void)addFruit:(FruitNodeForTree *)fruit
           tree:(TreeNode*)tree
{
    if([GameManager sharedInstance].running)
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
}

-(void)emitFruit:(TreeNode*)tree
{
    if([GameManager sharedInstance].running)
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
}

-(void)recreateMissingFruit:(TreeNode*)tree
{
    if([GameManager sharedInstance].running)
    {
        // recreate additional fruits by recreating the ones that have been picked/destroyed
        //CCLOG(@"Tree %@: recreateMissingFruit: children count %d (total clones %d)", self.info.frameName, self.children.count, _totFruitClones);
        
        [tree resetSlots]; // set all slots as filled = false
        
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
                    //b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:tree.info.fruitRegion];
                    FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
                    fruitSlot.filled = true;
                    NSString* key = [[NSString alloc] initWithFormat:@"%d_%@", tree.tag, fruit.info.frameName];
                    int cloneTag = [[_fruitCloneTags valueForKey:key] intValue] + _totFruitClones;
                    [key release];
                    key = nil;
                    ActorInfo* cloneInfo = [fruit.info cloneWithNewTag:cloneTag];
                    
                    FruitNodeForTree *cloneFruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                                      info:cloneInfo
                                                                           initialPosition:fruitSlot.position];
                    [cloneFruit setSlotInfo:fruitSlot];
                    cloneFruit.isClone = true;
                    cloneFruit.parentTreeTag = tree.tag;
                    cloneFruit.sprite.opacity = 0;
                    [cloneFruit setTreeSystemNode:self];
                    [_fruitsPool addObject:cloneFruit];
                    [cloneInfo release];
                    cloneInfo = nil;
                    
                    [cloneFruit release];
                    cloneFruit = nil;
                    
                    fruit.hasClone = true;
                    _totFruitClones++;
                    //CCLOG(@"Tree %@: Cloning fruit %d (z %d) with new tag %d (z %d) (children %d, total clones %d)", tree.info.frameName, fruit.tag, fruit.info.z, cloneInfo.tag, cloneInfo.z, self.children.count, _totFruitClones);
                }
            }
        }
        
        // rarely and randomly add Golden Apple
        // throw the dice
        int rnd1 = [MathHelper randomNumberBetween:1 andMax:6];
        int rnd2 = [MathHelper randomNumberBetween:1 andMax:6];
        if(rnd1 + rnd2 == 2)
        {
            CCLOG(@"recreateMissingFruit: LUCKY: golden apple");
            FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
            ActorInfo *infoAppleGolden = [ActorInfo createFruitInfo:kSpriteFrameNameAppleGolden
                                                                tag:4132523415];
            FruitNodeForTree *fruitGolden = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                               info:infoAppleGolden
                                                                    initialPosition:fruitSlot.position];
            [fruitGolden setSlotInfo:fruitSlot];
            fruitGolden.isClone = false;
            fruitGolden.parentTreeTag = tree.tag;
            fruitGolden.sprite.opacity = 0;
            [fruitGolden setTreeSystemNode:self];
            [_fruitsPool addObject:fruitGolden];
            [infoAppleGolden release];
            infoAppleGolden = nil;
            
            [fruitGolden release];
            fruitGolden = nil;
            
            tree.fruitCreated = false;
        }
        //else
        //{
        //    CCLOG(@"recreateMissingFruit: NO LUCK %d", rnd1 + rnd2);
        //}
    }
}

-(void)receivedDestroyedFruitName:(NSString*)fruitName
{
    CCLOG(@"TreeSystemInfo: receivedDestroyedFruitName: %@", fruitName);
    
    // get last tag and random tree and slot
    int lastFruitTag = ((FruitNodeForTree*)[_fruitsPool lastObject]).tag;
    int randomTreeIndex = [MathHelper randomNumberBetween:0 andMax:_info.treesInfo.count-1];
    TreeNode *randomTree = (TreeNode *)[_treeLayer.children objectAtIndex:randomTreeIndex];
    FruitSlotInfo* randomFruitSlot = [randomTree getRandomFruitSlot]; // get from tree fruit slots
    randomFruitSlot.filled = true;
    
    // create new fruit
    ActorInfo *fruitInfo = [ActorInfo createFruitInfo:fruitName
                                                  tag:lastFruitTag + (_fruitNewTagIncreaser++)];
    FruitNodeForTree *newFruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                    info:fruitInfo
                                                         initialPosition:randomFruitSlot.position];
    [newFruit setSlotInfo:randomFruitSlot];
    newFruit.isClone = true;
    newFruit.parentTreeTag = randomTree.tag;
    //newFruit.sprite.opacity = 0;
    [newFruit setTreeSystemNode:self];
    [_fruitsPool addObject:newFruit];
    [fruitInfo release];
    fruitInfo = nil;
    [newFruit release];
    newFruit = nil;
    
    randomTree = nil;
    randomFruitSlot = nil;
     
    // add tag to _fruitCloneTags
    NSString* key = [[NSString alloc] initWithFormat:kStringFormatFruitCloneKey, randomTree.tag, fruitName];
    [_fruitCloneTags setValue:[NSNumber numberWithInt:(fruitInfo.tag+_cloneTagIncreaser)] forKey:key];
    [key release];
    key = nil;
}

@end
