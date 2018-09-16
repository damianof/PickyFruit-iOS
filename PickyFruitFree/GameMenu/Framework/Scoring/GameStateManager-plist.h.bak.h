//
//  GameStateManager.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"
#import "Level.h"


@interface GameStateManager : NSObject 
{
    NSMutableDictionary *_levels;
}

@property (nonatomic, retain) NSMutableDictionary *levels;

+(id)sharedGameManager;
-(void)readPlist;
-(void)writePlist;

-(NSMutableDictionary*)createLevelDataDictWithScore:(int)s;

-(int)getLevelScore:(int)ln;
-(void)setLevelScore:(int)ln
               score:(int)s;
-(int)getTotalScore;

@end
