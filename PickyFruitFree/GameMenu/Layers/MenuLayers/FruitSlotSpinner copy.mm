//
//  FruitSlotSpinner.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "FruitSlotSpinner.h"


@implementation FruitSlotSpinner


-(NSString*)targetFrameName
{
    return _targetFrameName;
}

-(bool)targetReached
{
    if(_targetReached == false)
    {
        [self checkForTargetReached];
    }
    return _targetReached;
}

-(int)cellWidth
{
    return _cellWidth;
}

+(id)createWithSpritesDict:(NSDictionary *)spritesDict
           targetFrameName:(NSString*)targetFrameName
                 cellWidth:(int)cellWidth
                       gap:(int)gap
{
    return [[[self alloc] initWithSpritesDict:spritesDict
                              targetFrameName:targetFrameName
                                    cellWidth:cellWidth
                                          gap:gap] autorelease];
}

-(id) initWithSpritesDict:(NSDictionary *)spritesDict 
          targetFrameName:(NSString*)targetFrameName
                cellWidth:(int)cellWidth
                      gap:(int)gap
{
	if ( (self = [super init]) )
	{
        _spritesDict = [spritesDict retain];
        _targetFrameName = targetFrameName;
        _gap = gap;
        _cellWidth = cellWidth;
        _currentNodeIndex = 0;
		
		// Loop through the array and add the nodes
		int i = 0;
        for (CCNode *item in [_spritesDict allValues])
        {
			item.anchorPoint = ccp(0.0f, 1.0f);
			item.position = ccp(0, (int)(i*(_cellWidth+_gap)));
			[self addChild:item z:0 tag:i];
			i++;
		}
        
        // Setup a count of the available nodes
		_totalNodes = i;
	}
    
	return self;
}

- (void) dealloc
{
    //CCLOG(@"CCNodeScroller: dealloc");
    [_spritesDict release];
    _spritesDict = NULL;
    
    _targetFrameName = NULL;
    
    int i = -1;
    while (i++ < _totalNodes) 
    {
        [self removeChild:[self getChildByTag:i] cleanup:YES];
    }
    
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

-(bool)checkForTargetReached
{
    NSString *name = [[_spritesDict allKeys] objectAtIndex:_currentNodeIndex];
    if([name isEqualToString:_targetFrameName])
    {
        _targetReached = true;
    }
    return _targetReached;
}

-(void)moveToTarget
{
    int nodeIndex = 0;
    for(NSString *item in [_spritesDict allKeys])
    {
        if ([item isEqualToString:_targetFrameName])
        {
            break;
        }
        nodeIndex++;
    }
    
    CGPoint pos = ccp(self.position.x, (int)-((nodeIndex-1) * (_cellWidth+_gap)));
    CCActionInterval *actionInterval = [CCMoveTo actionWithDuration:0.1f 
                                                           position:pos];
	id changeNode = [CCEaseBackIn actionWithAction:actionInterval];
	[self runAction:changeNode];
    _currentNodeIndex = nodeIndex;
}

-(void)moveToCell:(int)nodeIndex
{
    //CCLOG(@"Fruit Slot Spinner moveToCell current y %.2f", self.position.y);
    CGPoint pos = ccp(self.position.x, (int)-((nodeIndex-1) * (_cellWidth+_gap)));
    CCActionInterval *actionInterval = [CCMoveTo actionWithDuration:0.1f 
                                                           position:pos];
	id changeNode = [CCEaseBackIn actionWithAction:actionInterval];
	[self runAction:changeNode];
    _currentNodeIndex = nodeIndex;
}
/*
-(void) moveToNextCell
{
    CGPoint pos = ccp(self.position.x, -(((_currentNodeIndex+1)-1)*_scrollHeight));
	id changeNode = [CCEaseBounce actionWithAction:[CCMoveTo actionWithDuration:0.2f 
                                                                       position:pos]];
	[self runAction:changeNode];
	_currentNodeIndex++;
}

-(void) moveToPreviousCell
{
	CGPoint pos = ccp(self.position.x, -(((_currentNodeIndex-1)-1)*_scrollHeight));
	id changeNode = [CCEaseBounce actionWithAction:[CCMoveTo actionWithDuration:0.2f 
                                                                       position:pos]];
	[self runAction:changeNode];
	_currentNodeIndex--;
}
*/

@end
