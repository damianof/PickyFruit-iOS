//
//  EnemySystemNode.mm
//
//  Created by Damiano Fusco on 12/26/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
#import "EnemySystemNode.h"
#import "MathHelper.h"
#import "CCLayerWithWorld.h"
#import "ActorInfo.h"
#import "EnemySystemInfo.h"
#import "EnemyNode.h"
#import "DevicePositionHelper.h"
#import "MathHelper.h"
#import "OutsideScreenEnum.h"
#import "GameManager.h"

#define kEnemiesPoolSize 30


@implementation EnemySystemNode

@synthesize info = _info;

-(bool)canEmit
{
    // if the pool is not being modified, then can emit
    bool retVal = [GameManager sharedInstance].running;
    
    if(retVal)
    {
        retVal = (_modifyingPool == false);
        
        // if the emittedCount is less then the emissionStopAfter, then can emit
        retVal = retVal && (_emittedCount < self.info.emissionStopAfter);
    }
    
    //CCLOG(@"EnemySystemNode.canEmit %d", retVal);
    return retVal;
}

+(id)createWithLayer:(CCLayerWithWorld*)layer
     enemySystemInfo:(EnemySystemInfo*)esi
{
    return [[[self alloc] initWithLayer:layer
                        enemySystemInfo:esi] autorelease];
}

-(id)initWithLayer:(CCLayerWithWorld*)layer
   enemySystemInfo:(EnemySystemInfo*)esi
{
    if((self = [super init]))
    {
        self.info = esi;
        _layer = layer;
        _modifyingPool = true;
        _emittedCount = 0;
        
        // ad frames file
        if ([esi.imageFormat isEqualToString:kImageFormatPvrCcz]) 
        {
            //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:esi.framesFileName]]; 
            [self addChild:[CCSpriteBatchNode batchNodeWithFile:kFramesFileSplash32]];
        }
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:esi.framesFileName]; 
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kFramesFileSplash32]; 
        
        _screenB2Vec2Size = [DevicePositionHelper screenB2Vec2Size];
        _screenB2Vec2Center = [DevicePositionHelper screenB2Vec2Center];
        
        // there should be only one ActorInfo child
        ActorInfo *templateInfo = [self.info.enemiesInfo lastObject];
        
        for (int i = 0; i < kEnemiesPoolSize; i++) 
        {
            ActorInfo *enemyInfo = [templateInfo cloneWithNewTag:i];
            b2Vec2 position = [DevicePositionHelper b2Vec2FromUnitsPoint:enemyInfo.unitsPosition];
            float randomx = [MathHelper randomFloatBetween:position.x-self.info.positionXVariation
                                                    andMax:position.x+self.info.positionXVariation];
            position = b2Vec2(randomx, position.y);
            EnemyNode *enemy = [[EnemyNode alloc] initWithLayer:_layer
                                                           info:enemyInfo
                                                initialPosition:position];
            [enemyInfo release];
            enemyInfo = nil;
            enemy.sprite.opacity = kInt0;
            enemy.collisionCheckOn = false;
            [enemy setDelegate:self];
            
            [self addChild:enemy z:enemy.info.z tag:enemy.info.tag];
            [enemy release];
            enemy = nil;
        }
        
        templateInfo = nil;
        _modifyingPool = false;
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)onEnter
{
    //CCLOG(@"EnemySystemNode: onEnter");
    [super onEnter];
    
    if(self.info.emissionDelay > kFloat0)
    {
        // create a squence that start with a delay and runs only once
        id delay = [CCDelayTime actionWithDuration:self.info.emissionDelay];
        id startRepeatForever = [CCCallFunc actionWithTarget:self 
                                             selector:@selector(startRepeatForever)];
        id seq = [CCSequence actions:delay, startRepeatForever, nil];
        [self runAction:seq];
    }
    else
    {
        [self startRepeatForever];
    }
}

-(void)startRepeatForever
{
    id emitEnemies = [CCCallFunc actionWithTarget:self 
                                         selector:@selector(emitEnemies)];
    id interval = [CCDelayTime actionWithDuration:self.info.emissionInterval];
    id seq = [CCSequence actions:emitEnemies, interval, nil];
    _repeatForever = [CCRepeatForever actionWithAction:seq];
    [self runAction:_repeatForever];  
}

-(void)onExit
{
    //CCLOG(@"EnemySystemNode: onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)dealloc
{
    CCLOG(@"EnemySystemNode: dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [_info release];
    _info = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

/*-(void)addEnemy:(EnemyNode *)enemy
{
    if(self.canEmit
       && [self getChildByTag:enemy.info.tag] == nil)
    {
        CCLOG(@"AddEnemy %d z %d", enemy.tag, enemy.info.z);
        enemy.info.tag += kInt1000;
        // enable collision
        enemy.collisionCheckOn = true;
        [self addChild:enemy z:enemy.info.z tag:enemy.info.tag];
        // make kinematic
        [enemy makeKinematic];
        // show it
        enemy.sprite.opacity = kInt255;
    }
}*/

-(void)emitEnemies //:(ccTime)dt
{
    if(self.canEmit)
    {
        int index = kInt0;
        for(index = kInt0; index < self.info.emissionRate; index++) 
        {
            if(index > (kEnemiesPoolSize-1))
            {
                break;
            }
            
            _poolLoopIndex = _poolLoopIndex > (kEnemiesPoolSize-1) ? kInt0 : _poolLoopIndex;
            
            //EnemyNode *enemy = [_enemiesPoolLayer.children objectAtIndex:_poolLoopIndex];
            EnemyNode *enemy = (EnemyNode *)[self getChildByTag:_poolLoopIndex];
            if(enemy.sprite.opacity < kInt255 && enemy.deadState == DeadStateINVALID)
            {
                // show it
                [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:enemy 
                                                                 priority:1
                                                          swallowsTouches:NO];
                // enable collision
                enemy.collisionCheckOn = true;
                // make kinematic
                [enemy makeKinematic];
                // make visible
                enemy.sprite.opacity = kInt255;
            }
            
            enemy = nil;
            _poolLoopIndex++;
            _emittedCount++;
        }
        //CCLOG(@"EnemySystemNode: emitEnemies: _emittedCount %d _poolLoopIndex %d", _emittedCount, _poolLoopIndex);
    }
    else
    {
        //CCLOG(@"EnemySystemNode: emitEnemies: start check if allOutsideScreenOrDying");
        EnemyNode* enemy = nil;
        bool allOutsideScreenOrDying = true;
        CCARRAY_FOREACH(self.children, enemy)
        {
            if(enemy && [enemy isKindOfClass:[EnemyNode class]])
            {
                bool outsideScreen = (enemy.outsideScreenValue != OutsideScreenINVALID
                                      && enemy.outsideScreenValue != OutsideScreenLeft);
                allOutsideScreenOrDying = allOutsideScreenOrDying && (outsideScreen || enemy.isDying);
            }
        }
        
        if(allOutsideScreenOrDying)
        {
            CCLOG(@"EnemySystemNode: emitEnemies: allOutsideScreenOrDying true");
            [self stopAllActions];
            [self unscheduleAllSelectors];
            [self removeFromParentAndCleanup:YES];
        }
    }
}

-(void)update:(ccTime)dt
{
    if([GameManager sharedInstance].running)
    {
        [self updateEnemyPosition:dt];
    }
    else
    {
        [self stopAllActions];
        [self unscheduleAllSelectors];
        [self removeFromParentAndCleanup:YES];
    }
}

-(void)updateEnemyPosition:(ccTime)dt
{
    int direction = 1;
    
    if(_modifyingPool == false)
    {
        EnemyNode *enemy = nil;
        CCARRAY_FOREACH(self.children, enemy)
        {
            if([GameManager sharedInstance].running 
               && enemy 
               && [enemy isKindOfClass:[EnemyNode class]]
               && enemy.isDying == false
               && enemy.body)
            {
                enemy.body->SetAwake(false);
                
                float randomy = [MathHelper randomFloatBetween:enemy.initialPosition.y-self.info.positionYVariation
                                                        andMax:enemy.initialPosition.y+self.info.positionYVariation];
                
                float randomx = enemy.initialPosition.x + self.info.enemySpeed;
                b2Vec2 desiredLocation = b2Vec2((direction * randomx), randomy);
                
                // if x position has passed half screen, make it jump on y
                if(enemy.body->GetPosition().x > _screenB2Vec2Center.x)
                {
                    //CCLOG(@"passed half screen");
                    desiredLocation.y = [MathHelper randomFloatBetween:randomy
                                                                andMax:randomy+0.5f];
                }
                
                b2Vec2 directionToTravel = b2Vec2(desiredLocation.x - enemy.initialPosition.x,
                                                  desiredLocation.y - enemy.initialPosition.y);
                
                directionToTravel *= [DevicePositionHelper directionMultipler];
                enemy.body->SetLinearVelocity(directionToTravel);
            }
        }
    }
}

// EnemyDied delegate
-(void)enemyDied:(EnemyNode*)enemy
{
    if([GameManager sharedInstance].running)
    {
        _modifyingPool = true;
        
        //int index = [_enemiesPool indexOfObject:enemy];
        //[_enemiesPool removeObjectAtIndex:index];
        [self removeChild:enemy cleanup:YES];
        
        _modifyingPool = false;
    }
}

@end
