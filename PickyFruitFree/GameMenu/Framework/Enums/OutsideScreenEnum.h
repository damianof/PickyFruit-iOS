//
//  OutsideScreenEnum.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/21/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

typedef enum 
{
    OutsideScreenINVALID  = 0x0000,
    
	OutsideScreenLeft     = 0x0001,
	OutsideScreenRight    = 0x0002,
	OutsideScreenDown     = 0x0004,
	OutsideScreenUp       = 0x0008,
    
    OutsideScreenMAX      = 0xFFFF
} OutsideScreenEnum;
