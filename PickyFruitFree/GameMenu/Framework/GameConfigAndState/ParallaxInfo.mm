//
//  ParallaxInfo.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/16/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ParallaxInfo.h"


@implementation ParallaxInfo

@synthesize 
framesFileName = _framesFileName,
imageFormat = _imageFormat,
textureImage = _textureImage,
spritesInfo = _spritesInfo,
unitsYOffset = _unitsYOffset,
active = _active;



+(id)createWithFramesFileName:(NSString *)ffn
                  imageFormat:(NSString *)format
                 textureImage:(NSString *)ti
                  spritesInfo:(NSArray *)si
                       active:(bool)a
{
    return [[[self alloc] initWithFramesFileName:ffn
                                     imageFormat:format 
                                    textureImage:ti
                                     spritesInfo:si
                                          active:a] autorelease];
}

-(id)initWithFramesFileName:(NSString *)ffn
                imageFormat:(NSString *)format 
               textureImage:(NSString *)ti
                spritesInfo:(NSArray *)si
                     active:(bool)a
{
    if ((self = [super init])) 
    {
        self.spritesInfo = si,
        
        self.framesFileName = ffn,
        self.imageFormat = format,
        self.textureImage = ti,
        
        self.active = a;
        
        //_spriteFramesFile = [[NSString alloc] initWithFormat:@"%@.%@", ffn, ffe];
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object    
    [_spritesInfo release];
    _spritesInfo = nil;
    
    [_framesFileName release];
    _framesFileName = nil;
    
    [_imageFormat release];
    _imageFormat = nil;
    
    [_textureImage release];
    _textureImage = nil;
    
    [super dealloc];
}

@end
