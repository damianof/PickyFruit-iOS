//
//  MenuScroll.h


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MenuScrollItem;
@class GameManager;
@class GameGroup;

@interface MenuScroll : CCLayer 
{
	MenuScrollItem *_selectedItem;
	
	// Holds the current height and width of the screen
	int _scrollHeight;
	int _scrollWidth;
	
	// Holds the height and width of the screen when the class was inited
	int _startHeight;
	int _startWidth;
	
	// Holds the current page being displayed
	int _currentScreen;
	
	// A count of the total screens available
	int _totalScreens;
	
	// The initial point the user starts their swipe
	int _startSwipe;
	bool _swiping;
}

+(id) createWithWidthOffset:(int)widthOffset
                     target:(id)target
                   selector:(SEL)selector;
-(id) initWithWidthOffset:(int)widthOffset
                   target:(id)target
                 selector:(SEL)selector;

-(void) moveToPage:(int)page;
-(void) moveToNextPage;
-(void) moveToPreviousPage;


@end
