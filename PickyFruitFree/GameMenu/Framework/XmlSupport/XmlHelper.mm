//
//  XmlHelper.m
//  EntensiveTeam-TabBar2
//
//  Created by Damiano Fusco on 7/3/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//
/*
#import "XmlHelper.h"
#import "GDataXMLNode.h"

//static const char* getPropertyType(objc_property_t property) {}

NSString *const boolType = @"B";
NSString *const intType = @"i";
NSString *const floatType = @"f";
NSString *const nsStringType = @"NSString";
NSString *const nsDateType = @"NSDate";
NSString *const nsNumberType = @"NSNumber";
NSString *const nsMutableArrayType = @"NSMutableArray";
NSString *const nsArrayType = @"NSArray";


@implementation XmlHelper


+(const char*)getPropertyType:(objc_property_t)property
{
    // parse the property attribues. this is a comma delimited string. 
    // the type of the attribute starts with the character 'T' should really 
    // just use strsep for this, using a C99 variable sized array.
	
    const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
	
    char *state = buffer;
	char *attribute;
	
    while ((attribute = strsep(&state, ",")) != NULL) {
		
        if (attribute[0] == 'T' && strlen(attribute)>2) 
        {
            // return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute)-4] bytes];
        }
        else if (attribute[0] == 'T' && strlen(attribute)==2) 
        {
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
		}
	}
	
    return "@";
}

//Method to get property type and name of a given object
+(NSMutableDictionary *)getClassProperties:(NSObject *)obj
                                 className:(NSString *)className
{
	unsigned int outCount, i;	
	NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1]; 
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    
    for(i = 0; i < outCount; i++) 
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        //const char *attributes = property_getAttributes(property);
        
        NSString *attributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@\n", attributes);
        bool isNotReadOnly = [attributes rangeOfString:@",R"].location == NSNotFound;
        //NSLog(@"[%@].[%s] isNotReadOnly:%i\n", className, propName, isNotReadOnly);
        
        if(propName && isNotReadOnly) 
        {
			const char *propType = [self getPropertyType:property];
			NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
			NSString *propertyType = [NSString stringWithCString:propType encoding:NSUTF8StringEncoding];
            
			[dic setValue:propertyType forKey:propertyName];
        }
    }
    
    free(properties);
	return dic;
}

+(NSMutableDictionary *)deserializeXmlElements:(NSArray *)elements
                                className:(NSString*)className
{
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithCapacity:[elements count]]; 
    
    //const char *objectName = class_getName([obj class]);
	//NSString *className = [NSString stringWithCString:objectName encoding:NSASCIIStringEncoding];
	NSObject * objTemp = [[[NSClassFromString(className) alloc] init] autorelease];
    
    NSMutableDictionary *properties = [self getClassProperties:objTemp 
                                                     className:className];
	NSString *objIdKey = [NSString stringWithFormat:@"%@Id", className];
    
    for (GDataXMLElement *element in elements) 
    {
        // instantiate object from name
        NSObject * objInstance = [[[NSClassFromString(className) alloc] init] autorelease];
		NSString *objIdValue = nil;
        
        // set properties
        for (NSString *key in properties) 
        {
            //NSLog(@"key: %@, value: %@", key, [properties objectForKey:key]);
			
			// try first as attribute
            if([[properties objectForKey:key] isEqualToString:intType])
            {
                int val = [self getElementOrAttributeInt:element name:key];
                [objInstance setValue:[NSNumber numberWithInt:val] forKey:key];
                
                // if this is Id field, save the value
                if(objIdValue == nil && [key caseInsensitiveCompare:objIdKey] == NSOrderedSame)
                {
                    objIdValue = [NSString stringWithFormat:@"%i", val];
                }
            }
            else if([[properties objectForKey:key] isEqualToString:boolType])
            {
                bool val = [self getElementOrAttributeBool:element name:key];
                [objInstance setValue:[NSNumber numberWithInt:val] forKey:key];
            }
            else if([[properties objectForKey:key] isEqualToString:floatType])
            {
                float val = [self getElementOrAttributeFloat:element name:key];
                [objInstance setValue:[NSNumber numberWithFloat:val] forKey:key];
            }
            else if([[properties objectForKey:key] isEqualToString:nsNumberType]) 
            {
                float val = [self getElementOrAttributeFloat:element name:key];
                [objInstance setValue:[NSNumber numberWithFloat:val] forKey:key];
            }
            else if([[properties objectForKey:key] isEqualToString:nsDateType]) 
            {
                NSDate *val = [self getElementOrAttributeDate:element name:key];
                [objInstance setValue:val forKey:key];
            }
            else if([[properties objectForKey:key] isEqualToString:nsStringType]) 
            {
                NSString *val = [self getElementOrAttributeString:element name:key];
                [objInstance setValue:val forKey:key];
            }
            
            // otherwise try as element
            //NSArray *arr = [element elementsForName:key];
			//NSLog(@"arr: %@",  arr);
            //if(arr == nil)
            //{
            //}
        }
        
        if(objInstance != nil)
        {
            [retVal setValue:objInstance forKey:objIdValue];
        }
    }
    
    return retVal;
}

// generic helpers
+(int)intFromString:(NSString*)stringValue
{
    int retVal = 0;
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.intValue;
    }
    return retVal;
}
+(float)floatFromString:(NSString*)stringValue
{
    float retVal = 0.0f;
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.floatValue;
    }
    return retVal;
}
+(bool)boolFromString:(NSString*)stringValue
{
    bool retVal = false;
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.boolValue;
    }
    return retVal;
}
+(NSDate *)dateFromString:(NSString *)stringValue
{
    NSDate *retVal = nil;
    if(stringValue && stringValue.length > 0)
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        
        // TODO: current format is 2011-01-21T13:07:21
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        retVal = [dateFormatter dateFromString:stringValue];
        [dateFormatter release];
        dateFormatter = nil;
    }
    return retVal; 
}

// try to get value from Attribute, if nil then try from elememnt
+(NSString *)getElementOrAttributeString:(GDataXMLElement *)element
                                    name:(NSString *)name
{
    NSString *stringValue = [self getAttributeString:element attributeName:name];
    if(stringValue == nil || stringValue.length == 0)
    {
        stringValue = [self getChildElementString:element elementName:name];
    }
    return stringValue;
}
+(int)getElementOrAttributeInt:(GDataXMLElement *)element
                          name:(NSString *)name
{
    NSString *stringValue = [self getElementOrAttributeString:element name:name];
    int retVal = [self intFromString:stringValue];
    return retVal;
}
+(float)getElementOrAttributeFloat:(GDataXMLElement *)element
                              name:(NSString *)name
{
    NSString *stringValue = [self getElementOrAttributeString:element name:name];
    float retVal = [self floatFromString:stringValue];
    return retVal;
}
+(bool)getElementOrAttributeBool:(GDataXMLElement *)element
                            name:(NSString *)name
{
    NSString *stringValue = [self getElementOrAttributeString:element name:name];
    bool retVal = [self boolFromString:stringValue];
    return retVal;
}
+(NSDate*)getElementOrAttributeDate:(GDataXMLElement *)element
                               name:(NSString *)name
{
    NSString *stringValue = [self getElementOrAttributeString:element name:name];
    NSDate *retVal = [self dateFromString:stringValue];
    return retVal;
}

// element helpers
+ (NSString *)getChildElementString:(GDataXMLElement *)element
                        elementName:(NSString *)name
{
    NSString *retVal = nil;
    NSArray *items = [element elementsForName:name];
    if (items.count > 0) 
    {
        GDataXMLElement *first = (GDataXMLElement *) [items objectAtIndex:0];
        retVal = first.stringValue;
    } 
    else 
    {
        retVal = @"";
    }
    return retVal;
}

+ (int)getChildElementInt:(GDataXMLElement *)element
              elementName:(NSString *)name
{
    NSString *stringValue = [self getChildElementString:element elementName:name];
    int retVal = [self intFromString:stringValue];
    return retVal;
}

+ (float)getChildElementFloat:(GDataXMLElement *)element
                  elementName:(NSString *)name
{
    NSString *stringValue = [self getChildElementString:element elementName:name];
    float retVal = [self floatFromString:stringValue];
    return retVal;
}

+(bool)getChildElementBool:(GDataXMLElement *)element
               elementName:(NSString *)name
{
    NSString *stringValue = [self getChildElementString:element elementName:name];
    bool retVal = [self boolFromString:stringValue];
    return retVal;
}

+(NSDate *)getChildElementDate:(GDataXMLElement *)element
                   elementName:(NSString *)name
{
    NSString *stringValue = [self getChildElementString:element elementName:name];
    NSDate *retVal = [self dateFromString:stringValue];
    return retVal; 
}

// attribute helpers
+(NSString *)getAttributeString:(GDataXMLElement *)element
                  attributeName:(NSString *)name
{
    GDataXMLNode *attribute = (GDataXMLNode *) [element attributeForName:name];
    NSString *value = attribute.stringValue;
    return value;
}
+(int)getAttributeInt:(GDataXMLElement *)element
        attributeName:(NSString *)name
{
    NSString *stringValue = [self getAttributeString:element attributeName:name];
    int retVal = [self intFromString:stringValue];
    return retVal;
    
}
+(float)getAttributeFloat:(GDataXMLElement *)element
            attributeName:(NSString *)name
{
    NSString *stringValue = [self getAttributeString:element attributeName:name];
    float retVal = [self floatFromString:stringValue];
    return retVal;
}
+(bool)getAttributeBool:(GDataXMLElement *)element
          attributeName:(NSString *)name
{
    NSString *stringValue = [self getAttributeString:element attributeName:name];
    bool retVal = [self boolFromString:stringValue];
    return retVal;
}
+(NSDate*)getAttributeDate:(GDataXMLElement *)element
             attributeName:(NSString *)name
{
    NSString *stringValue = [self getAttributeString:element attributeName:name];
    NSDate *retVal = [self dateFromString:stringValue];
    return retVal;   
}

// xml manipulation
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
                   value:(NSString*)v
{
    GDataXMLElement * child = [GDataXMLNode elementWithName:n 
                                                stringValue:v];
    [element addChild:child];
}
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
                intValue:(int)v
{
    [self addChildToElement:element name:n value:[NSString stringWithFormat:@"%d",v]];
}
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
              floatValue:(float)v
                  format:(NSString *)f
{
    [self addChildToElement:element name:n value:[NSString stringWithFormat:f, v]];
}

+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                       value:(NSString*)v
{
    GDataXMLNode *attribute = [GDataXMLNode attributeWithName:n 
                                                  stringValue:v];
    [element addAttribute:attribute];
}
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                    intValue:(int)v
{
    [self addAttributeToElement:element name:n value:[NSString stringWithFormat:@"%d", v]];
}
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                  floatValue:(float)v
                      format:(NSString *)f
{
    [self addAttributeToElement:element name:n value:[NSString stringWithFormat:f, v]];
}



@end*/
