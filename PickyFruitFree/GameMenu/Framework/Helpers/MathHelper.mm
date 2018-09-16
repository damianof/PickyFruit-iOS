//
//  MathHelper.mm
//
//  Created by Damiano Fusco on 3/31/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "MathHelper.h"
#import "stdlib.h"

//static int _previousRandomNumber;


@implementation MathHelper

+(int)randomNumberBetween:(int)min 
                    andMax:(int)max 
{
    if(max > min || min > max)
    {
        int range = max > min ? (max - min) : (min - max);
        int random = (arc4random() % range) + min;
        /*if(random == _previousRandomNumber)
        {
            random = (_previousRandomNumber+1) > max ? _previousRandomNumber-1 : (_previousRandomNumber+1);
        }*/
        return random;
    }
    else
    {
        return 0;
    }
}

+(int)randomNumberBetween:(int)min 
                   andMax:(int)max 
                  notLike:(int)notlikethis
{
    int random = [MathHelper randomNumberBetween:min andMax:max];
    if(random == notlikethis)
    {
        random = (random+1) <= max // try to increase by one if not greater than max
            ? (random+1) 
            : (random-1)>= min
                ? (random-1)
                : random = [MathHelper randomNumberBetween:min andMax:max]; // try once more
    }
    return random;
}

+(float)randomFloatBetween:(float)min
                    andMax:(float)max
{
    float diff = max - min;
    float random = (((float) arc4random() / UINT32_MAX) * diff) + min;
    return random;
}


@end
