//
//  MenuScroll.m


#import "MenuScroll.h"
#import "MenuScrollItem.h"
#import "GameManager.h"
#import "GameConfigAndState.h"
#import "GameGroup.h"
#import "DevicePositionHelper.h"


@implementation MenuScroll

+(id)createWithWidthOffset:(int)widthOffset
                    target:(id)target
                  selector:(SEL)selector
{
    return [[[self alloc] initWithWidthOffset:widthOffset
                                       target:target
                                     selector:selector] autorelease];
}

-(id) initWithWidthOffset:(int)widthOffset
                   target:(id)target
                 selector:(SEL)selector
{
	if ( (self = [super init]) )
    //if ((self = [super initWithColor:ccc4(0,255,0,60)]))
    {
		// Make sure the layer accepts touches
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                         priority:1 
                                                  swallowsTouches:YES];
		_currentScreen = 1;
        CGSize spriteSize = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ButtonGroupLevels1"].rect.size;
        
        // offset added to show preview of next/previous screens
        //int screenWidth = [[CCDirector sharedDirector] winSize].width;
		_scrollWidth = (spriteSize.width*kFloat1Point5); //[[CCDirector sharedDirector] winSize].width - widthOffset;
		_scrollHeight = [[CCDirector sharedDirector] winSize].height;
		_startWidth = _scrollWidth;
		_startHeight = _scrollHeight;
        
        //----------------
        
        GameManager *gameManager = [GameManager sharedInstance];
        float fontSize = kFloat1; 
        int numOfGroups = gameManager.gameConfigAndState.groups.count;
        [self setContentSize:CGSizeMake(_scrollWidth*numOfGroups, _scrollHeight)];
        
        // need to set an xoffset and yoffset to center the buttons
        int xoffset = kFloat0Point5 * (_scrollWidth - spriteSize.width);
		int yoffset = kFloat0Point5 * (_scrollHeight - spriteSize.height);
        CGPoint screenCenter = [DevicePositionHelper screenCenter];
        
        int i = 0;
        int lastGroupNum = 0;
        for (GameGroup *gameGroup in gameManager.gameConfigAndState.groups)
        {
            MenuScrollItem *item = [[MenuScrollItem alloc] initWithFntFile:kBmpFontAll32
                                                                  fontSize:fontSize 
                                                                   enabled:gameGroup.enabled 
                                                                    number:gameGroup.number 
                                                                 labelText:gameGroup.labelText 
                                                          reqScoreToEnable:gameGroup.reqScoreToEnable
                                                          reqStarsToEnable:gameGroup.reqStarsToEnable 
                                                                     stars:0 
                                                                    target:target 
                                                                  selector:selector];
            item.tag = gameGroup.number;
            item.anchorPoint = cgcenter;
			item.position = ccp((screenCenter.x-(_scrollWidth*kFloat0Point5)) + (i*_scrollWidth) + xoffset, yoffset);
			[self addChild:item z:0 tag:i];
            [item release];
            item = nil;
			i++;
            lastGroupNum = gameGroup.number;
        }
        
        // FREE EDITION: ADD ITEM TO GET FULL VERSION
        lastGroupNum++;
        MenuScrollItem *item = [[MenuScrollItem alloc] initWithFntFile:kBmpFontAll32
                                                              fontSize:fontSize 
                                                               enabled:true 
                                                                number:lastGroupNum 
                                                             labelText:@"Get full version" 
                                                      reqScoreToEnable:999999999
                                                      reqStarsToEnable:999999999 
                                                                 stars:0 
                                                                target:target 
                                                              selector:selector];
        item.tag = lastGroupNum;
        item.anchorPoint = cgcenter;
        item.position = ccp((screenCenter.x-(_scrollWidth*kFloat0Point5)) + (i*_scrollWidth) + xoffset, yoffset);
        [self addChild:item z:0 tag:i];
        [item release];
        item = nil;
        i++;
        
        
        //----------------
		
		// Setup a count of the available screens
		_totalScreens = i;
	}
    
	return self;
}

- (void) dealloc
{
    CCLOG(@"MenuScroll: dealloc");    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

- (void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

-(void) moveToPage:(int)page
{
    CGPoint pos = ccp(-((page-1)*_scrollWidth),0);
    CCActionInterval *actionInterval = [CCMoveTo actionWithDuration:0.3f 
                                                           position:pos];
	id changePage = [CCEaseBounce actionWithAction:actionInterval];
	[self runAction:changePage];
	_currentScreen = page;
}

-(void) moveToNextPage
{
    CGPoint pos = ccp(-(((_currentScreen+1)-1)*_scrollWidth),0);
	id changePage = [CCEaseBounce actionWithAction:[CCMoveTo actionWithDuration:0.3f 
                                                                       position:pos]];
	[self runAction:changePage];
	changePage = nil;
	_currentScreen = _currentScreen+1;
}

-(void) moveToPreviousPage
{
    CGPoint pos = ccp(-(((_currentScreen-1)-1)*_scrollWidth),0);
	id changePage = [CCEaseBounce actionWithAction:[CCMoveTo actionWithDuration:0.3f 
                                                                       position:pos]];
	[self runAction:changePage];
    changePage = nil;
	_currentScreen = _currentScreen-1;
}

// touch handling
-(MenuScrollItem*)itemForTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView:touch.view];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
    MenuScrollItem *retVal = nil;
	for (MenuScrollItem *item in self.children)
	{
		CGPoint local = [item convertToNodeSpace:touchLocation];
		
		CGRect r = item.boundingBox;
		r.origin = CGPointZero;
		
		if (CGRectContainsPoint(r, local))
		{
			retVal = item;
            break;
		}
	}
	
	return retVal;
}

-(BOOL)ccTouchBegan:(UITouch *)touch 
          withEvent:(UIEvent *)event
{
	_swiping = false;
    _selectedItem = nil;
	_selectedItem = [self itemForTouch:touch];
    if(_selectedItem 
       && _selectedItem.enabled)
    {
        _selectedItem.color = kColorGroupButtonHighlight;
    }
    
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	_startSwipe = touchPoint.x;
    
    return YES;
}

-(void)ccTouchCancelled:(UITouch *)touch 
              withEvent:(UIEvent *)event
{
    if(_selectedItem 
       && _selectedItem.enabled)
    {
        _selectedItem.color = ccWHITE;
    }
    _swiping = false;
    _selectedItem = nil;
	_startSwipe = kInt0;
}

- (void)ccTouchMoved:(UITouch *)touch 
           withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:touch.view];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    float diff = _startSwipe - touchPoint.x;
	if (diff > kFloat5 || diff < -kFloat5) 
    {
        _swiping = true;
        if(_selectedItem 
           && _selectedItem.enabled)
        {
            _selectedItem.color = ccWHITE;
        }
    }
    self.position = ccp((-(_currentScreen-1)*_scrollWidth)+(touchPoint.x-_startSwipe),0);
}

- (void)ccTouchEnded:(UITouch *)touch 
           withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if(_swiping)
    {
        if(_selectedItem 
           && _selectedItem.enabled)
        {
            _selectedItem.color = ccWHITE;
        }
        
        int newX = touchPoint.x;
        if ( (newX - _startSwipe) < -kInt100 && (_currentScreen+kInt1) <= _totalScreens )
        {
            [self moveToNextPage];
        }
        else if ( (newX - _startSwipe) > kInt100 && (_currentScreen-kInt1) > kInt0 )
        {
            [self moveToPreviousPage];
        }
        else
        {
            [self moveToPage:_currentScreen];
        }
    }
    else
    {
       	MenuScrollItem *currentItem = [self itemForTouch:touch];
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
            [self stopAllActions];
            [self unscheduleAllSelectors];
            if(_selectedItem){
                [_selectedItem activate];
            }
        }
    }
}

@end
