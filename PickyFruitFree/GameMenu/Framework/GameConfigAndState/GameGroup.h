//
//  GameGroup.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/29/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetLayerEnum.h"
#import "DevicePositionHelper.h"

@class GameManager;
@class GameConfigAndState;
@class ParallaxInfo;
@class TreeSystemInfo;
@class EnemySystemInfo;
@class TreeSystemNode;


@interface GameGroup : NSObject 
{
    int _number;
    
    int _reqScoreToEnable;
    int _reqStarsToEnable;
    
    bool _active;
    NSString *_labelText;
    //NSString *_groupButtonImage;
    //NSString *_groupButtonImagePressed;
    //NSString *_groupButtonImageDisabled;
    
    //NSString *_levelButtonImage;
    //NSString *_levelButtonImageDisabled;
    
    NSString *_uiBackgroundImage;
    
    TargetLayerEnum _targetLayer;
    
    ParallaxInfo *_parallaxInfo;
    TreeSystemInfo *_treeSystemInfo;
    EnemySystemInfo *_enemySystemInfo;
    NSArray *_staticSpritesInfo;
    NSArray *_actorsInfo;
    
    UnitsRect _skyRegion;
    float _unitsFromEdge;
    float _unitsYOffset;
    float _timeBeforeHail;
    
    int _numberOfTrailers;
    
    // loose reference
    TreeSystemNode* _treeSystem;
}

@property (nonatomic, retain) NSArray *staticSpritesInfo;
@property (nonatomic, retain) NSArray *actorsInfo;

@property (nonatomic, readonly) NSString *labelText;
//@property (nonatomic, readonly) NSString *groupButtonImage;
//@property (nonatomic, readonly) NSString *groupButtonImagePressed;
//@property (nonatomic, readonly) NSString *groupButtonImageDisabled;

//@property (nonatomic, readonly) NSString *levelButtonImage;
//@property (nonatomic, readonly) NSString *levelButtonImageDisabled;

@property (nonatomic, readonly) NSString *uiBackgroundImage;

@property (nonatomic, readonly) bool active;
@property (nonatomic, readonly) int number;
@property (nonatomic, readonly) int reqScoreToEnable;
@property (nonatomic, readonly) int reqStarsToEnable;

@property (nonatomic, retain) ParallaxInfo *parallaxInfo;
@property (nonatomic, retain) TreeSystemInfo *treeSystemInfo;
@property (nonatomic, retain) EnemySystemInfo *enemySystemInfo;

@property (nonatomic, readonly) bool enabled;
@property (nonatomic, readonly) TargetLayerEnum targetLayer;
@property (nonatomic, assign) UnitsRect skyRegion;
@property (nonatomic, assign) float timeBeforeHail;
@property (nonatomic, assign) float unitsFromEdge;
@property (nonatomic, assign) float unitsYOffset;
@property (nonatomic, assign) int numberOfTrailers;


@property (nonatomic, readonly) TreeSystemNode *treeSystem;


+(id)createWithNumber:(int)n 
     reqScoreToEnable:(int)rste 
     reqStarsToEnable:(int)rstarste 
               active:(bool)a 
            labelText:(NSString *)lt
    uiBackgroundImage:(NSString *)ubi
          targetLayer:(TargetLayerEnum)tl
         parallaxInfo:(ParallaxInfo *)pi
       treeSystemInfo:(TreeSystemInfo*)tsi
      enemySystemInfo:(EnemySystemInfo*)esi
    staticSpritesInfo:(NSArray *)ssi
           actorsInfo:(NSArray *)ai;

-(id)initWithNumber:(int)n 
   reqScoreToEnable:(int)rste
   reqStarsToEnable:(int)rstarste  
             active:(bool)a 
          labelText:(NSString *)lt
  uiBackgroundImage:(NSString *)ubi
        targetLayer:(TargetLayerEnum)tl
       parallaxInfo:(ParallaxInfo *)pi
     treeSystemInfo:(TreeSystemInfo*)tsi
    enemySystemInfo:(EnemySystemInfo*)esi
  staticSpritesInfo:(NSArray *)ssi
         actorsInfo:(NSArray *)ai;

// loose reference to TreeSystemNode
-(void)setTreeSystem:(TreeSystemNode*)ts;


@end
