//
//  LevelPassedScoresLayer.m
//  GameMenu
//
//  Created by Damiano Fusco on 1/12/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "LevelPassedScoresLayer.h"


typedef enum{
    LevelPassedScoresTagINVALID = 0,
    LevelPassedScoresTagContainer,
    LevelPassedScoresTagLabelStatic,
    LevelPassedScoresTagLabelAnimated,
    LevelPassedScoresTagLabelBonusStatic,
    LevelPassedScoresTagLabelBonusAnimated,
    LevelPassedScoresTagImprovedScore,
    LevelPassedScoresTagMAX
} LevelPassedScoresTags;


@implementation LevelPassedScoresLayer


//@synthesize 
//delegate = _delegate;

-(CGSize)size
{
    return _size;
}

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
      hideOnComplete:(bool)hideOnComplete
{
    return [[[self alloc] initWithColor:color
                                   size:size
                              labelText:text
                         scoreToAnimate:score
                              scoreBase:scoreBase
                                  delay:delay
                               fontSize:fontSize
                         hideOnComplete:hideOnComplete] autorelease];
}

+(id)createWithColor:(ccColor4B)color
                size:(CGSize)size
           labelText:(NSString*)text
      scoreToAnimate:(int)score
           scoreBase:(int)scoreBase
               delay:(float)delay
            fontSize:(float)fontSize
      hideOnComplete:(bool)hideOnComplete
      bonusLabelText:(NSString*)bonusText
 bonusScoreToAnimate:(int)bonusScore
addImprovedScoreSprite:(bool)addImprovedScoreSprite
{
    return [[[self alloc] initWithColor:color
                                   size:size
                              labelText:text
                         scoreToAnimate:score
                              scoreBase:scoreBase
                                  delay:delay
                               fontSize:fontSize
                         hideOnComplete:hideOnComplete
                         bonusLabelText:bonusText
                    bonusScoreToAnimate:bonusScore
                 addImprovedScoreSprite:addImprovedScoreSprite] autorelease];
}

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
    hideOnComplete:(bool)hideOnComplete
{
    return [self initWithColor:color
                          size:size
                     labelText:text
                scoreToAnimate:score
                     scoreBase:scoreBase
                         delay:delay
                      fontSize:fontSize
                hideOnComplete:hideOnComplete
                bonusLabelText:nil
           bonusScoreToAnimate:kInt0
        addImprovedScoreSprite:false];
}

-(id)initWithColor:(ccColor4B)color
              size:(CGSize)size
         labelText:(NSString*)text
    scoreToAnimate:(int)score
         scoreBase:(int)scoreBase
             delay:(float)delay
          fontSize:(float)fontSize
    hideOnComplete:(bool)hideOnComplete
    bonusLabelText:(NSString*)bonusText
bonusScoreToAnimate:(int)bonusScore
addImprovedScoreSprite:(bool)addImprovedScoreSprite
{
    if((self = [super init]))
    {   
        _addImprovedScoreSprite = addImprovedScoreSprite;
        _hideOnComplete = hideOnComplete;
        _size = size;
        
        _layerColor = [CCLayerColor layerWithColor:color
                                              width:size.width 
                                             height:size.height];
        _layerColor.isTouchEnabled = false;
        
        CCLOG(@"LevelPassedScoresLayer init [%@]", text);
        
        // add static label       
        _labelStatic = [[CCLabelBMFont alloc] initWithString:text fntFile:kBmpFontLevelPassedScore32];
        _labelStatic.opacity = kInt0;
        _labelStatic.anchorPoint = cgzero;
        _labelStatic.scale = fontSize;
        _labelStatic.position = cgzero;
        [self addChild:_labelStatic z:kInt0 tag:LevelPassedScoresTagLabelStatic];
        
        
        // add animated label
        _labelAnimated = [[CCLabelBMFont alloc] initWithString:kString0 fntFile:kBmpFontLevelPassedScore32];
        _labelAnimated.opacity = kInt0;
        _labelAnimated.anchorPoint = cgonezero;
        _labelAnimated.scale = fontSize;
        _labelAnimated.position = ccp(_size.width, kInt0);
        [self addChild:_labelAnimated z:kInt0 tag:LevelPassedScoresTagLabelAnimated];
        
        if(_addImprovedScoreSprite)
        {
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileLevelPassedFailed]]; 
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileLevelPassedFailed];
            
            _spriteImprovedScore = [[CCSprite alloc] initWithSpriteFrameName:kSpriteFrameNameImprovedScoreRound];
            _spriteImprovedScore.anchorPoint = cgonezero;
            int y = _labelAnimated.position.y - (_spriteImprovedScore.boundingBox.size.height*kFloat0Point5);
            _spriteImprovedScore.position = ccp((_size.width + _spriteImprovedScore.boundingBox.size.width)*1.05f, y);
        }
        
        if (bonusScore > kInt0) 
        {
            // add Bonus static label 
            fontSize *= kFloat0Point75;
            _labelBonusStatic = [[CCLabelBMFont alloc] initWithString:bonusText fntFile:kBmpFontLevelPassedScore32];
            _labelBonusStatic.opacity = kInt0;
            _labelBonusStatic.color = ccRED;
            _labelBonusStatic.anchorPoint = cgzero;
            _labelBonusStatic.scale = fontSize;
            _labelBonusStatic.position = ccp(_labelStatic.position.x, _labelStatic.contentSize.height + _labelStatic.position.y);
            [self addChild:_labelBonusStatic z:kInt0 tag:LevelPassedScoresTagLabelBonusStatic];
            
            
            // add Bonus animated label
            _labelBonusAnimated = [[CCLabelBMFont alloc] initWithString:kString0 fntFile:kBmpFontLevelPassedScore32];
            _labelBonusAnimated.opacity = kInt0;
            _labelBonusAnimated.color = ccRED;
            _labelBonusAnimated.anchorPoint = cgonezero;
            _labelBonusAnimated.scale = fontSize;
            _labelBonusAnimated.position = ccp(_labelAnimated.position.x, _labelAnimated.contentSize.height + _labelAnimated.position.y);
            [self addChild:_labelBonusAnimated z:kInt0 tag:LevelPassedScoresTagLabelBonusAnimated];
        }
        
        // add container
        //[self addChild:_container z:kInt0 tag:LevelPassedScoresTagContainer];
        //[_container release];
        //_container = nil;
        
        _bonusScoreIncrement = bonusScore * kTwentyInverted;
        //CCLOG(@"bonusScore %d _bonusScoreIncrement %d", bonusScore, _bonusScoreIncrement);
        _scoreCounter = kInt0;
        _bonusScoreCounter = kInt0;
        _bonusScoreSubStepCounter = kInt0;
        
        _bonusScore = bonusScore;
        _score = (score * scoreBase) - _bonusScore;
        _stepIncrement = _score * kZeroPointFiveInverted; // (score / 0.5) to complete animation in 0.5 second
        _delay = delay;
        _elapsed = kFloat0;
        
        [self scheduleUpdate];
    }
    return self;

}

-(void)dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
   
    CCLOG(@"LevelPassedScoresLayer dealloc [%@]", _labelStatic.string);
    
    //_container = nil;
    
    [_labelStatic release];
    _labelStatic = nil;
    [_labelAnimated release];
    _labelAnimated = nil;
    
    [_labelBonusStatic release];
    _labelBonusStatic = nil;
    [_labelBonusAnimated release];
    _labelBonusAnimated = nil;
    
    [_spriteImprovedScore release];
    _spriteImprovedScore = nil;
	
    [self removeAllChildrenWithCleanup:YES];
    
    // do not do this here
    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:kFramesFileLevelPassedFailedLabels];
    
    [super dealloc];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    CCLOG(@"LevelPassedScoresLayer onExit [%@]", _labelStatic.string);
    [super onExit];
}

-(void)addImprovedScoreSprite
{
    if(_addImprovedScoreSprite)
    {
        [self addChild:_spriteImprovedScore z:kInt0 tag:LevelPassedScoresTagImprovedScore];
    }
}

-(void)didCompleteAnimation
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    CCLOG(@"LevelPassedScoresLayer didCompleteAnimation [%@]", _labelStatic.string);
    
    if(_bonusScore > kInt0)
    {
        [_labelBonusStatic runAction:[CCFadeOut actionWithDuration:0.4f]];
        [_labelBonusAnimated runAction:[CCFadeOut actionWithDuration:0.4f]];
    }
    
    if(_hideOnComplete)
    {
        id wait = [CCDelayTime actionWithDuration:0.2f]; // wait a little so that user can see score
        id fadeOut = [CCFadeOut actionWithDuration:0.2f]; // fade out
        CCSequence *sequenceAction = [CCSequence actions:wait, fadeOut, nil];        
        [self runAction:sequenceAction];
    }
}

-(void)animateBonus
{
    if(_bonusScore > kInt0 && _bonusScoreCounter < _bonusScore)
    {       
        _bonusScoreSubStepCounter+=0.5f;
        
        if(_bonusScoreSubStepCounter >= 1)
        {
            _bonusScoreSubStepCounter = kInt0;
            _bonusScoreCounter += _bonusScoreIncrement;
            _scoreCounter += _bonusScoreIncrement;
            if(_bonusScoreCounter > _bonusScore)
            {
                _bonusScoreCounter = _bonusScore;
            }
            if(_scoreCounter > (_score+_bonusScore))
            {
                _scoreCounter = (_score+_bonusScore);
            }
            
            int labelBonusValue = (_bonusScore - _bonusScoreCounter);
            if(labelBonusValue != _prevLabelBonusScoreValue)
            {
                _prevLabelBonusScoreValue = labelBonusValue;
                NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, _prevLabelBonusScoreValue];
                //CCLOG(@"labelBonusValue: %@ %d", str, labelBonusValue);
                [_labelBonusAnimated setString:str];
                [str release];
                str = nil;
                _labelBonusStatic.opacity = kInt255;
                _labelBonusAnimated.opacity = kInt255;
            }
        }
    }
    
    if(_scoreCounter >= (_score+_bonusScore) || _score == 0)
    {
        _scoreCounter = (_score+_bonusScore);
        [self addImprovedScoreSprite];
        [self didCompleteAnimation];
    }
}

- (void)update:(ccTime)dt 
{
    _elapsed += dt;
    
    if(_elapsed > _delay)
    {
        _labelStatic.opacity = kInt255;
        _labelAnimated.opacity = kInt255;
        
        if(_scoreCounter <= _score)
        {
            int increment = (int)(_stepIncrement * dt);
            _scoreCounter += increment;
            if(_scoreCounter > _score)
            {
                _scoreCounter = _score;
            }
        }
        
        //CCLOG(@"update elapsed %.2f delay %.2f scoreCounter %df _stepIncrement %.2f", _elapsed, _delay, _scoreCounter, _stepIncrement);
        
        if(_scoreCounter >= _score || _score == 0)
        {
            [self animateBonus];
        }
        
        if(_scoreCounter > _prevLabelScoreValue)
        {
            NSString *str = [[NSString alloc] initWithFormat:kStringFormatInt, _scoreCounter];
            [_labelAnimated setString:str];
            [str release];
            str = nil;
            _prevLabelScoreValue = _scoreCounter;
        }
    }
}

@end
