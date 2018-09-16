//
//  RottenStateEnum.h
//  GameMenu
//
//  Created by Damiano Fusco on 1/7/12.
//  Copyright 2012 Shallow Waters Group LLC. All rights reserved.
//
typedef enum 
{
    FruitMessageNONE                = 0x0000,
    
	FruitMessageIncreaseSaved       = 0x0001,
	FruitMessageDecreaseSaved       = 0x0002,
	FruitMessageIncreaseDestroyed   = 0x0004,
	// = 0x0008,
    
    FruitMessageALL            = 0xFFFF
    
} FruitMessageEnum;

