//
//  GameConfigTests.mm
//  GameMenu
//
//  Created by Damiano Fusco on 1/15/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "GameConfigTests.h"
#import "GDataXMLNode.h"
#import "GameStateXmlHelper.h"


@implementation GameConfigTests

+(ActorInfo*)enemyNodeInfo:(NSString*)fn
            framesFileName:(NSString*)ffn
               imageFormat:(NSString*)imageFormat
{
    GDataXMLElement *levelElement = [GDataXMLNode elementWithName:@"Actor"];
    
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"Desc" value:fn];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"Type" value:@"EnemyNode"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"Tag" value:@"7778"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"Z" value:@"105"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"FrameFileName" value:ffn];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"ImageFormat" value:imageFormat];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"VerticesFile" value:@""];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"FrameName" value:fn];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"AnchorPoint" value:@"{0.5,0.5}"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"Position" value:@"{10,20}"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"PositionFromTop" value:@"false"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"CollisionType" value:@"CollisionTypeEnemy"];
    [GameStateXmlHelper addAttributeToElement:levelElement name:@"MakeDynamic" value:@"false"];
    
    GDataXMLElement *collidesWithElement = [GDataXMLNode elementWithName:@"CollidesWith"];
    [GameStateXmlHelper addAttributeToElement:collidesWithElement name:@"Value" value:@"CollisionTypeFruit"];
    [levelElement addChild:collidesWithElement];
    
    GDataXMLElement *maskBitsElement1 = [GDataXMLNode elementWithName:@"MaskBits"];
    [GameStateXmlHelper addAttributeToElement:maskBitsElement1 name:@"Value" value:@"CollisionTypeALL"];
    [levelElement addChild:maskBitsElement1];
    
    GDataXMLElement *maskBitsElement2 = [GDataXMLNode elementWithName:@"MaskBits"];
    [GameStateXmlHelper addAttributeToElement:maskBitsElement2 name:@"Value" value:@"~CollisionTypeWorldLeft"];
    [levelElement addChild:maskBitsElement2];
    
    GDataXMLElement *maskBitsElement3 = [GDataXMLNode elementWithName:@"MaskBits"];
    [GameStateXmlHelper addAttributeToElement:maskBitsElement3 name:@"Value" value:@"~CollisionTypeWorldRight"];
    [levelElement addChild:maskBitsElement3];
    
    ActorInfo *actorInfo = [GameStateXmlHelper actorInfoInstanceFromConfigXmlElement:levelElement];
    return actorInfo;
}




@end
