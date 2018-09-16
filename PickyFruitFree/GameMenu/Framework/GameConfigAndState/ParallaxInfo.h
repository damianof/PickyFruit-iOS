//
//  ParallaxInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/16/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParallaxInfo : NSObject
{
    NSArray *_spritesInfo;
    
    NSString *_framesFileName;
    NSString *_imageFormat;
    NSString *_textureImage;
    
    bool _active;
    float _unitsYOffset;
}

@property (nonatomic, retain) NSArray *spritesInfo;

@property (nonatomic, copy) NSString *framesFileName;
@property (nonatomic, copy) NSString *imageFormat;
@property (nonatomic, copy) NSString *textureImage;

@property (nonatomic, assign) bool active;
@property (nonatomic, assign) float unitsYOffset;

+(id)createWithFramesFileName:(NSString *)ffn
                  imageFormat:(NSString *)format 
                 textureImage:(NSString *)ti
                  spritesInfo:(NSArray *)si
                       active:(bool)a;

-(id)initWithFramesFileName:(NSString *)ffn
                imageFormat:(NSString *)format
               textureImage:(NSString *)ti
                spritesInfo:(NSArray *)si
                     active:(bool)a;

@end
