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
        
        _goalFruitToRecreate = [[NSMutableDictionary alloc] initWithCapacity:32];
        _fruitCloneTags = [[NSMutableDictionary alloc] initWithCapacity:32];
        _fruitPool = [[NSMutableDictionary alloc] initWithCapacity:32];
        _treesPool = [[CCArray alloc] initWithCapacity:4];
        
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
        
        _layer = layer;
        _info = tsi;
        _treesCreated = false;
        _fruitCloneTagIncreaser = 10000;
        _fruitNewTagIncreaser = 20000;
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
            // set tree initial position outside screen on the right
            //UnitsPoint unitsPoint = UnitsPointMake(screenSize.width, 5);
            UnitsPoint unitsPoint = UnitsPointMake(screenSize.width*0.75f, 5);
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
                
                // add to pool
                NSString *poolKey = [[NSString alloc] initWithFormat:kStringFormatInt, fi.tag];
                [_fruitPool setValue:fruit forKey:poolKey];
                [poolKey release];
                poolKey = nil;
                
                [fruit release];
                fruit = nil;
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
            NSString* goalFruitToRecreateKey = [[NSString alloc] initWithFormat:kStringFormatString, goal.fruitName];
            NSNumber *numberGoalFruitToRecreate = [[NSNumber alloc] initWithInt:kInt0];
            [_goalFruitToRecreate setValue:numberGoalFruitToRecreate forKey:goalFruitToRecreateKey];
            [numberGoalFruitToRecreate release]; numberGoalFruitToRecreate = nil;
            [goalFruitToRecreateKey release]; goalFruitToRecreateKey = nil;
            
            int tagToUse = 0;
            bool found = false;
            for (TreeInfo *treeInfo in _info.treesInfo) 
            {
                for (ActorInfo *fi in treeInfo.actorsInfo) 
                {
                    if ([goal.fruitName isEqualToString:fi.frameName]) {
                        found = true;
                        tagToUse = fi.tag+(_fruitCloneTagIncreaser++);
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
                tagToUse = lastFruitTag + (_fruitNewTagIncreaser++);
            }
            
            // spread the target number of fruits randomly on the trees
            for(int i = fruitCounterStart; i <= goal.target; i++)
            {
                CCLOG(@"TreeSystem: spread the goal target number of fruits");
                //ActorInfo *newInfo = [infoToUse cloneWithNewTag:infoToUse.tag + i]; 
                ActorInfo *newInfo = [ActorInfo createFruitInfo:goal.fruitName
                                                   tag:tagToUse + i];
                int randomTreeIndex = [MathHelper randomNumberBetween:0 andMax:_info.treesInfo.count-1];
                randomTreeInfo = [_info.treesInfo objectAtIndex:randomTreeIndex];
                //CCLOG(@"randomTreeIndex %d", randomTreeIndex);
                
                //b2Vec2 fruitPosition = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:randomTreeInfo.fruitRegion];
                //fruitPosition = b2Vec2(fruitPosition.x+0.5, fruitPosition.y+0.5);
                TreeNode *tree = (TreeNode *)[_treeLayer getChildByTag:randomTreeInfo.tag];
                FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
                fruitSlot.filled = true;                
                FruitNodeForTree *newFruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                                info:newInfo
                                                                     initialPosition:fruitSlot.position];
                [newFruit setSlotInfo:fruitSlot];
                newFruit.parentTreeTag = randomTreeInfo.tag;
                newFruit.sprite.opacity = 0;
                [newFruit setTreeSystemNode:self];
                
                // add to pool
                NSString *poolKey = [[NSString alloc] initWithFormat:kStringFormatInt, newInfo.tag];
                [_fruitPool setValue:newFruit forKey:poolKey];
                [poolKey release];
                poolKey = nil;
                
                //CCLOG(@"Fruit Goal added: %@ tag %d tag %d (counter %d)", newInfo.frameName, newInfo.tag, newfruit.tag, i);
                [newInfo release];
                newInfo =nil;                
                [newFruit release];
                newFruit = nil;
            }
            
            tagToUse = 0;
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
    
    [_goalFruitToRecreate release];
    _goalFruitToRecreate     = nil;
    [_fruitCloneTags release];
    _fruitCloneTags = nil;
    [_fruitPool release];
    _fruitPool = nil;
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

-(void)updateTreePosition:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        id child = nil;
        
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
                
                int spriteWidth = [DevicePositionHelper b2Vec2FromSize:tree.sprite.boundingBox.size].x;
                if(bodyPosition.x > (tree.offsetX1ForOutsideScreen - spriteWidth - 5))
                {
                    if(tree.fruitCreated == false)
                    {
                        [self emitFruit:tree];
                    }
                    else
                    {
                        int direction = -1;
                        b2Vec2 directionToTravel = b2Vec2((direction * (tree.speed * _pixelsToMove)), 0);
                        directionToTravel *= 30 / [DevicePositionHelper pixelsToMeterRatio]; // 60 frames per second * PTM_RATIO
                        tree.body->SetLinearVelocity(directionToTravel);
                    }
                }
                else
                {
                    // recreate additional fruits by recreating the ones that have been picked
                    //[self recreateMissingFruit:tree];
                    
                    b2Vec2 newPosition = tree.initialPosition;
                    float prevx = previousTree.body->GetPosition().x;
                    float prevw = [DevicePositionHelper b2Vec2FromSize:previousTree.sprite.boundingBox.size].x;
                    newPosition = b2Vec2(prevx+prevw+2, newPosition.y);
                    
                    tree.body->SetTransform(newPosition, 0);
                }
                
                // recreate additional fruits by recreating the ones that have been picked
                [self recreateMissingFruit:tree];
                
                previousTree = tree;
            }
        }
    }
}

-(void)update:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        [self updateTreePosition:dt]; 
    }
}

-(void)addFruit:(FruitNodeForTree *)fruit
        poolkey:(NSString*)poolkey
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
                
                _fruitPoolUpdating = true;
                [_fruitPool removeObjectForKey:poolkey];
                _fruitPoolUpdating = false;
                
                fruit.sprite.opacity = 255;
                
                b2Vec2 fruitCenter = fruit.body->GetWorldCenter();
                b2RevoluteJointDef jointFruit;
                // limit fruit rotation
                jointFruit.lowerAngle = -0.5f * b2_pi;
                jointFruit.upperAngle = 0.5f * b2_pi;
                jointFruit.enableLimit = true;
                jointFruit.Initialize(tree.body, fruit.body, fruitCenter);
                _layer.world->CreateJoint(&jointFruit);
            }
        }
    }
}

-(void)emitFruit:(TreeNode*)tree
{
    if([GameManager sharedInstance].running
       && _fruitPool.count > 0 
       && _fruitPoolUpdating == false)
    {
        // CCLOG(@"emitFruit tree initialPosition %f %f", self.initialPosition.x, self.initialPosition.y);
        for(NSString *poolkey in _fruitPool.allKeys)
        {
            FruitNodeForTree *fruit = [_fruitPool valueForKey:poolkey];
            if(fruit.jointsDestroyed == false)
            {
                //CCLOG(@"emitFruit: fruitsPool %@ tag %d tag %d", fruit.info.frameName, fruit.info.tag, fruit.tag);
                [self addFruit:fruit 
                       poolkey:poolkey
                          tree:tree];
            }
            fruit = nil;
        }
        
        tree.fruitCreated = true;
    }
}

-(void)recreateMissingFruit:(TreeNode*)tree
{
    if([GameManager sharedInstance].running
       && _fruitPoolUpdating == false
       && _fruitCloneTags.count > 0)
    {
        // recreate additional fruit by recreating the ones that have been picked/destroyed
        CCLOG(@"recreateMissingFruit: total clones %d", _totFruitClones);

        [tree resetSlots]; // set all slots as filled = false
        
        for(NSString *cloneTagKey in [_fruitCloneTags allKeys])
        {
            NSArray *chunks = [cloneTagKey componentsSeparatedByString:@"_"];
            int treeTagForClone = [(NSString *)[chunks objectAtIndex:0] intValue];
            
            if(treeTagForClone == tree.tag)
            {
                NSString *fruitNameForClone = (NSString *)[chunks objectAtIndex:1];
                int fruitTagForClone = [(NSNumber*)[_fruitCloneTags valueForKey:cloneTagKey] intValue];
                //CCLOG(@"recreateMissingFruit: fruitNameForClone %@ tree %d", fruitNameForClone, tree.tag);
                // 3rd chunk is not used, but I want to see the value in the log here
                CCLOG(@"recreateMissingFruit: _fruitCloneTags chunks: [0]treeTag %d, [1]fruitName %@, [2]num %@", treeTagForClone, fruitNameForClone, (NSString *)[chunks objectAtIndex:2]);
                
                FruitSlotInfo* fruitSlot = [tree getRandomFruitSlot]; // get from tree fruit slots
                fruitSlot.filled = true;
                
                // for fun, set random position within region for recreated fruit
                b2Vec2 newp = [DevicePositionHelper b2Vec2RandomWithinUnitsRect:tree.info.fruitRegion];
                [fruitSlot setNewPosition:newp];
                ActorInfo *newInfo = [ActorInfo createFruitInfo:fruitNameForClone
                                                            tag:fruitTagForClone];
                
                FruitNodeForTree *newFruit = [[FruitNodeForTree alloc] initWithLayer:_layer
                                                                                info:newInfo
                                                                     initialPosition:fruitSlot.position];
                [newFruit setSlotInfo:fruitSlot];
                fruitSlot = nil;
                newFruit.isClone = true;
                newFruit.parentTreeTag = tree.tag;
                newFruit.sprite.opacity = 0;
                [newFruit setTreeSystemNode:self];
                
                // add to pool
                NSString *poolKey = [[NSString alloc] initWithFormat:kStringFormatInt, newInfo.tag];
                [_fruitPool setValue:newFruit forKey:poolKey];
                [poolKey release];
                poolKey = nil;
                
                [newInfo release];
                newInfo = nil;                
                [newFruit release];
                newFruit = nil;
                
                fruitNameForClone = nil;
                
                _totFruitClones++;
                
                // remove recreated fruit from dictionary
                [_fruitCloneTags removeObjectForKey:cloneTagKey];
                
                CCLOG(@"recreateMissingFruit: _fruitPool.count %d", _fruitPool.count);
            }
            
            chunks = nil;
        }
        
        // add Golden Apple (rarely and randomly)
        // throw the dice
        int rnd1 = [MathHelper randomNumberBetween:1 andMax:12];
        int rnd2 = [MathHelper randomNumberBetween:1 andMax:12];
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
            fruitGolden.isClone = true;
            fruitGolden.parentTreeTag = tree.tag;
            fruitGolden.sprite.opacity = 0;
            [fruitGolden setTreeSystemNode:self];
            
            // add to pool
            NSString *poolKey = [[NSString alloc] initWithFormat:kStringFormatInt, infoAppleGolden.tag];
            [_fruitPool setValue:fruitGolden forKey:poolKey];
            [poolKey release];
            poolKey = nil;
            
            [infoAppleGolden release];
            infoAppleGolden = nil;            
            [fruitGolden release];
            fruitGolden = nil;
            
            tree.fruitCreated = false;
        }
    }
}

-(void)recreateGoalFruit
{
    for (LevelGoal *goal in [GameManager currentGameLevel].levelGoals) 
    {
        // get key from dictionary so that we don't have to create a new string
        NSArray *allKeys = [_goalFruitToRecreate allKeys];
        if([allKeys containsObject:goal.fruitName])
        {
            NSString *toRecreateKey = [allKeys objectAtIndex:[allKeys indexOfObject:goal.fruitName]];
            NSNumber *numberToRecreate = (NSNumber *)[_goalFruitToRecreate valueForKey:toRecreateKey];
            
            int toRecreate = numberToRecreate.intValue;
            numberToRecreate = nil;
            
            CCLOG(@"TreeSystemInfo: recreateGoalFruit: %@, toRecreate %d", goal.fruitName, toRecreate);
            
            while(toRecreate > 0) // i.e. target is 5, but only 3 remaining so we need to recreate 2
            {
                // get last tag and random tree and slot
                int lastFruitTag = ((FruitNodeForTree*)[_fruitPool.allValues lastObject]).tag;
                int randomTreeIndex = [MathHelper randomNumberBetween:0 
                                                               andMax:(_info.treesInfo.count-1)
                                                              notLike:_prevRandomTreeIndex];
                _prevRandomTreeIndex = randomTreeIndex;
                TreeNode *randomTree = (TreeNode *)[_treeLayer.children objectAtIndex:randomTreeIndex];
                randomTree.fruitCreated = false;
                
                // add tag to _fruitCloneTags
                int newTag = (lastFruitTag+(_cloneTagIncreaser++)+33777);
                CCLOG(@"TreeSystemInfo: recreateGoalFruit: %@, remainingCount %d, newTag %d", goal.fruitName, toRecreate, newTag);
                NSString* cloneTagKey = [[NSString alloc] initWithFormat:kStringFormatFruitCloneKey, randomTree.tag, goal.fruitName, newTag];
                NSNumber *numberCloneTag = [[NSNumber alloc] initWithInt:newTag];
                [_fruitCloneTags setValue:numberCloneTag forKey:cloneTagKey];
                [numberCloneTag release]; numberCloneTag = nil;
                [cloneTagKey release]; cloneTagKey = nil;
                
                //[self recreateMissingFruit:randomTree];
                randomTree = nil;
                
                toRecreate--;
            }
            
            // reset goal fruit to recreate count
            NSNumber *newNumberToRecreate = [[NSNumber alloc] initWithInt:kInt0];
            [_goalFruitToRecreate setValue:newNumberToRecreate forKey:toRecreateKey];
            [newNumberToRecreate release];
            newNumberToRecreate = nil;
        }
    }
}

-(void)receiveMissingFruitName:(NSString*)fruitName
                     levelGoal:(LevelGoal*)levelGoal
                         saved:(bool)saved
{
    if([fruitName isEqualToString:kSpriteFrameNameAppleGolden] == false)
    {
        // check if this is a goal fruit:
        NSArray *allKeys = [_goalFruitToRecreate allKeys];
        if(saved == false
           && [allKeys containsObject:fruitName])
        {
            // goal fruit, decrease lookup count in _goalFruitsRemaining if needed
            int stillNeeded = 2;
            bool goalReached = false;
            if(levelGoal)
            {
                goalReached = levelGoal.reached;
                stillNeeded = levelGoal.stillNeeded+2;
            }
            
            if(goalReached == false)
            {
                // decrease count in _goalFruitRemaining lookup
                NSString *key = [allKeys objectAtIndex:[allKeys indexOfObject:fruitName]];
                NSNumber *newNumber = [[NSNumber alloc] initWithInt:stillNeeded];
                [_goalFruitToRecreate setValue:newNumber forKey:key];
                [newNumber release];
                newNumber = nil;
                
                CCLOG(@"TreeSystemInfo: receiveMissingFruitName: %@, stillNeeded %d", fruitName, stillNeeded);
                
                [self recreateGoalFruit];
            }
        }
        else
        {
            // non-goal fruit, recreate one
            CCLOG(@"TreeSystemInfo: receiveMissingFruitName: %@, non-goal fruit, recreate one", fruitName);
            
            // get last tag and random tree and slot
            int lastFruitTag = ((FruitNodeForTree*)[_fruitPool.allValues lastObject]).tag;
            int randomTreeIndex = [MathHelper randomNumberBetween:0 
                                                           andMax:(_info.treesInfo.count-1)
                                                          notLike:_prevRandomTreeIndex];
            _prevRandomTreeIndex = randomTreeIndex;
            TreeNode *randomTree = (TreeNode *)[_treeLayer.children objectAtIndex:randomTreeIndex];
            randomTree.fruitCreated = false;
            
            // add tag to _fruitCloneTags
            NSString* key = [[NSString alloc] initWithFormat:kStringFormatFruitCloneKey, randomTree.tag, fruitName, 1];
            NSNumber *numberCloneTag = [[NSNumber alloc] initWithInt:(lastFruitTag+(_cloneTagIncreaser++)+33777)];
            [_fruitCloneTags setValue:numberCloneTag forKey:key];
            [numberCloneTag release]; numberCloneTag = nil;
            [key release]; key = nil;
            
            randomTree = nil;
        }
    }
}

@end
