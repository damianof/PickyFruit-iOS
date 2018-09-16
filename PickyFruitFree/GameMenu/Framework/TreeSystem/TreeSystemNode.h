//
//  TreeSystemNode.h
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@class CCLayerWithWorld;
@class TreeSystemInfo;
@class TreeNode;
@class FruitNodeForTree;
@class LevelGoal;


@interface TreeSystemNode : CCNode 
{
    CCLayerWithWorld *_layer;
    TreeSystemInfo *_info;
    NSString *_framesFileName;
    
    CGRect _screenRect;
    CCArray* _treesPool;
    bool _treesCreated;
    
    float _elapsed;
    float _treeSpeed;
    CCNode* _treeLayer;
    int _fruitCloneTagIncreaser;
    int _fruitNewTagIncreaser;
    int _cloneTagIncreaser;
    
    NSMutableDictionary *_fruitPool;
    bool _fruitPoolUpdating;
    int _fruitTagMultipler;
    int _totFruitClones;
    NSMutableDictionary *_fruitCloneTags;
    NSMutableDictionary *_goalFruitToRecreate;
    CCNode* _fruitLayer;
    
    float _pixelsToMove;
    
    int _prevRandomTreeIndex;
}

@property (nonatomic, readwrite) float treeSpeed;

+(id)createWithLayer:(CCLayerWithWorld*)layer
      treeSystemInfo:(TreeSystemInfo*)tsi;

-(id)initWithLayer:(CCLayerWithWorld*)layer
    treeSystemInfo:(TreeSystemInfo*)tsi;

-(void)emitTrees;
-(void)updateTreePosition:(ccTime)dt;

-(void)addFruit:(FruitNodeForTree *)fruit
        poolkey:(NSString*)poolkey
           tree:(TreeNode*)tree;
-(void)emitFruit:(TreeNode*)tree;

-(void)recreateGoalFruit;
-(void)recreateMissingFruit:(TreeNode*)tree;

-(void)receiveMissingFruitName:(NSString*)fruitName
                     levelGoal:(LevelGoal*)levelGoal
                         saved:(bool)saved;

@end
