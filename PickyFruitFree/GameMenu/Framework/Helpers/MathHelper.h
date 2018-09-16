//
//  MathHelper.h
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MathHelper : NSObject {
    
}

+(int)randomNumberBetween:(int)min 
                    andMax:(int)max;

+(int)randomNumberBetween:(int)min 
                   andMax:(int)max 
                  notLike:(int)notlikethis;

+(float)randomFloatBetween:(float)min
                    andMax:(float)max;


@end
