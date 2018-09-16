//
//  FruitSlotSpinner.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface FruitSlotSpinner : CCNode
{
    NSDictionary *_spritesDict;
    
    NSString *_targetFrameName;
    bool _targetReached;
    
    // Holds the current node being displayed
	int _currentNodeIndex;
	
	// A count of the total nodes available
	int _totalNodes;
    
    int _cellWidth;
    int _gap;
}

@property (nonatomic, readonly) int cellWidth;
@property (nonatomic, readonly) NSString *targetFrameName;
@property (nonatomic, readonly) bool targetReached;

+(id)createWithSpritesDict:(NSDictionary *)spritesDict
           targetFrameName:(NSString*)targetFrameName
                 cellWidth:(int)cellWidth
                       gap:(int)gap;
-(id)initWithSpritesDict:(NSDictionary *)spritesDict
         targetFrameName:(NSString*)targetFrameName
               cellWidth:(int)cellWidth
                     gap:(int)gap;

-(bool)checkForTargetReached;

-(void) moveToTarget;
-(void) moveToCell:(int)nodeIndex;
//-(void) moveToNextCell;
//-(void) moveToPreviousCell;


@end
