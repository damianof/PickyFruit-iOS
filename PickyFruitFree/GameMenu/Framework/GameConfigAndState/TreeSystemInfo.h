//
//  TreeSystemInfo.h
//  GameMenu
//
//  Created by Damiano Fusco on 12/18/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeSystemInfo : NSObject
{
    NSArray *_treesInfo;
    NSString *_framesFileName;
    NSString *_imageFormat;
    NSString *_textureImage;
    
    bool _active;
    float _unitsYOffset;
    float _speed;
}

@property (nonatomic, retain) NSArray *treesInfo;
@property (nonatomic, copy) NSString *framesFileName;
@property (nonatomic, copy) NSString *imageFormat;
@property (nonatomic, copy) NSString *textureImage;

@property (nonatomic, assign) bool active;
@property (nonatomic, assign) float unitsYOffset;
@property (nonatomic, assign) float speed;

+(id)createWithTreesInfo:(NSArray *)treesInfo
          framesFileName:(NSString *)ffn
             imageFormat:(NSString *)format
            textureImage:(NSString *)ti
                  active:(bool)a
                   speed:(float)s;

-(id)initWithTreesInfo:(NSArray *)treesInfo
        framesFileName:(NSString *)ffn
           imageFormat:(NSString *)format
          textureImage:(NSString *)ti
                active:(bool)a
                 speed:(float)s;
@end
