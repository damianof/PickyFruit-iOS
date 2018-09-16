//
//  EnemySystemInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/26/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnemySystemInfo : NSObject
{
    NSArray *_enemiesInfo;
    NSString *_framesFileName;
    NSString *_imageFormat;
    
    bool _active;
    float _unitsYOffset;
    
    float _emissionDelay;
    int _emissionRate;
    float _emissionInterval;
    int _emissionStopAfter;
    
    float _positionXVariation;
    float _positionYVariation;
    
    float _enemySpeed;
}

//<EnemySystem Active="true" EmissionDelay="2" EmissionRate="5" EmissionInterval="1.5" EmissionStopAfter="5" EnemySpeed="0.15">

@property (nonatomic, retain) NSArray *enemiesInfo;
@property (nonatomic, copy) NSString *framesFileName;
@property (nonatomic, copy) NSString *imageFormat;

@property (nonatomic, assign) bool active;
@property (nonatomic, assign) float unitsYOffset;

@property (nonatomic, assign) float emissionDelay;
@property (nonatomic, assign) int   emissionRate;
@property (nonatomic, assign) float emissionInterval;
@property (nonatomic, assign) int emissionStopAfter;

@property (nonatomic, assign) float enemySpeed;

@property (nonatomic, assign) float positionXVariation;
@property (nonatomic, assign) float positionYVariation;


+(id)createWithEnemiesInfo:(NSArray *)enemiesInfo
            framesFileName:(NSString *)ffn
               imageFormat:(NSString *)format
                    active:(bool)a
             emissionDelay:(float)ed
              emissionRate:(int)er
          emissionInterval:(float)ei
         emissionStopAfter:(float)esf
                enemySpeed:(float)es;

-(id)initWithEnemiesInfo:(NSArray *)enemiesInfo
          framesFileName:(NSString *)ffn
             imageFormat:(NSString *)format
                  active:(bool)a
           emissionDelay:(float)ed
            emissionRate:(int)er
        emissionInterval:(float)ei
       emissionStopAfter:(float)esf
              enemySpeed:(float)es;
@end
