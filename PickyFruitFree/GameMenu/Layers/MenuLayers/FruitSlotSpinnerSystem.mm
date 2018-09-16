//
//  FruitSlotSpinnerSystem.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//
#import "FruitSlotSpinnerSystem.h"
#import "MathHelper.h"
#import "LevelGoal.h"
#import "FruitSlotSpinner.h"
#import "SimpleAudioEngine.h"


@implementation FruitSlotSpinnerSystem

-(int)cellWidth
{
    return _cellWidth;
}

-(int)cellHalfWidth
{
    return _cellHalfWidth;
}

-(int)gap
{
    return _gap;
}

+(id)createWithLevelGoals:(NSArray*)levelGoals
                  timeout:(float)timeout
               nextTarget:(id)nextTarget
               nextAction:(SEL)nextAction
{
    return [[[self alloc] initWithLevelGoals:levelGoals
                                     timeout:timeout
                                  nextTarget:nextTarget
                                  nextAction:nextAction] autorelease];
}

-(id)initWithLevelGoals:(NSArray*)levelGoals
                timeout:(float)timeout
             nextTarget:(id)nextTarget
             nextAction:(SEL)nextAction
{
    if ( (self = [super initWithColor:ccc4(255,255,255,0)]) )
	{
        _numberOfSpinners = levelGoals.count;
        _timeout = timeout;
        
        _nextTarget = nextTarget;
        _nextAction = nextAction;
        /*_nextAction = nil;
        if(nextAction != nil)
        {
            _nextAction = [nextAction retain];
        }*/
        
        // we have to do this here because CCLayerWithWorld has not been loaded yet
        [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileFruit32]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileFruit32];
        
        CCSpriteFrame *trailerFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kSpriteFrameNameAppleRed];
        
        _cellWidth = trailerFrame.rect.size.width;
        _cellHalfWidth = (_cellWidth * kTwoInverted);
        _gap = (int)(_cellWidth * kFloat0Point2);
        
        // get dict with all the frame names
        NSString *path = [CCFileUtils fullPathFromRelativePath:kFramesFileFruit32];
        NSDictionary *dictFromFile = [[NSDictionary alloc] initWithContentsOfFile:path]; 
        path = nil;
        NSArray *frameNames = [[dictFromFile objectForKey:kCCStringFrames] allKeys];
        [dictFromFile release];
        dictFromFile = nil;
        _numberOfSprites = frameNames.count;
        
        // create spinners
        int i = 0;
        while(i < _numberOfSpinners)
        {
            LevelGoal *goal = (LevelGoal*)[levelGoals objectAtIndex:i];
            
            NSMutableDictionary *sprites = [[NSMutableDictionary alloc] initWithCapacity:_numberOfSprites];            
            //for(NSString *frameKey in framesDict) 
            for(NSString *frameKey in frameNames) 
            {
                CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameKey];
                [sprites setValue:sprite forKey:frameKey];
            }
            
            FruitSlotSpinner *spinner = [FruitSlotSpinner createWithSpritesDict:sprites
                                                                targetFrameName:goal.fruitName
                                                                      cellWidth:self.cellWidth
                                                                            gap:_gap];
            spinner.anchorPoint = CGPointMake(kFloat0, kFloat0Point5);
            spinner.position = ccp((self.cellWidth+_gap) * i, kFloat0);
            [self addChild:spinner z:kInt0 tag:i];
            [sprites release];
            sprites = nil;
            i++;
        }
        
        frameNames = nil;
        
        int totWidth = (_numberOfSpinners * (self.cellWidth+_gap));
        [self setContentSize:CGSizeMake(totWidth, self.cellWidth+_gap)];        
        
        [self schedule:@selector(randomSpin:) interval:kFloat0Point1];

        //id wait = [CCActionInterval actionWithDuration:0.1f];
        //id upd = [CCCallFunc actionWithTarget:self selector:@selector(randomSpin)];
        //id seq = [CCSequence actions:wait, upd, nil];
        //id repeat = [CCRepeatForever actionWithAction:seq];
        //[self runAction:repeat];
	}
    
	return self;
}

-(void)dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    CCLOG(@"FruitSlotSpinnerSystem onExist dealloc _sequenceAction retainCount %d", _sequenceAction.retainCount);
    _sequenceAction = nil;
    _nextTarget = nil;
    _nextAction = nil;
    
    [super dealloc];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    [super onExit];
}

-(bool)allTargetsReached
{
    int count = 0;
    int i = 0;
    while(i < _numberOfSpinners)
    {
        FruitSlotSpinner *spinner = (FruitSlotSpinner*)[self getChildByTag:i];
        if(spinner.targetReached)
        {
            count++;
        }
        i++;
    }
    return count == _numberOfSpinners;
}

-(void)randomSpin:(float)dt
{
    _timeElapsed += dt;
    _elapsedForCounterSound += dt;
    
    int i = 0;
    while(i < _numberOfSpinners)
    {
        FruitSlotSpinner *spinner = (FruitSlotSpinner*)[self getChildByTag:i];
        if(_timeout == kInt0 || spinner.targetReached == false)
        {
            int index = [MathHelper randomNumberBetween:kInt0 andMax:_numberOfSprites];
            //CCLOG(@"index %d", index);
            if(_elapsedForCounterSound > 0.05f)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:kSoundEfxSpinner];
                _elapsedForCounterSound = kFloat0;
            }
            [spinner moveToCell:index];
        }
        i++;
    }
    
    if(self.allTargetsReached)
    {
        [self unscheduleAllSelectors];
        [self runNextAction];
    }
    
    if(_timeout > 0 && _timeElapsed > _timeout){
        [self unscheduleAllSelectors];
        [self goToTargetsAndStop];   
    }
}

-(void)goToTargetsAndStop
{
    [self unscheduleAllSelectors];
    int i = 0;
    while(i < _numberOfSpinners)
    {
        FruitSlotSpinner *spinner = (FruitSlotSpinner*)[self getChildByTag:i];
        if(spinner.targetReached == false)
        {
            [spinner moveToTarget];
        }
        i++;
    }
    [self runNextAction];
}

-(void)performNextAction
{
    if(_nextAction != nil)
    {
        [_nextTarget performSelector:_nextAction];
    }
}

-(void)runNextAction
{
    [self unscheduleAllSelectors];
    if(_nextAction != nil)
    {
        id wait = [CCDelayTime actionWithDuration:kFloat0Point1];
        id next = [CCCallFunc actionWithTarget:self selector:@selector(performNextAction)];
        _sequenceAction = [CCSequence actions:wait, next, nil];
        [self runAction:_sequenceAction];
    }
}

/*
-(void)update:(float)dt
{
    _timeElapsed += dt;
    
    int mod = fmodf(_timeElapsed, 0.2f);
    CCLOG(@"mod %d", mod);
    
    if (mod == 0)
    {
        [self randomSpin];
    }
}*/

-(void)visit
{
    CGRect rect = CC_RECT_POINTS_TO_PIXELS(self.boundingBox);
    glEnable(GL_SCISSOR_TEST);
    glScissor(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
    
    //[self preVisitWithClippingRect:visibleRect];
    //[super visit];
    //[self postVisit];
}

@end
