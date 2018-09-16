//
//  ImageGrayscaleHelper.h
//  MEM2
//
//  Created by Damiano Fusco on 2/19/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

/*
Example usage:
 UIImage* myImage = [UIImage imageNamed:@"apple1.png"];
 UIImage* aImage = [ImageGrayscaleHelper convertToGrayscale:sprite.texture];
 CGImageRef sourceImageRef = [aImage CGImage];
 CCSprite* aSprite = [[CCSprite alloc] initWithCGImage:sourceImageRef key:@"aImageKey"];
 aSprite.position = ccp( 240, 160 );
 [self addChild:aSprite];
 [aSprite release];
*/

#import <Foundation/Foundation.h>

@interface ImageGrayscaleHelper : NSObject
{
    
}

+(UIImage *)convertToGrayscale:(UIImage *)source;

@end

