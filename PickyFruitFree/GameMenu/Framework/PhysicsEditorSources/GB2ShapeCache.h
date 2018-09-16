//
//  GB2ShapeCache.h
//  
//  Loads physics sprites created with http://www.PhysicsEditor.de
//
//  Generic Shape Cache for box2d
//
//  Copyright by Andreas Loew 
//      http://www.PhysicsEditor.de
//      http://texturepacker.com
//      http://www.code-and-web.de
//  
//  All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <Box2D.h>
#import "cocos2d.h"
//#import "CCFileUtils.h"


/**
 * Shape cache 
 * This class holds the shapes and makes them accessible 
 * The format can be used on any MacOS/iOS system
 */
@interface GB2ShapeCache : NSObject 
{
    NSMutableDictionary *shapeObjects;
}

+ (GB2ShapeCache *)sharedShapeCache;

/**
 * Adds shapes to the shape cache
 * @param plist name of the plist file to load
 */
-(void) addShapesWithFile:(NSString*)plist
                     size:(CGSize)size
                   anchor:(CGPoint)anchor;

/**
 * Adds fixture data to a body
 * @param body body to add the fixture to
 * @param shape name of the shape
 */
-(void) addFixturesToBody:(b2Body*)body 
             forShapeName:(NSString*)shape;

- (void) addFixturesToBody:(b2Body*)body 
              forShapeName:(NSString*)shape
      overrideCategoryBits:(uint16)categoryBits
          overrideMaskBits:(uint16)maskBits;

/**
 * Returns the anchor point of the given sprite
 * @param shape name of the shape to get the anchorpoint for
 * @return anchorpoint
 */
//-(CGPoint) anchorPointForShape:(NSString*)shape;

@end
