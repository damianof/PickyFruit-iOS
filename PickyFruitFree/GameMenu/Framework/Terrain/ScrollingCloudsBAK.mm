//
//  ScrollingClouds.mm
//  GameMenu
//
//  Created by Damiano Fusco on 12/30/11.
//  Copyright (c) 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ScrollingClouds.h"

@implementation ScrollingClouds


+(id)createWithSpeed:(float)speed
           direction:(int)direction
{
    return [[[self alloc] initWithSpeed:speed
                              direction:direction] autorelease];
}

-(id)initWithSpeed:(float)speed
         direction:(int)direction
{
    _speed = speed;
    _direction = direction;    
    _screenUnitsSize = [DevicePositionHelper screenUnitsRect].size;
    _cloudsUnitsHeight = _screenUnitsSize.height;
    //_mountainsUnitsHeight = 8;
    
    if ((self = [super init])) 
    {
        [self generateSprites];  
        [self scheduleUpdate];
    }
    return self;
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor 
                 textureSize:(CGSize)textureSize
               noiseFileName:(NSString*)noiseFileName
{
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width 
                                                           height:textureSize.height];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    float gradientAlpha = 0.7;    
    CGPoint vertices[4];
    ccColor4F colors[4];
    int nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize.width, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize.height);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureSize.width, textureSize.height);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    if(noiseFileName)
    {
        CCSprite *noise = [CCSprite spriteWithFile:noiseFileName];
        [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
        //noise.position = ccp(textureSize.width*0.8, textureSize.height*0.8);
        noise.position = ccp(0,0);
        [noise visit];
    }
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

-(CCSprite *)stripedSpriteWithColor1:(ccColor4F)c1 
                              color2:(ccColor4F)c2 
                         textureSize:(CGSize)textureSize
                       noiseFileName:(NSString*)noiseFileName  
                        numOfStripes:(int)numOfStripes 
{
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width 
                                                           height:textureSize.height];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:c1.r g:c1.g b:c1.b a:c1.a];
    
    // 3: Draw into the texture    
    
    // Layer 1: Stripes
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    CGPoint vertices[numOfStripes*6];
    int nVertices = 0;
    float x1 = -textureSize.width;
    float x2;
    float y1 = textureSize.height;
    float y2 = 0;
    float dx = textureSize.width / numOfStripes * 2;
    float stripeWidth = dx/2;
    for (int i=0; i<numOfStripes; i++) 
    {
        x2 = x1 + textureSize.width;
        vertices[nVertices++] = CGPointMake(x1, y1);
        vertices[nVertices++] = CGPointMake(x1+stripeWidth, y1);
        vertices[nVertices++] = CGPointMake(x2, y2);
        vertices[nVertices++] = vertices[nVertices-2];
        vertices[nVertices++] = vertices[nVertices-2];
        vertices[nVertices++] = CGPointMake(x2+stripeWidth, y2);
        x1 += dx;
    }
    
    glColor4f(c2.r, c2.g, c2.b, c2.a);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)nVertices);
    
    // layer 2: gradient
    glEnableClientState(GL_COLOR_ARRAY);
    
    float gradientAlpha = 0.7;    
    ccColor4F colors[4];
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
    vertices[nVertices] = CGPointMake(textureSize.width, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(0, textureSize.height);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    vertices[nVertices] = CGPointMake(textureSize.width, textureSize.height);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    // layer 3: top highlight
    float borderWidth = textureSize.width/16;
    float borderAlpha = 0.3f;
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    vertices[nVertices] = CGPointMake(textureSize.width, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    
    vertices[nVertices] = CGPointMake(0, borderWidth);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    vertices[nVertices] = CGPointMake(textureSize.width, borderWidth);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    // Layer 2: Noise    
    if(noiseFileName)
    {
        CCSprite *noise = [CCSprite spriteWithFile:noiseFileName];
        [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
        noise.position = ccp(textureSize.width, textureSize.height);
        [noise visit];
    }
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

- (ccColor4F)getRandomColor:(bool)noRed
                    noGreen:(bool)noGreen
                     noBlue:(bool)noBlue
{
    while (true) 
    {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
        ccc4(noRed ? 0 : arc4random() % 255,
             noGreen ? 0 : arc4random() % 255, 
             noBlue ? 0 : arc4random() % 255, 
             255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) 
        {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}

- (ccColor4F)getRandomBlueishColor
{
    while (true) 
    {
        float requiredBrightness = 212;
        ccColor4B randomColor = 
        ccc4(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255, 
             255);
        
        if ((randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness
            ) 
            && randomColor.b > randomColor.g
            && randomColor.g > randomColor.r
        )
        {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}

- (void)generateSprites 
{
    [self generateCloudsSprite];
    //[self generateMountainsSprite];

    //int nStripes = ((arc4random() % 4) + 1) * 2;
    //_spriteClouds = [self stripedSpriteWithColor1:bgColor color2:color2 textureSize:512 stripes:nStripes];
}

-(void)generateCloudsSprite
{
    CGSize cloudsSize = [DevicePositionHelper sizeFromUnitsSize:UnitsSizeMake(_screenUnitsSize.width, _cloudsUnitsHeight)];
    
    [_spriteClouds removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [self getRandomBlueishColor];
    
    //ccColor4F color2 = [self randomBrightColor];
    _spriteClouds = [self spriteWithColor:bgColor 
                              textureSize:cloudsSize
                            noiseFileName:@"NoiseClouds.png"];
    
    UnitsPoint cloudsUnitsPosition = UnitsPointMake(0, _screenUnitsSize.height);
    CGPoint position = [DevicePositionHelper pointFromUnitsPoint:cloudsUnitsPosition];
    
    [_spriteClouds setAnchorPoint:ccp(0, 1)];
    _spriteClouds.position = position;
    
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_spriteClouds.texture setTexParameters:&tp];
    
    _cloudsBox = [_spriteClouds boundingBox];
    
    [self addChild:_spriteClouds z:0 tag:0];
}

-(void)generateMountainsSprite
{
    CGSize mountainsSize = [DevicePositionHelper sizeFromUnitsSize:UnitsSizeMake(_screenUnitsSize.width, _mountainsUnitsHeight)];
    
    [_spriteMountains removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [self getRandomColor:false
                                     noGreen:false
                                      noBlue:false];
    ccColor4F color2 = [self getRandomColor:false
                                    noGreen:false
                                     noBlue:false];
    
    int numOfStripes = ((arc4random() % 4) + 1) * 2;
    _spriteMountains = [self stripedSpriteWithColor1:bgColor
                                              color2:color2
                                         textureSize:mountainsSize
                                       noiseFileName:@"NoiseClouds.png"
                                        numOfStripes:numOfStripes];
    
    UnitsPoint mountainsUnitsPosition = UnitsPointMake(0, _screenUnitsSize.height-5);
    CGPoint position = [DevicePositionHelper pointFromUnitsPoint:mountainsUnitsPosition];
    
    [_spriteMountains setAnchorPoint:ccp(0, 1)];
    _spriteMountains.position = position;
    
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_spriteMountains.texture setTexParameters:&tp];
    
    [self addChild:_spriteMountains z:1 tag:1];
}

- (void)update:(ccTime)dt 
{
    float PIXELS_PER_SECOND = 20;
    static float offset1 = 0;
    offset1 += (PIXELS_PER_SECOND * (_speed*0.3) * _direction) * dt;
    static float offset2 = 0;
    offset2 += (PIXELS_PER_SECOND * (_speed*0.6) * _direction) * dt;
    
    CGSize textureSize = _spriteClouds.textureRect.size;
    [_spriteClouds setTextureRect:CGRectMake(offset1, 0, textureSize.width, textureSize.height)];
    
    CGSize textureSize2 = _spriteMountains.textureRect.size;
    [_spriteMountains setTextureRect:CGRectMake(offset2, 0, textureSize2.width, textureSize2.height)];
}

-(void)draw
{
    /*glLineWidth(1.0f);
    glColor4f(1.0f, 0.0f, 0.0f, 0.1f); 
    
    CGPoint p1 = _cloudsBox.origin; 
    CGSize sz = _cloudsBox.size;
    p1.x -= 0.1;
    p1.y -= 0.1;
    sz.width += 0.1;
    sz.height += 0.1;
    
    ccDrawLine( p1, CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( p1, CGPointMake(p1.x, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y + sz.height));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y + sz.height), CGPointMake(p1.x + sz.width, p1.y));
    ccDrawLine( CGPointMake(p1.x + sz.width, p1.y), p1);*/
}

-(void)dealloc
{
    [_spriteClouds removeFromParentAndCleanup:YES];
    _spriteClouds = nil;
    [_spriteMountains removeFromParentAndCleanup:YES];
    _spriteMountains = nil;
    
    [super dealloc];
}

@end
