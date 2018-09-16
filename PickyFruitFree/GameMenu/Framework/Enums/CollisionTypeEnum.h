//
//  CollisionTypeEnum.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/17/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

/*typedef enum 
{
	CollisionTypeINVALID = 0,
	CollisionTypeWall = 1,
	CollisionTypeFruit = 2,
	CollisionTypeChain = 3,
	CollisionTypeBug = 4,
	CollisionTypeHail = 5,
    CollisionTypeTruck = 6,
    CollisionTypeMAX
} CollisionTypeEnum;*/

typedef enum 
{
    // IMPORTANT: any change made here should be reflected also in CollisionTypeEnumHelper.h
	CollisionTypeZERO          = 0x0000,
    
	CollisionTypeWorldFloor    = 0x0001,
	CollisionTypeWorldTop      = 0x0002,
	CollisionTypeWorldLeft     = 0x0004,
	CollisionTypeWorldRight    = 0x0008,
	
    CollisionTypeTruck         = 0x0010,
    CollisionTypeChain         = 0x0020,
	CollisionTypeFruit         = 0x0040,
	CollisionTypeHail          = 0x0080,
    
    CollisionTypeObstacleWall   = 0x0100,
    CollisionTypeObstacleHCart  = 0x0200,
    CollisionTypeEnemy          = 0x0400,
    CollisionTypeEnemy2         = 0x0800,
    
    CollisionTypeTruckDriver    = 0x1000,
    
	CollisionTypeALL           = 0xFFFF
} CollisionTypeEnum;

