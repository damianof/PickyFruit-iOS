//
//  TreeSystemNode.h
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCLayerWithWorld;
@class TreeSystemInfo;
@class TreeNode;


@interface TreeSystemNode : CCNode 
{
    CCLayerWithWorld *_layer;
    TreeSystemInfo *_info;
    NSMutableArray* _treesPool;
    bool _treesCreated;
    
    float _elapsed;
    CGRect _screenRect;
    int _totFruitsSaved;
    float _treeSpeed;
}

@property (nonatomic, readonly) int totFruitsSaved;

+(id)createWithLayer:(CCLayerWithWorld*)layer
      treeSystemInfo:(TreeSystemInfo*)tsi;

-(id)initWithLayer:(CCLayerWithWorld*)layer
    treeSystemInfo:(TreeSystemInfo*)tsi;

-(void)emitTrees;
-(void)updateTreePosition:(ccTime)dt;
-(void)addFruitsSaved:(int)value;

@end
