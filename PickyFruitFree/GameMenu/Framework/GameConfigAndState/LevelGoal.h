//
//  LevelGoal.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/7/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LevelGoal : NSObject
{
    NSString *_fruitName;
    int _tag;
    int _target;
    int _currentCount;
    int _stateCount;
    int _prevCount;
    int _oldCount;
}

@property (nonatomic, copy) NSString *fruitName;
@property (nonatomic, readonly) int tag;

@property (nonatomic, readonly) int target;
@property (nonatomic, readonly) int stillNeeded;
@property (nonatomic, readwrite) int currentCount;
@property (nonatomic, readonly) int stateCount;
@property (nonatomic, readonly) int prevCount;

@property (nonatomic, readonly) bool reached;

+(id)createWithTag:(int)tag
         fruitName:(NSString*)fn 
            target:(int)t
        stateCount:(int)sc
         prevCount:(int)pc;

-(id)initWithTag:(int)tag
       fruitName:(NSString*)fn 
          target:(int)t
      stateCount:(int)sc
       prevCount:(int)pc;

-(void)resetGoal;
-(void)prepareForSaving;
-(void)restorePreviousScores;

@end
