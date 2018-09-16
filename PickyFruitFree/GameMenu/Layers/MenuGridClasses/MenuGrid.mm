#import "MenuGrid.h"
#import "MenuGridItem.h"
#import "GameManager.h"
#import "GameConfigAndState.h"
#import "GameGroup.h"
#import "GameLevel.h"
#import "DevicePositionHelper.h"


@interface MenuGrid (Private)
-(MenuGridItem*) itemForTouch:(UITouch*)touch;
@end


@implementation MenuGrid


+(id) menuWithFillStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit 
                padding:(CGPoint)padding
                 target:(id)target
               selector:(SEL)selector
{
	return [[[self alloc] initWithFillStyle:fillStyle 
                                  itemLimit:itemLimit 
                                    padding:padding
                                     target:target
                                   selector:selector] autorelease];
}

-(id) initWithFillStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit 
                padding:(CGPoint)padding
                 target:(id)target
               selector:(SEL)selector
{
    //if ((self = [super initWithColor:ccc4(255,255,255,0)]))
    if ((self = [super init]))
    {
        // Make sure the layer accepts touches
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
		//self.isTouchEnabled = YES;
        self.isRelativeAnchorPoint = YES;
        
		_padding = padding;
        
        GameManager *gameManager = [GameManager sharedInstance];
        int gn = [GameManager groupNumberSelected];
        GameGroup *gameGroup = [gameManager.gameConfigAndState getGroupByNumber:gn];
        NSArray *gameLevels = gameManager.gameConfigAndState.levels;
        
        int z = 0;
		for (GameLevel *gameLevel in gameLevels)
        {
            if(gameGroup.enabled 
               && gameLevel.groupNumber == gn)
            {
                MenuGridItem *item = [[MenuGridItem alloc] initWithFntFile:kBmpFontDigits32SkyBlue 
                                                                  fontSize:kFloat0Point75 
                                                                   enabled:gameLevel.enabled 
                                                                    number:gameLevel.number 
                                                                     stars:gameLevel.stateStars
                                                                    target:target 
                                                                  selector:selector];
                item.tag = gameLevel.number;                
                
                // add child
                [self addChild:item z:z tag:item.tag];
                
                [item release];
                item = nil;
                ++z;
            }
        }
		
		[self layoutWithStyle:fillStyle itemLimit:itemLimit];
	}
	
	return self;
}

-(void)dealloc
{
	CCLOG(@"MenuGrid dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

-(void)onExit
{
	//CCLOG(@"MenuGrid onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

-(void) layoutWithStyle:(EMenuGridFillStyle)fillStyle 
              itemLimit:(int)itemLimit;
{
	int col = 0, row = 0, itemCount = 0;
    
    // get single item size
    MenuGridItem *temp = [self.children lastObject];
    CGSize itemSize = temp.boundingBox.size;
    CGPoint itemAnchorPoint = cgzero;
    
    // calculate Menugrid size
    int totalItems = self.children.count;
    int colLimit = itemLimit;
    int rowLimit = floor(totalItems / itemLimit);
    int gridWidth = (itemSize.width * colLimit) + (_padding.x * (colLimit-1));
    int gridHeight = (itemSize.height * rowLimit) + (_padding.y * (rowLimit-1));
    self.contentSize = CGSizeMake(gridWidth, gridHeight);
    
    //CCLOG(@"MenuGrid anchor is: %f %f", self.anchorPoint.x, self.anchorPoint.y);
    //CCLOG(@"MenuGrid position is: %f %f", self.position.x, self.position.y);
    //CCLOG(@"MenuGrid size is: %f %f", self.size.width, self.size.height);
    
	for (MenuGridItem *item in self.children)
	{
		CGPoint newPosition = CGPointMake((col * (itemSize.width + _padding.x)), ((rowLimit-row-1) * (itemSize.height + _padding.y)));
        item.anchorPoint = itemAnchorPoint;
		item.position = newPosition;
		++itemCount;
        
		if (fillStyle == kMenuGridFillColumnsFirst)
		{
			++col;
			if (itemCount == itemLimit)
			{
				itemCount = 0;
				col = 0;
				++row;
			}
		}
		else
		{
			++row;
			if (itemCount == itemLimit)
			{
				itemCount = 0;
				row = 0;
				++col;
			}
		}
	}
}

// similar to CCMenu
-(void)addChild:(CCNode*)child z:(int)z tag:(int)aTag
{
    //CCLOG(@"%@", [child class]);
	NSAssert([child isKindOfClass:[MenuGridItem class]], @"MenuGrid only supports MenuGridItem objects as children");
	[super addChild:child z:z tag:aTag];
}

// touch handling
-(MenuGridItem*)itemForTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView:touch.view];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	for (MenuGridItem *item in self.children)
	{
		CGPoint local = [item convertToNodeSpace:touchLocation];
		
		CGRect r = item.boundingBox;
		r.origin = CGPointZero;
		
		if (CGRectContainsPoint(r, local))
		{
			return item;
		}
	}
	
	return nil;
}

-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
    _selectedItem = nil;
	_selectedItem = [self itemForTouch:touch];
	
	if (_selectedItem 
        && _selectedItem.enabled)
	{
		_selectedItem.color = kColorLevelButtonHighlight;
        return YES;
	}
	
	return NO;
}

-(void)ccTouchCancelled:(UITouch *)touch 
              withEvent:(UIEvent *)event
{
    if(_selectedItem 
       && _selectedItem.enabled)
    {
        _selectedItem.color = ccWHITE;
    }
}

-(void)ccTouchMoved:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
	MenuGridItem *currentItem = [self itemForTouch:touch];
    
	if (currentItem != _selectedItem)
	{
		if(_selectedItem 
           && _selectedItem.enabled)
        {
            _selectedItem.color = ccWHITE;
        }
		_selectedItem = currentItem;
        if(_selectedItem 
           && _selectedItem.enabled)
        {
            _selectedItem.color = kColorLevelButtonHighlight;
        }
    }
}

-(void)ccTouchEnded:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
	MenuGridItem *currentItem = [self itemForTouch:touch];
    if(_selectedItem 
       && _selectedItem.enabled)
    {
        _selectedItem.color = ccWHITE;
    }
    
	if (currentItem != _selectedItem)
	{
		_selectedItem = currentItem;
    }
    
    if(_selectedItem 
       && _selectedItem.enabled)
    {
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        if(_selectedItem){
            [_selectedItem activate];
        }
    }
}

@end
