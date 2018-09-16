//
//  Level.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Level : NSObject 
{
    NSNumber *_number;
    NSNumber *_score;
}

@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSNumber *score;

-(id)initWithNumber:(int)n 
           andScore:(int)s;

@end
