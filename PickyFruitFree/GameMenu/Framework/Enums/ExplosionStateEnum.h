//
//  ExplosionStateEnum.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/29/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
typedef enum 
{
    ExplosionStateINVALID      = 0,
    
	ExplosionStateInit,
	ExplosionStateStarted,      
	ExplosionStateProgress,     
	ExplosionStateEnded,    
    
	ExplosionStateMAX          
} ExplosionStateEnum;

