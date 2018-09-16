//
//  GameStateXmlHelper.h
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TargetLayerEnumHelper.h"
#import "CollisionTypeEnumHelper.h"


@class GameConfigAndState;
@class GameGroup;
@class GameLevel;
@class StaticSpriteInfo;
@class ActorInfo;
@class GDataXMLDocument;
@class GDataXMLElement;
@class GDataXMLNode;
@class TargetLayerEnumHelper;
@class CollisionTypeEnumHelper;
@class ParallaxInfo;
@class ParallaxSpriteInfo;


@interface GameStateXmlHelper : NSObject 
{
}

+(GDataXMLDocument *)getGameConfigXmlDocument;
+(GDataXMLDocument *)getGameStateXmlDocument;

+(GameConfigAndState *)loadGameConfigAndState;
+(void)saveGameState:(GameConfigAndState *)gs;
+(void)deleteGameState;

+(void)saveLevel:(GameLevel *)gl;

// desserialization helpers:
//+(StaticSpriteInfo *)staticSpriteInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element;
+(GameGroup *)gameGroupInstanceFromConfigXmlElement:(GDataXMLElement *)element;

+(GameLevel *)gameLevelInstanceFromConfigXmlElement:(GDataXMLElement *)element
                                 andStateXmlElement:(GDataXMLElement *)element;

+(ActorInfo *)actorInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element;

// element helpers
+(NSString *)getChildElementString:(GDataXMLElement *)element
                              name:(NSString *)name;
+(int)getChildElementInt:(GDataXMLElement *)element
                    name:(NSString *)name;
+(float)getChildElementFloat:(GDataXMLElement *)element
                        name:(NSString *)name;

// attribute helpers
+(NSString *)getAttributeString:(GDataXMLElement *)element
                  name:(NSString *)name;
+(int)getAttributeInt:(GDataXMLElement *)element
                 name:(NSString *)name;
+(float)getAttributeFloat:(GDataXMLElement *)element
                     name:(NSString *)name;
+(bool)getAttributeBool:(GDataXMLElement *)element
                   name:(NSString *)name;

// element creation helpers
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
                   value:(NSString*)v;
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
                intValue:(int)v;
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
              floatValue:(float)v
                  format:(NSString *)f;

// attribute creation helpers
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                       value:(NSString*)v;
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                    intValue:(int)v;
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                  floatValue:(float)v
                      format:(NSString *)f;
@end
