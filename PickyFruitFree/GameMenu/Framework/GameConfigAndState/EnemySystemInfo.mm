//
//  EnemySystemInfo.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/26/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "EnemySystemInfo.h"
#import "cocos2d.h"

@implementation EnemySystemInfo

@synthesize 
enemiesInfo = _enemiesInfo,
framesFileName =_framesFileName,
imageFormat =_imageFormat,
unitsYOffset = _unitsYOffset,
active = _active,
emissionDelay = _emissionDelay,
emissionRate = _emissionRate,
emissionInterval = _emissionInterval,
emissionStopAfter = _emissionStopAfter,
enemySpeed = _enemySpeed,
positionXVariation = _positionXVariation,
positionYVariation = _positionYVariation;


+(id)createWithEnemiesInfo:(NSArray *)enemiesInfo
            framesFileName:(NSString *)ffn
               imageFormat:(NSString *)format
                    active:(bool)a
             emissionDelay:(float)ed
              emissionRate:(int)er
          emissionInterval:(float)ei
         emissionStopAfter:(float)esa
                enemySpeed:(float)es
{
    return [[[self alloc] initWithEnemiesInfo:enemiesInfo
                               framesFileName:ffn
                                  imageFormat:format 
                                       active:a
                                emissionDelay:ed
                                 emissionRate:er
                             emissionInterval:ei
                            emissionStopAfter:esa
                                   enemySpeed:es] autorelease];
}

-(id)initWithEnemiesInfo:(NSArray *)enemiesInfo
          framesFileName:(NSString *)ffn
             imageFormat:(NSString *)format
                  active:(bool)a
           emissionDelay:(float)ed
            emissionRate:(int)er
        emissionInterval:(float)ei
       emissionStopAfter:(float)esa
              enemySpeed:(float)es
{
    if ((self = [super init])) 
    {
        self.enemiesInfo = enemiesInfo,
        self.framesFileName = ffn,
        self.imageFormat = format,
        
        self.active = a,

        self.emissionDelay = ed,
        self.emissionRate = er,
        self.emissionInterval = ei;
        self.emissionStopAfter = esa;
        
        self.enemySpeed = es;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    CCLOG(@"EnemySystemInfo dealloc");
    
    [_enemiesInfo release];
    _enemiesInfo = nil;
    
    [_framesFileName release];
    _framesFileName = nil;
    
    [_imageFormat release];
    _imageFormat = nil;
    
    [super dealloc];
}


@end
