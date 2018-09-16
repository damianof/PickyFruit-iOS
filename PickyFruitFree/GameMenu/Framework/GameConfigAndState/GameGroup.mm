//
//  GameGroup.m
//  GameMenu
//
//  Created by Damiano Fusco on 4/29/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameGroup.h"
#import "GameManager.h"
#import "GameConfigAndState.h"
#import "ParallaxInfo.h"
#import "TreeSystemInfo.h"
#import "EnemySystemInfo.h"

@implementation GameGroup


@synthesize
    labelText = _labelText,
    parallaxInfo = _parallaxInfo,
    treeSystemInfo = _treeSystemInfo,
    enemySystemInfo = _enemySystemInfo,
    staticSpritesInfo = _staticSpritesInfo,
    actorsInfo = _actorsInfo,
    skyRegion = _skyRegion,
    timeBeforeHail = _timeBeforeHail,
    numberOfTrailers =_numberOfTrailers,
    unitsFromEdge = _unitsFromEdge,
    unitsYOffset = _unitsYOffset;

-(int)number
{
    return _number;
}

-(bool)active
{
    return _active;
}

-(int)reqScoreToEnable
{
    return _reqScoreToEnable;
}

-(int)reqStarsToEnable
{
    return _reqStarsToEnable;
}

-(NSString*)labelText
{
    return _labelText;
}

-(TargetLayerEnum)targetLayer
{
    return _targetLayer;
}

/*
 -(NSString*)groupButtonImage
 {
 return _groupButtonImage;
 }
 
 -(NSString*)levelButtonImage
 {
 return _levelButtonImage;
 }
 
-(NSString*)groupButtonImagePressed
{
    return _groupButtonImagePressed;
}

-(NSString*)groupButtonImageDisabled
{
    return _groupButtonImageDisabled;
}

-(NSString*)levelButtonImageDisabled
{
    return _levelButtonImageDisabled;
}*/

-(NSString*)uiBackgroundImage
{
    return _uiBackgroundImage;
}

-(bool)enabled
{
    bool retVal = false;
    
    // unlocked mode override
    if([GameManager allLevelsUnlocked])
    {
        retVal = true;
    }
    else
    {
        int totScore = [GameManager totalScore];
        int totStars = [GameManager totalStars];
        
        retVal = totScore >= _reqScoreToEnable;
        retVal = retVal || (totStars >= _reqStarsToEnable);
    }
    
    return retVal;
}

-(void)setTreeSystem:(TreeSystemNode*)ts
{
    _treeSystem = ts;
}

-(TreeSystemNode *)treeSystem
{
    return _treeSystem;
}

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
           actorsInfo:(NSArray *)ai
{
    return [[[self alloc] initWithNumber:n 
                        reqScoreToEnable:rste
                        reqStarsToEnable:rstarste  
                                  active:a 
                               labelText:lt
                       uiBackgroundImage:ubi
                             targetLayer:tl
                            parallaxInfo:pi
                          treeSystemInfo:tsi
                         enemySystemInfo:esi
                       staticSpritesInfo:ssi
                              actorsInfo:ai] autorelease];
}

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
         actorsInfo:(NSArray *)ai
{
    if ((self = [super init])) 
    {
        //CCLOG(@"GameGroup: init: staticSpritesInfo Retain Count %d", ssi.retainCount);
        //CCLOG(@"GameGroup: init: actorsInfo Retain Count %d", ai.retainCount);
        
        self.staticSpritesInfo = ssi,
        self.actorsInfo = ai,
        self.parallaxInfo = pi,
        self.treeSystemInfo = tsi,
        self.enemySystemInfo = esi;
        
        //CCLOG(@"GameGroup: initB: staticSpritesInfo Retain Count %d", ssi.retainCount);
        //CCLOG(@"GameGroup: initB: actorsInfo Retain Count %d", ai.retainCount);
        
        _labelText = [lt retain],
        _uiBackgroundImage = [ubi retain],
        
        //_groupButtonImagePressed = [[NSString alloc] initWithFormat:kStringFormatButtonPressedImageName, _groupButtonImage];
        //_groupButtonImageDisabled = [[NSString alloc] initWithFormat:kStringFormatButtonDisabledImageName, _groupButtonImage];
        //_levelButtonImageDisabled = [[NSString alloc] initWithFormat:kStringFormatButtonDisabledImageName, _levelButtonImage];
        
        self.unitsFromEdge = 0,
        self.unitsYOffset = 0,
        
        _targetLayer = tl,
        
        _active = a,
        _number = n,
        _reqScoreToEnable = rste,
        _reqStarsToEnable = rstarste;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    [_labelText release];
    //[_groupButtonImage release];
    //[_groupButtonImagePressed release];
    //[_groupButtonImageDisabled release];
    
    //[_levelButtonImage release];
    //[_levelButtonImageDisabled release];
    
    [_uiBackgroundImage release];
    
    _labelText = nil;
    //_groupButtonImage = nil;
    //_groupButtonImagePressed = nil;
    //_groupButtonImageDisabled = nil;
    
    //_levelButtonImage = nil;
    //_levelButtonImageDisabled = nil;
    
    _uiBackgroundImage = nil;
    
    //NSAssert(_staticSpritesInfo.retainCount == 1, @"GameGroup dealloc: _staticSpritesInfo retainCount != 1");
    //CCLOG(@"GameGroup dealloc: _staticSpritesInfo Retain Count %d", _staticSpritesInfo.retainCount);
    //NSAssert(_actorsInfo.retainCount == 1, @"GameGroup dealloc: _actorsInfo retainCount != 1");
    //CCLOG(@"GameGroup dealloc: _actorsInfo Retain Count %d", _actorsInfo.retainCount);
    
    [_staticSpritesInfo release];
    [_actorsInfo release];
    
    _staticSpritesInfo = nil;
    _actorsInfo = nil;
    
    //NSAssert(_parallaxInfo.retainCount == 1, @"GameGroup dealloc: _parallaxInfo retainCount != 1");
    //CCLOG(@"GameGroup dealloc: _parallaxInfo Retain Count %d", _parallaxInfo.retainCount);
    //NSAssert(_enemySystemInfo.retainCount == 1, @"GameGroup dealloc: _enemySystemInfo retainCount != 1");
    //CCLOG(@"GameGroup dealloc: _enemySystemInfo Retain Count %d", _enemySystemInfo.retainCount);
    //NSAssert(_treeSystemInfo.retainCount == 1, @"GameGroup dealloc: _treeSystemInfo retainCount != 1");
    //CCLOG(@"GameGroup dealloc: _treeSystemInfo Retain Count %d", _treeSystemInfo.retainCount);
    
    [_parallaxInfo release];
    [_enemySystemInfo release];
    [_treeSystemInfo release];
    
    _parallaxInfo = nil;
    _enemySystemInfo = nil;
    _treeSystemInfo = nil;
    
    [super dealloc];
}

@end
