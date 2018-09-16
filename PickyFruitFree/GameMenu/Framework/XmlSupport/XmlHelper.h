//
//  XmlHelper.h
//
//  Created by Damiano Fusco on 7/3/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
/*
#import <Foundation/Foundation.h>
#import "objc/runtime.h"
@class GDataXMLDocument;
@class GDataXMLElement;
@class GDataXMLNode;


@interface XmlHelper : NSObject {
    
}

// reflection stuff
+(const char*)getPropertyType:(objc_property_t)property;
+(NSMutableDictionary *)getClassProperties:(NSObject *)obj
                                 className:(NSString *)className;
+(NSMutableDictionary *)deserializeXmlElements:(NSArray *)xmlNodes
                                     className:(NSString*)className;

// generic helpers
+(int)intFromString:(NSString*)stringValue;
+(float)floatFromString:(NSString*)stringValue;
+(bool)boolFromString:(NSString*)stringValue;
+(NSDate *)dateFromString:(NSString *)stringValue;

// generic element/attribute
+(NSString *)getElementOrAttributeString:(GDataXMLElement *)element
                                    name:(NSString *)name;
+(int)getElementOrAttributeInt:(GDataXMLElement *)element
                          name:(NSString *)name;
+(float)getElementOrAttributeFloat:(GDataXMLElement *)element
                              name:(NSString *)name;
+(bool)getElementOrAttributeBool:(GDataXMLElement *)element
                            name:(NSString *)name;
+(NSDate*)getElementOrAttributeDate:(GDataXMLElement *)element
                               name:(NSString *)name;

// element helpers
+(NSString *)getChildElementString:(GDataXMLElement *)element
                       elementName:(NSString *)name;
+(int)getChildElementInt:(GDataXMLElement *)element
             elementName:(NSString *)name;
+(float)getChildElementFloat:(GDataXMLElement *)element
                 elementName:(NSString *)name;
+(bool)getChildElementBool:(GDataXMLElement *)element
               elementName:(NSString *)name;
+(NSDate *)getChildElementDate:(GDataXMLElement *)element
                   elementName:(NSString *)name;

// attribute helpers
+(NSString *)getAttributeString:(GDataXMLElement *)element
                  attributeName:(NSString *)name;
+(int)getAttributeInt:(GDataXMLElement *)element
        attributeName:(NSString *)name;
+(float)getAttributeFloat:(GDataXMLElement *)element
            attributeName:(NSString *)name;
+(bool)getAttributeBool:(GDataXMLElement *)element
          attributeName:(NSString *)name;
+(NSDate*)getAttributeDate:(GDataXMLElement *)element
             attributeName:(NSString *)name;

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

@end*/
