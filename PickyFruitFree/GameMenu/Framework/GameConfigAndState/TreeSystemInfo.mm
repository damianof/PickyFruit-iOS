//
//  TreeSystemInfo.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "TreeSystemInfo.h"

@implementation TreeSystemInfo

@synthesize 
treesInfo = _treesInfo,
framesFileName =_framesFileName,
imageFormat =_imageFormat,
textureImage = _textureImage,
unitsYOffset = _unitsYOffset,
active = _active,
speed = _speed;


+(id)createWithTreesInfo:(NSArray *)treesInfo
          framesFileName:(NSString *)ffn
             imageFormat:(NSString *)format  
            textureImage:(NSString *)ti
                  active:(bool)a
                   speed:(float)s
{
    return [[[self alloc] initWithTreesInfo:treesInfo
                             framesFileName:ffn
                                imageFormat:format  
                               textureImage:ti
                                     active:a
                                      speed:s] autorelease];
}

-(id)initWithTreesInfo:(NSArray *)treesInfo
        framesFileName:(NSString *)ffn
           imageFormat:(NSString *)format  
          textureImage:(NSString *)ti
                active:(bool)a
                 speed:(float)s
{
    if ((self = [super init])) 
    {
        self.treesInfo = treesInfo,
        self.framesFileName = ffn,
        self.imageFormat = format,
        self.textureImage = ti,
        
        self.active = a,
        self.speed = s;
    }    
    return self; 
}

-(void) dealloc 
{    
    // set to nil any NSString or other object
    [_treesInfo release];
    _treesInfo = nil;
    
    [_framesFileName release];
    _framesFileName = nil;
    
    [_imageFormat release];
    _imageFormat = nil;
    
    [_textureImage release];
    _textureImage = nil;
    
    [super dealloc];
}


@end
