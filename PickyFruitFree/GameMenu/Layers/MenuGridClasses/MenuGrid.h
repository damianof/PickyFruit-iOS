#import "cocos2d.h"

@class MenuGridItem;


typedef enum
{
	kMenuGridFillColumnsFirst,
	kMenuGridFillRowsFirst,
} EMenuGridFillStyle;


@interface MenuGrid : CCLayer //CCLayerColor //<CCRGBAProtocol>
{
	MenuGridItem *_selectedItem;
	
	CGPoint _padding;
}

// aligns items in grid, filling either rows or columns first before going to the next
+(id) menuWithFillStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit 
                padding:(CGPoint)padding
                 target:(id)target
               selector:(SEL)selector;

-(id) initWithFillStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit 
                padding:(CGPoint)padding
                 target:(id)target
               selector:(SEL)selector;

-(void) layoutWithStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit;


@end
