//
//  CCLayerColor_Opaque.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/13/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "CCLayerColor_Opaque.h"


@implementation CCLayerColor (CCLayerColor_Opaque)

// Set the opacity of all of our children that support it
-(void) setOpacity: (GLubyte) opacity
{
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
    }
}

- (GLubyte)opacity 
{
	for (CCNode *node in [self children]) 
    {
		if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) 
        {
			return [(id<CCRGBAProtocol>)node opacity];
		}
	}
	return 255;
}

@end
