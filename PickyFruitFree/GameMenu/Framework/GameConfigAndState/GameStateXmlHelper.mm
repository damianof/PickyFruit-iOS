//
//  GameStateXmlHelper.m
//  TestXmlSerialization
//
//  Created by Damiano Fusco on 4/27/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameStateXmlHelper.h"

//#import "DevicePositionHelper.h"
#import "GDataXMLNode.h"
#import "GameConfigAndState.h"
#import "GameGroup.h"
#import "GameLevel.h"
#import "LevelGoal.h"
#import "StaticSpriteInfo.h"
#import "ActorInfo.h"
#import "ParallaxSpriteInfo.h"
#import "ParallaxInfo.h"
#import "TreeInfo.h"
#import "TreeSystemInfo.h"
#import "EnemySystemInfo.h"


@implementation GameStateXmlHelper

// contains the game config a state defaults
+(NSString *)gameConfigFilePath 
{
    return [[NSBundle mainBundle] pathForResource:@"GameConfigAndStateDefaults" ofType:@"xml"];
}

// it will contain the game state saved in the user documents folder (user scorese etc)
+(NSString *)gameStateFilePath:(BOOL)forSave 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    paths = nil;
    
    // try to look in the Documents directory
    NSString *gameStateFilePath = [documentsDirectory
                                   stringByAppendingPathComponent:@"GameState.xml"];
    documentsDirectory = nil;
    
    if (forSave || 
        [[NSFileManager defaultManager] fileExistsAtPath:gameStateFilePath]) 
    {
        // if saving, or the file exists, return the document path
        return gameStateFilePath;
    } 
    else 
    {
        // otherwise, return the default GameConfigAndStateDefaults.xml document from the resource
        //return [[NSBundle mainBundle] pathForResource:@"GameConfigAndStateDefaults" ofType:@"xml"];
        return [self gameConfigFilePath];
    }
}

+(GDataXMLDocument *)getGameConfigXmlDocument
{
    NSString *filePath = [self gameConfigFilePath];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    filePath = nil;
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:&error];
    if (doc == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: getGameConfigXmlDocument: WARNING: Could not load Game Config xml document");
        [xmlData release];
        xmlData = nil;
        return nil; 
    }
    
    //CCLOG(@"GameStateXmlHelper: getGameConfigXmlDocument: %@", doc.rootElement);
    [xmlData release];
    xmlData = nil;
    return doc;
}

+(GDataXMLDocument *)getGameStateXmlDocument
{
    NSString *filePath = [self gameStateFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    filePath = nil;
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData 
                                                           options:0 error:&error];
    if (doc == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: getGameStateXmlDocument: WARNING: Could not load Game State xml document");
        [xmlData release];
        xmlData = nil;
        return nil; 
    }
    
    //CCLOG(@"GameStateXmlHelper: getGameStateXmlDocument: %@", doc.rootElement);
    [xmlData release];
    xmlData = nil;
    return doc;
}

// element helpers
+ (NSString *)getChildElementString:(GDataXMLElement *)element
                               name:(NSString *)name
{
    NSString *retVal = nil;
    NSArray *items = [element elementsForName:name];
    if (items.count > 0) 
    {
        GDataXMLElement *first = (GDataXMLElement *) [items objectAtIndex:0];
        retVal = first.stringValue;
        first = nil;
    } 
    else 
    {
        retVal = @""; //[NSString stringWithString:@""];
    }
    items = nil;
    return retVal;
}

+ (int)getChildElementInt:(GDataXMLElement *)element
                     name:(NSString *)name
{
    int retVal = 0;
    NSString *stringValue = [self getChildElementString:element name:name];
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.intValue;
    }
    stringValue = nil;
    return retVal;
}

+ (float)getChildElementFloat:(GDataXMLElement *)element
                         name:(NSString *)name
{
    float retVal = 0.0f;
    NSString *stringValue = [self getChildElementString:element name:name];
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.floatValue;
    }
    stringValue = nil;
    return retVal;
}

// attribute helpers
+(NSString *)getAttributeString:(GDataXMLElement *)element
                  name:(NSString *)name
{
    GDataXMLNode *attribute = (GDataXMLNode *) [element attributeForName:name];
    return attribute.stringValue;
}
+(int)getAttributeInt:(GDataXMLElement *)element
                 name:(NSString *)name
{
    int retVal = 0;
    NSString *stringValue = [self getAttributeString:element name:name];
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.intValue;
    }
    stringValue = nil;
    return retVal;

}
+(float)getAttributeFloat:(GDataXMLElement *)element
                     name:(NSString *)name
{
    float retVal = 0;
    NSString *stringValue = [self getAttributeString:element name:name];
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.floatValue;
    }
    return retVal;
}
+(bool)getAttributeBool:(GDataXMLElement *)element
                   name:(NSString *)name
{
    bool retVal = false;
    NSString *stringValue = [self getAttributeString:element name:name];
    if(stringValue && stringValue.length > 0)
    {
        retVal = stringValue.boolValue;
    }
    return retVal;
}


// create a ParallaxSpriteInfo instance from the xml element
+(ParallaxSpriteInfo *)parallaxSpriteInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    int t = [self getAttributeFloat:element name:@"Tag"];
    int z = [self getAttributeFloat:element name:@"Z"];
    NSString *fn = [self getAttributeString:element name:@"FrameName"];
    NSString *apStr = [self getAttributeString:element name:@"AnchorPoint"];
    CGPoint ap = CGPointFromString(apStr);
    float sf = [self getAttributeFloat:element name:@"SpeedFactor"];
    
    NSString *pStr = [self getAttributeString:element name:@"Position"];
    UnitsPoint up = UnitsPointFromString(pStr);
    
    bool pft = [self getAttributeBool:element name:@"PositionFromTop"];
    
    ParallaxSpriteInfo *parallaxSpriteInfo = [ParallaxSpriteInfo createWithTag:t
                                                                             z:z
                                                                     frameName:fn 
                                                                   anchorPoint:ap  
                                                                 unitsPosition:up
                                                               positionFromTop:pft 
                                                                   speedFactor:sf];
    return parallaxSpriteInfo;
}

// create a ParallaxInfo instance from the xml element
+(ParallaxInfo *)parallaxInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    NSString *ffn = [self getAttributeString:element name:@"FramesFileName"];
    NSString *format = [self getAttributeString:element name:@"ImageFormat"];
    NSString *ti = [self getAttributeString:element name:@"TextureImage"];
    bool a = [self getAttributeBool:element name:@"Active"];
    
    //CCLOG(@"parallaxInfoInstanceFromConfigXmlElement sff %@", sff);
    
    // Parallax Sprites
    NSError *error = nil;
    NSArray *spriteElements = [element nodesForXPath:@"Sprite" error:&error];
    
    if (spriteElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: parallaxInfoInstanceFromConfigXmlElement: ERROR: Could not find Sprites child for this element");
        return nil; 
    }
    
    NSMutableArray *spritesInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *spriteElement in spriteElements) 
    {
        ParallaxSpriteInfo *spriteInfo = [self parallaxSpriteInfoInstanceFromConfigXmlElement:spriteElement];
        [spritesInfo addObject:spriteInfo];
    }
    spriteElements = nil;
    
    ParallaxInfo *parallaxInfo = [ParallaxInfo createWithFramesFileName:ffn
                                                            imageFormat:format
                                                           textureImage:ti
                                                            spritesInfo:spritesInfo
                                                                 active:a];
    [spritesInfo release];
    spritesInfo = nil;
    ffn = nil;
    format = nil;
    ti = nil;
    
    return parallaxInfo;
}

// create a TreeInfo instance from the xml element
+(TreeInfo *)treeInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    int t = [self getAttributeFloat:element name:@"Tag"];
    int z = [self getAttributeFloat:element name:@"Z"];
    
    NSString *fn = [self getAttributeString:element name:@"FrameName"];
    
    // Fruit Region
    NSString *frStr = [self getAttributeString:element name:@"FruitRegion"];
    UnitsRect fr = UnitsRectFromString(frStr);
    
    NSString *apStr = [self getAttributeString:element name:@"AnchorPoint"];
    CGPoint ap = CGPointFromString(apStr);
    
    // Fruits
    // <Actor> elements
    NSError *error = nil;
    NSArray *actorElements = [element nodesForXPath:@"Actors/Actor" error:&error];
    
    if (actorElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: treeInfoInstanceFromConfigXmlElement: ERROR: Could not find Actors child for this element");
        return nil; 
    }
    
    NSMutableArray *actorsInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *actorElement in actorElements) 
    {
        ActorInfo *actorInfo = [self actorInfoInstanceFromConfigXmlElement:actorElement];
        [actorsInfo addObject:actorInfo];
    }
    actorElements = nil;

    TreeInfo *treeInfo = [TreeInfo createWithTag:t
                                               z:z
                                       frameName:fn 
                                     anchorPoint:ap
                                     fruitRegion:fr
                                      actorsInfo:actorsInfo];
    [actorsInfo release];
    actorsInfo = nil;
    fn = nil;
    return treeInfo;
}

// create a TreeSystemInfo instance from the xml element
+(TreeSystemInfo *)treeSystemInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    bool a = [self getAttributeBool:element name:@"Active"];
    float s = [self getAttributeFloat:element name:@"Speed"];
    NSString *ffn = [self getAttributeString:element name:@"FramesFileName"];
    NSString *format = [self getAttributeString:element name:@"ImageFormat"];
    NSString *ti = [self getAttributeString:element name:@"TextureImage"];
    
    // Parallax Sprites
    NSError *error = nil;
    NSArray *treeElements = [element nodesForXPath:@"Tree" error:&error];
    if (treeElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: treeSystemInfoInstanceFromConfigXmlElement: ERROR: Could not find Tree children for this element");
        return nil; 
    }
    
    NSMutableArray *treesInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *treeElement in treeElements) 
    {
        TreeInfo *treeInfo = [self treeInfoInstanceFromConfigXmlElement:treeElement];
        [treesInfo addObject:treeInfo];
    }
    treeElements = nil;
    
    TreeSystemInfo *treeSystemInfo = [TreeSystemInfo createWithTreesInfo:treesInfo
                                                          framesFileName:ffn
                                                             imageFormat:format
                                                            textureImage:ti
                                                                  active:a
                                                                   speed:s];
    [treesInfo release];
    treesInfo = nil;
    ffn = nil;
    format = nil;
    ti = nil;
    return treeSystemInfo;
}

// create a EnemySystemInfo instance from the xml element
+(EnemySystemInfo *)enemySystemInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    bool a = [self getAttributeBool:element name:@"Active"];
    float es = [self getAttributeFloat:element name:@"EnemySpeed"];
    float ed = [self getAttributeFloat:element name:@"EmissionDelay"];
    int er = [self getAttributeInt:element name:@"EmissionRate"];
    float ei = [self getAttributeFloat:element name:@"EmissionInterval"];
    int esa = [self getAttributeInt:element name:@"EmissionStopAfter"];
    
    float pxv = [self getAttributeFloat:element name:@"PositionXVariation"];
    float pyv = [self getAttributeFloat:element name:@"PositionYVariation"];
    
    NSString *ffn = [self getAttributeString:element name:@"FramesFileName"];
    NSString *format = [self getAttributeString:element name:@"ImageFormat"];
    
    // <Actor> elements
    NSError *error = nil;
    NSArray *actorElements = [element nodesForXPath:@"Actors/Actor" error:&error];
    
    if (actorElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: enemySystemInfoInstanceFromConfigXmlElement: ERROR: Could not find Actors child for this element");
        return nil; 
    }
    
    NSMutableArray *enemiesInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *actorElement in actorElements) 
    {
        ActorInfo *enemyInfo = [self actorInfoInstanceFromConfigXmlElement:actorElement];
        [enemiesInfo addObject:enemyInfo];
    }
    actorElements = nil;
    
    EnemySystemInfo *enemySystemInfo = [EnemySystemInfo createWithEnemiesInfo:enemiesInfo
                                                               framesFileName:ffn
                                                                  imageFormat:format
                                                                       active:a
                                                                emissionDelay:ed
                                                                 emissionRate:er
                                                             emissionInterval:ei
                                                            emissionStopAfter:esa
                                                                   enemySpeed:es];
    enemySystemInfo.positionXVariation = pxv;
    enemySystemInfo.positionYVariation = pyv;
    
    [enemiesInfo release];
    enemiesInfo = nil;
    ffn = nil;
    format = nil;
    
    return enemySystemInfo;
}

+(StaticSpriteInfo *)staticSpriteInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    int t = [self getAttributeFloat:element name:@"Tag"];
    int z = [self getAttributeFloat:element name:@"Z"];
    NSString *ffn = [self getAttributeString:element name:@"FramesFileName"];
    NSString *format = [self getAttributeString:element name:@"ImageFormat"];
    NSString *fn = [self getAttributeString:element name:@"FrameName"];
    NSString *apStr = [self getAttributeString:element name:@"AnchorPoint"];
    NSString *pStr = [self getAttributeString:element name:@"Position"];
    bool pft = [self getAttributeBool:element name:@"PositionFromTop"];
    
    CGPoint ap = CGPointFromString(apStr);
    apStr = nil;
    UnitsPoint up = UnitsPointFromString(pStr);
    pStr = nil;
    StaticSpriteInfo *staticSpriteInfo = [StaticSpriteInfo createWithTag:t
                                                                       z:z
                                                          framesFileName:ffn
                                                             imageFormat:format
                                                               frameName:fn 
                                                             anchorPoint:ap 
                                                           unitsPosition:up 
                                                         positionFromTop:pft];
    ffn = nil;
    format = nil;
    fn = nil;
    
    return staticSpriteInfo;
}

/*+(JointInfo *)jointInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    NSString *tn = [self getAttributeString:element name:@"Type"];
    NSString *jw = [self getAttributeString:element name:@"With"];
    NSString *waStr = [self getAttributeString:element name:@"WorldAxis"];
    CGPoint waPoint = CGPointFromString(waStr);
    waStr = nil;
    b2Vec2 wa = [DevicePositionHelper b2Vec2FromPoint:waPoint];
    
    JointInfo *retVal = [JointInfo createWithTypeName:tn];
    tn = nil;
    retVal.joinWith = jw;
    jw = nil;
    [retVal setWorldAxis:wa];
    
    return retVal;
}*/

+(ActorInfo *)actorInfoInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    int t = [self getAttributeFloat:element name:@"Tag"];
    int z = [self getAttributeFloat:element name:@"Z"];
    NSString *tn = [self getAttributeString:element name:@"Type"];
    NSString *ffn = [self getAttributeString:element name:@"FramesFileName"];
    //CCLOG(@"actorInfoInstanceFromConfigXmlElement: framesFileName %@ retainCount %d", ffn, ffn.retainCount);
    
    NSString *format = [self getAttributeString:element name:@"ImageFormat"];
    NSString *fn = [self getAttributeString:element name:@"FrameName"];
    NSString *apStr = [self getAttributeString:element name:@"AnchorPoint"];
    NSString *pStr = [self getAttributeString:element name:@"Position"];
    bool pft = [self getAttributeBool:element name:@"PositionFromTop"];
    float a = [self getAttributeFloat:element name:@"Angle"];
    NSString *ubStr = [self getAttributeString:element name:@"UnitsBounds"];
    
    NSString *vf = [self getAttributeString:element name:@"VerticesFile"];
    NSString *ctStr = [self getAttributeString:element name:@"CollisionType"];
    uint16 ct = [CollisionTypeEnumHelper enumValueFromName:ctStr];
    ctStr = nil;
    bool md = [self getAttributeBool:element name:@"MakeDynamic"];
    bool mk = [self getAttributeBool:element name:@"MakeKinematic"];
    
    // CollidesWith
    NSError *error = nil;
    NSArray *collidesWithElements = [element nodesForXPath:@"CollidesWith" error:&error];
    if (collidesWithElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: actorInfoInstanceFromConfigXmlElement: ERROR: Could not find CollidesWith children for this element");
        return nil; 
    }
    uint16 cwt = 0;
    for (GDataXMLElement *collidesWithElement in collidesWithElements) 
    {
        NSString *cwStr = [self getAttributeString:collidesWithElement name:@"Value"];
        uint16 tmp = [CollisionTypeEnumHelper valueFromName:cwStr];
        if(cwt == 0)
        {
            cwt = tmp;
        }
        else
        {
            cwt &= tmp;
        }
    }
    collidesWithElements = nil;
    
    // MaskBits
    error = nil;
    NSArray *maskBitsElements = [element nodesForXPath:@"MaskBits" error:&error];
    if (maskBitsElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: actorInfoInstanceFromConfigXmlElement: ERROR: Could not find MaskBits children for this element");
        return nil; 
    }
    uint16 mb = 0;
    for (GDataXMLElement *maskBitsElement in maskBitsElements) 
    {
        NSString *mbStr = [self getAttributeString:maskBitsElement name:@"Value"];
        uint16 tmp = [CollisionTypeEnumHelper valueFromName:mbStr];
        if(mb == 0)
        {
            mb = tmp;
        }
        else
        {
            mb &= tmp;
        }
    }
    maskBitsElements = nil;
    
    //uint16 test = (CollisionTypeFruit & CollisionTypeHail);
    //uint16 test2 = test == (test & CollisionTypeFruit);
    //uint16 test3 = test == (test & CollisionTypeHail);
    //CCLOG(@"%@ t:%i cwt:%i test:%i test2:%i test3:%i", tn, t, cwt, test, test2, test3);
    
    // Joints
    error = nil;
    
    /*NSArray *jointElements = [element nodesForXPath:@"Joint" error:&error];
    NSMutableArray *jointInfos = [[NSMutableArray alloc] init];
    if (jointElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: actorInfoInstanceFromConfigXmlElement: WARNING: Could not find Joint children for this element");
    }
    else
    {
        for (GDataXMLElement *jointElement in jointElements) 
        {
            JointInfo *jointInfo = [self jointInfoInstanceFromConfigXmlElement:jointElement];
            [jointInfos addObject:jointInfo];
        }
    }
    jointElements = nil;*/
    
    CGPoint ap = CGPointFromString(apStr);
    apStr = nil;
    UnitsPoint up = UnitsPointFromString(pStr);
    pStr = nil;
    UnitsBounds ub = UnitsBoundsFromString(ubStr);
    ubStr = nil;
    ActorInfo *actorInfo = [ActorInfo createWithTypeName:tn
                                                     tag:t
                                                       z:z
                                          framesFileName:ffn
                                             imageFormat:format
                                               frameName:fn 
                                             anchorPoint:ap 
                                           unitsPosition:up 
                                         positionFromTop:pft
                                                   angle:a
                                             unitsBounds:ub];
    
    actorInfo.verticesFile = vf;
    actorInfo.makeDynamic = md;
    actorInfo.makeKinematic = mk;
    actorInfo.collisionType = ct;
    actorInfo.collidesWithTypes = cwt;
    actorInfo.maskBits = mb;
    
    [element releaseCachedValues];

    vf = nil;
    tn = nil;
    ffn = nil;
    format = nil;
    fn = nil;
    
    return actorInfo;
}

+(LevelGoal *)levelGoalInstanceFromXmlElement:(GDataXMLElement *)element
{
    int tag = [self getAttributeInt:element name:@"Tag"];
    NSString *fn = [self getAttributeString:element name:@"FruitName"];
    int target = [self getAttributeInt:element name:@"Target"];
    
    // state
    int count = [self getAttributeInt:element name:@"Count"];
    int prevCount = [self getAttributeInt:element name:@"PrevCount"];

    LevelGoal *retVal = [LevelGoal createWithTag:tag
                                       fruitName:fn
                                          target:target
                                      stateCount:count
                                       prevCount:prevCount];
    
    fn = nil;
    return retVal;
}

+(GameGroup *)gameGroupInstanceFromConfigXmlElement:(GDataXMLElement *)element
{
    // <Group> attributes
    // Group Number
    int n = [self getAttributeInt:element name:@"Number"];
    // Active
    int a = [self getAttributeInt:element name:@"Active"];
    // Label
    NSString *lt = [self getAttributeString:element name:@"Label"];
    // Required TotScore to enable level
    int rste = [self getAttributeInt:element name:@"ReqScoreToEnable"];
    // Required TotStars to enable level
    int rstarste = [self getAttributeInt:element name:@"ReqStarsToEnable"];
    // TargetLayer
    NSString *tlStr = [self getAttributeString:element name:@"GameLayer"];
    TargetLayerEnum tl = [TargetLayerEnumHelper enumValueFromName:tlStr];
    tlStr = nil;
    
    // Units from Edge
    int ufe = [self getAttributeInt:element name:@"UnitsFromEdge"];
    // Units Y Offset
    int uyo = [self getAttributeInt:element name:@"UnitsYOffset"];
    // Fruit Region
    NSString *srStr = [self getAttributeString:element name:@"SkyRegion"];
    UnitsRect sr = UnitsRectFromString(srStr);
    srStr = nil;
    
    // Time before hail
    NSString *tbhStr = [self getAttributeString:element name:@"TimeBeforeHail"];
    float tbh = [tbhStr floatValue];
    tbhStr = nil;
    
    // numberOfTrailers
    int numberOfTrailers = [self getAttributeInt:element name:@"NumberOfTrailers"];
    
    // <Images> attributes (Images is a child of <Group>)
    NSArray *imagesElements = [element elementsForName:@"Images"];
    if (imagesElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find Images child for this element");
        return nil; 
    }
    
    GDataXMLElement *imagesElement = [imagesElements lastObject];
    imagesElements = nil;
    
    // Group button image
    //NSString *gbi = [self getAttributeString:imagesElement name:@"GroupButton"];
    // Level button image
    //NSString *lbi = [self getAttributeString:imagesElement name:@"LevelButton"];
    // UI Background image
    NSString *ubi = [self getAttributeString:imagesElement name:@"UIBackground"];
    imagesElement = nil;
    
    // <Parallax> element
    NSError *error = nil;
    NSArray *parallaxElements = [element nodesForXPath:@"Parallax" error:&error];
    if (parallaxElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find Parallax child for this element");
        return nil; 
    }
    GDataXMLElement *parallaxElement = [parallaxElements lastObject];
    parallaxElements = nil;
    
    ParallaxInfo *parallaxInfo = [self parallaxInfoInstanceFromConfigXmlElement:parallaxElement];
    parallaxElement = nil;
    
    // pass units y offset to ParallaxInfo as well, as Paralla will be responsible for rendering its sprites at the right position
    parallaxInfo.unitsYOffset = uyo;
    
    // TreeSystem element
    error = nil;
    NSArray *treeSystemElements = [element nodesForXPath:@"TreeSystem" error:&error];
    if (treeSystemElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find TreeSystem child for this element");
        return nil; 
    }
    GDataXMLElement *treeSystemElement = [treeSystemElements lastObject];
    treeSystemElements = nil;
    
    TreeSystemInfo *treeSystemInfo = [self treeSystemInfoInstanceFromConfigXmlElement:treeSystemElement];
    treeSystemElement = nil;
    
    // pass units y offset to TreeSystemInfo as well, as it will be responsible for rendering its sprites at the right position
    treeSystemInfo.unitsYOffset = uyo;
    
    // EnemySystem element
    error = nil;
    NSArray *enemySystemElements = [element nodesForXPath:@"EnemySystem" error:&error];
    if (enemySystemElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find EnemySystem child for this element");
        return nil; 
    }
    GDataXMLElement *enemySystemElement = [enemySystemElements lastObject];
    enemySystemElements = nil;
    
    EnemySystemInfo *enemySystemInfo = [self enemySystemInfoInstanceFromConfigXmlElement:enemySystemElement];
    enemySystemElement = nil;
    
    // pass units y offset to EnemySystemInfo as well, as it will be responsible for rendering its sprites at the right position
    enemySystemInfo.unitsYOffset = uyo;
    
    // <StaticSprite> elements
    error = nil;
    NSArray *staticSpriteElements = [element nodesForXPath:@"StaticSprites/StaticSprite" error:&error];
    
    if (staticSpriteElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find StaticSprites child for this element");
        return nil; 
    }
    
    NSMutableArray *staticSpritesInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *staticSpriteElement in staticSpriteElements) 
    {
        StaticSpriteInfo *staticSpriteInfo = [self staticSpriteInfoInstanceFromConfigXmlElement:staticSpriteElement];
        [staticSpritesInfo addObject:staticSpriteInfo];
    }
    staticSpriteElements = nil;
    
    // <Actor> elements
    error = nil;
    NSArray *actorElements = [element nodesForXPath:@"Actors/Actor" error:&error];
    
    if (actorElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: ERROR: Could not find Actors child for this element");
        return nil; 
    }
    
    NSMutableArray *actorsInfo = [[NSMutableArray alloc] init];
    for (GDataXMLElement *actorElement in actorElements) 
    {
        ActorInfo *actorInfo = [self actorInfoInstanceFromConfigXmlElement:actorElement];
        [actorsInfo addObject:actorInfo];
    }
    actorElements = nil;

    GameGroup *group = [GameGroup createWithNumber:n 
                                  reqScoreToEnable:rste 
                                  reqStarsToEnable:rstarste 
                                            active:a
                                         labelText:lt
                                 uiBackgroundImage:ubi
                                       targetLayer:tl
                                      parallaxInfo:parallaxInfo
                                    treeSystemInfo:treeSystemInfo
                                   enemySystemInfo:enemySystemInfo
                                 staticSpritesInfo:staticSpritesInfo
                                        actorsInfo:actorsInfo];
    group.skyRegion = sr;
    group.timeBeforeHail = tbh;
    group.numberOfTrailers = numberOfTrailers;
    group.unitsFromEdge = ufe;
    group.unitsYOffset = uyo;
    
    
    //CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: staticSpritesInfo Retain Count %d", staticSpritesInfo.retainCount);
    //CCLOG(@"GameStateXmlHelper: gameGroupInstanceFromXmlElement: actorsInfo Retain Count %d", actorsInfo.retainCount);
    
    [staticSpritesInfo release];
    staticSpritesInfo = nil;
    
    [actorsInfo release];
    actorsInfo = nil;
    
    lt = nil;
    //gbi = nil;
    //lbi = nil;
    ubi = nil;
    return group;
}

+(GameLevel *)gameLevelInstanceFromConfigXmlElement:(GDataXMLElement *)configElement
                                 andStateXmlElement:(GDataXMLElement *)stateElement
{
    // (config)
    // <Level> attributes
    // Level Number
    int number = [self getAttributeInt:configElement name:@"Number"];
    // Group Number
    int groupNumber = [self getAttributeInt:configElement name:@"GroupNumber"];
    // Required TotScore to enable level
    int reqScoreToEnable = [self getAttributeInt:configElement name:@"ReqScoreToEnable"];
    // Required TotStars to pass level
    int reqStarsToEnable = [self getAttributeInt:configElement name:@"ReqStarsToEnable"];
    
    // <LevelActor> elements
    NSError *error = nil;
    NSArray *actorElements = [configElement nodesForXPath:@"LevelActors/LevelActor" error:&error];
    
    NSMutableArray *actorsInfo = [[NSMutableArray alloc] init];
    if (actorElements != nil) 
    { 
        for (GDataXMLElement *actorElement in actorElements) 
        {
            ActorInfo *actorInfo = [self actorInfoInstanceFromConfigXmlElement:actorElement];
            [actorsInfo addObject:actorInfo];
        }
    }
    actorElements = nil;
    
    // (state)
    // <LevelGoal> elements
    error = nil;
    NSArray *goalElements = nil;
    if(stateElement) // if we have a state xml, try to get the level goals
    {
        goalElements = [stateElement nodesForXPath:@"LevelGoals/LevelGoal" error:&error];
    }
    if(goalElements == nil) // if goal level state is null, get defaults from the config
    {
        // get goal state defaults from config
        goalElements = [configElement nodesForXPath:@"LevelGoals/LevelGoal" error:&error];
    }
    // if we got here, level goals cannot be null
    NSAssert(goalElements != nil, @"GameStateXmlHelper: gameLevelInstanceFromConfigXmlElement: EXCEPTION: Could not find LevelGoals");
    
    NSMutableArray *levelGoals = [[NSMutableArray alloc] init];
    for (GDataXMLElement *goalElement in goalElements) 
    {            
        LevelGoal *levelGoal = [self levelGoalInstanceFromXmlElement:goalElement];
        [levelGoals addObject:levelGoal];
    }
    goalElements = nil;
    
    // <LevelScores> attributes (LevelScores is a child of <Level>)
    error = nil;
    NSArray *scoresStateElements = nil;
    if(stateElement) // if we have a state xml, try to get the level scores
    {
        scoresStateElements = [stateElement elementsForName:@"LevelScores"];
    }
    if(scoresStateElements == nil) // if level scores is null, get its default from the config
    {
        // get state defaults from config
        scoresStateElements = [configElement elementsForName:@"LevelScores"];
    }
    // if we got here, level scores cannot be null
    NSAssert(scoresStateElements != nil, @"GameStateXmlHelper: gameLevelInstanceFromConfigXmlElement: EXCEPTION: Could not find LevelScores");
    
    GDataXMLElement *scoresStateElement = [scoresStateElements lastObject];
    scoresStateElements = nil;
    
    // Score, Time etc
    int score = [self getAttributeInt:scoresStateElement name:@"Score"];
    int bonus = [self getAttributeInt:scoresStateElement name:@"Bonus"];
    int starScore = [self getAttributeInt:scoresStateElement name:@"StarScore"];
    float time = [self getAttributeFloat:scoresStateElement name:@"Time"];
    time = (time*100)/100; // round to 2 decimal places
    
    int prevScore = [self getAttributeInt:scoresStateElement name:@"PrevScore"];
    int prevBonus = [self getAttributeInt:scoresStateElement name:@"PrevBonus"];
    int prevStarScore = [self getAttributeInt:scoresStateElement name:@"PrevStarScore"];
    float prevTime = [self getAttributeFloat:scoresStateElement name:@"PrevTime"];
    prevTime = (prevTime*100)/100; // round to 2 decimal places
    
    int timesPlayed = [self getAttributeInt:scoresStateElement name:@"TimesPlayed"];
    int timesPassed = [self getAttributeInt:scoresStateElement name:@"TimesPassed"];
    int timesFailed = [self getAttributeInt:scoresStateElement name:@"TimesFailed"];
    scoresStateElement = nil;
    
    // create new Game Level instance
    GameLevel *level = [GameLevel createWithNumber:number 
                                       groupNumber:groupNumber
                                  reqScoreToEnable:reqScoreToEnable
                                  reqStarsToEnable:reqStarsToEnable
                                        stateScore:score 
                                        stateBonus:bonus
                                    stateStarScore:starScore 
                                         stateTime:time 
                                         prevScore:prevScore
                                         prevBonus:prevBonus
                                     prevStarScore:prevStarScore 
                                          prevTime:prevTime
                                       timesPlayed:timesPlayed 
                                       timesPassed:timesPassed 
                                       timesFailed:timesFailed
                                        actorsInfo:actorsInfo
                                        levelGoals:levelGoals];
    [actorsInfo release];
    actorsInfo = nil;
    
    [levelGoals release];
    levelGoals = nil;
    
    return level;
}

+(GameConfigAndState *)loadGameConfigAndState 
{
    // Game Config
    GDataXMLDocument *docConfig = [self getGameConfigXmlDocument];
    GDataXMLDocument *docState = [self getGameStateXmlDocument];
    
    //NSArray *gameLevels = [doc.rootElement elementsForName:@"Level"];
    NSError *error = nil;
    
    // achievements
    int achieve10GreenApples = 0, achieve10RedApples = 0, achieve10Bananas = 0, achieve1GoldenApple = 0, achieve3GoldenApple = 0, achieve7GoldenApple = 0, achieve10GoldenApple = 0, achieveLevel18With3Stars = 0, achieveLevel33With3Stars = 0;
    NSArray *achievementElements = [docState nodesForXPath:@"//Achievements/Achievement" error:&error];
    if (achievementElements == nil || achievementElements.count == 0) 
    { 
        // try to get them from Config file
        achievementElements = [docConfig nodesForXPath:@"//Achievements/Achievement" error:&error];
        if (achievementElements == nil) 
        { 
            CCLOG(@"GameStateXmlHelper: loadGameConfigAndState: WARNING: Could not find Achievements node in state/config xml");
            return nil; 
        }
    }
    for (GDataXMLElement *achievementElement in achievementElements) 
    {
        NSString *achieveName = [self getAttributeString:achievementElement name:@"Name"];
        int achieveValue = [self getAttributeInt:achievementElement name:@"Value"];
        if(achieveValue < 0)
        {
            achieveValue = 0;
        }
        if([achieveName isEqualToString:kAchievePickyFruit10GreenApples])
        {
            if(achieveValue > 10)
            {
                achieveValue = 10;
            }
            achieve10GreenApples = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit10RedApples])
        {
            if(achieveValue > 10)
            {
                achieveValue = 10;
            }
            achieve10RedApples = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit10Bananas])
        {
            if(achieveValue > 10)
            {
                achieveValue = 10;
            }
            achieve10Bananas = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit1GoldenApple])
        {
            if(achieveValue > 1)
            {
                achieveValue = 1;
            }
            achieve1GoldenApple = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit3GoldenApple])
        {
            if(achieveValue > 3)
            {
                achieveValue = 3;
            }
            achieve3GoldenApple = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit7GoldenApple])
        {
            if(achieveValue > 7)
            {
                achieveValue = 7;
            }
            achieve7GoldenApple = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruit10GoldenApple])
        {
            if(achieveValue > 10)
            {
                achieveValue = 10;
            }
            achieve10GoldenApple = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruitPassedLevel18])
        {
            if(achieveValue > 1)
            {
                achieveValue = 1;
            }
            achieveLevel18With3Stars = achieveValue;
        }
        else if([achieveName isEqualToString:kAchievePickyFruitPassedLevel33])
        {
            if(achieveValue > 1)
            {
                achieveValue = 1;
            }
            achieveLevel33With3Stars = achieveValue;
        }
        achieveName = nil;
    }
    
    // game menu config
    NSArray *gameMenuConfigElements = [docConfig nodesForXPath:@"//GameMenuConfig" error:&error];
    if (gameMenuConfigElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: loadGameConfigAndState: WARNING: Could not find GameMenuConfig node in config xml");
        return nil; 
    }
    GDataXMLElement *gameMenuConfigElement = [gameMenuConfigElements lastObject];    
    int nog = [self getAttributeInt:gameMenuConfigElement name:@"NumberOfGroups"];
    int lpg = [self getAttributeInt:gameMenuConfigElement name:@"LevelsPerGroup"];
    int lpr = [self getAttributeInt:gameMenuConfigElement name:@"LevelsPerRow"];
    
    //CCLOG(@"loadGameConfigAndState: gameMenuConfigElements retainCount %d", gameMenuConfigElements.retainCount);
    //[gameMenuConfigElements release];
    //gameMenuConfigElements = nil;
    
    // game groups config
    NSArray *gameGroupConfigElements = [docConfig nodesForXPath:@"//Groups/Group" error:&error];
    if (gameGroupConfigElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: loadGameConfigAndState: WARNING: Could not find Groups node in config xml");
        return nil; 
    }
    NSMutableArray *groups = [[[NSMutableArray alloc] init] autorelease];
    for (GDataXMLElement *gameGroupConfigElement in gameGroupConfigElements) 
    {
        GameGroup *group = [self gameGroupInstanceFromConfigXmlElement:gameGroupConfigElement];
        [groups addObject:group];
    }
    //CCLOG(@"loadGameConfigAndState: gameGroupConfigElements retainCount %d", gameGroupConfigElements.retainCount);
    //[gameGroupConfigElements release];
    //gameGroupConfigElements = nil;
    
    // levels config
    NSArray *gameLevelConfigElements = [docConfig nodesForXPath:@"//Levels/Level" error:&error];
    if (gameLevelConfigElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: loadGameConfigAndState: WARNING: Could not find Levels node in config xml");
        return nil; 
    }
    
    // Game Levels Config and State
    NSArray *gameLevelStateElements = [docState nodesForXPath:@"//Levels/Level" error:&error];
    if (gameLevelStateElements == nil) 
    { 
        CCLOG(@"GameStateXmlHelper: loadGameConfigAndState: WARNING: Could not find Levels node in state xml");
        return nil; 
    }
    
    NSMutableArray *levels = [[[NSMutableArray alloc] init] autorelease];
    for (GDataXMLElement *gameLevelConfigElement in gameLevelConfigElements) 
    {
        int stateConfigNum = [self getAttributeInt:gameLevelConfigElement name:@"Number"];
        GDataXMLElement *gameLevelStateElement = nil;
        // get level state element
        if(gameLevelStateElements)
        {
            for (GDataXMLElement *item in gameLevelStateElements) 
            {
                int stateLevelNum = [self getAttributeInt:item name:@"Number"];
                if (stateLevelNum == stateConfigNum) 
                {
                    gameLevelStateElement = item;
                    break;
                }
            }
        }
        
        GameLevel *level = [self gameLevelInstanceFromConfigXmlElement:gameLevelConfigElement
                                                    andStateXmlElement:gameLevelStateElement];
        [levels addObject:level];
    }
    //CCLOG(@"loadGameConfigAndState: gameLevelConfigElements retainCount %d", gameLevelConfigElements.retainCount);
    //[gameLevelConfigElements release];
    //gameLevelConfigElements = nil;
    //CCLOG(@"loadGameConfigAndState: gameLevelStateElements retainCount %d", gameLevelStateElements.retainCount);
    //[gameLevelStateElements release];
    //gameLevelStateElements = nil;
    
    //CCLOG(@"loadGameConfigAndState: docState retainCount %d", docState.retainCount);
    [docState release];
    docState = nil;
    
    //CCLOG(@"loadGameConfigAndState: docConfig retainCount %d", docConfig.retainCount);
    [docConfig release];
    docConfig = nil;
    
    // create GameConfigAndState
    GameConfigAndState *gameConfigAndState = [GameConfigAndState createWithNumberOfGroups:nog
                                                                           levelsPerGroup:lpg
                                                                             levelsPerRow:lpr
                                                                                   groups:groups
                                                                                   levels:levels];
    
    CCLOG(@"loadGameConfigAndState: groups retainCount %d", groups.retainCount);
    CCLOG(@"loadGameConfigAndState: levels retainCount %d", levels.retainCount);
    groups = nil;
    levels = nil;
    
    // achievements
    gameConfigAndState.achieve10GreenApples = achieve10GreenApples;
    gameConfigAndState.achieve10RedApples = achieve10RedApples;
    gameConfigAndState.achieve10Bananas = achieve10Bananas;
    
    gameConfigAndState.achieve1GoldenApple = achieve1GoldenApple;
    gameConfigAndState.achieve3GoldenApple = achieve3GoldenApple;
    gameConfigAndState.achieve7GoldenApple = achieve7GoldenApple;
    gameConfigAndState.achieve10GoldenApple = achieve10GoldenApple;
    
    gameConfigAndState.achieveLevel18With3Stars = achieveLevel18With3Stars;
    gameConfigAndState.achieveLevel33With3Stars = achieveLevel33With3Stars;
    
    return gameConfigAndState;
}

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
    NSString *strValue = [[NSString alloc] initWithFormat:kStringFormatInt,v];
    [self addChildToElement:element name:n value:strValue];
    [strValue release];
    strValue = nil;
}
+(void)addChildToElement:(GDataXMLElement *)element
                    name:(NSString *)n 
              floatValue:(float)v
                  format:(NSString *)f
{
    NSString *strValue = [[NSString alloc] initWithFormat:f,v];
    [self addChildToElement:element name:n value:strValue];
    [strValue release];
    strValue = nil;
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
    NSString *strValue = [[NSString alloc] initWithFormat:kStringFormatInt,v];
    [self addAttributeToElement:element name:n value:strValue];
    [strValue release];
    strValue = nil;
}
+(void)addAttributeToElement:(GDataXMLElement *)element
                        name:(NSString *)n 
                  floatValue:(float)v
                      format:(NSString *)f
{
    NSString *strValue = [[NSString alloc] initWithFormat:f,v];
    [self addAttributeToElement:element name:n value:strValue];
    [strValue release];
    strValue = nil;
}


+ (void)saveGameState:(GameConfigAndState *)gcs 
{    
    GDataXMLElement *gameStateElement = [GDataXMLNode elementWithName:@"GameState"];
    
    // save achievements
    GDataXMLElement *achievementsElement = [GDataXMLNode elementWithName:@"Achievements"];
    
    GDataXMLElement *pick10greenapplesElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick10greenapplesElement name:@"Name" value:kAchievePickyFruit10GreenApples];
    [self addAttributeToElement:pick10greenapplesElement name:@"Value" intValue:gcs.achieve10GreenApples];
    [achievementsElement addChild:pick10greenapplesElement];
    
    GDataXMLElement *pick10redapplesElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick10redapplesElement name:@"Name" value:kAchievePickyFruit10RedApples];
    [self addAttributeToElement:pick10redapplesElement name:@"Value" intValue:gcs.achieve10RedApples];
    [achievementsElement addChild:pick10redapplesElement];
    
    GDataXMLElement *pick10bananasElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick10bananasElement name:@"Name" value:kAchievePickyFruit10Bananas];
    [self addAttributeToElement:pick10bananasElement name:@"Value" intValue:gcs.achieve10Bananas];
    [achievementsElement addChild:pick10bananasElement];
    
    GDataXMLElement *pick1GoldenAppleElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick1GoldenAppleElement name:@"Name" value:kAchievePickyFruit1GoldenApple];
    [self addAttributeToElement:pick1GoldenAppleElement name:@"Value" intValue:gcs.achieve1GoldenApple];
    [achievementsElement addChild:pick1GoldenAppleElement];
    
    GDataXMLElement *pick3GoldenAppleElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick3GoldenAppleElement name:@"Name" value:kAchievePickyFruit3GoldenApple];
    [self addAttributeToElement:pick3GoldenAppleElement name:@"Value" intValue:gcs.achieve3GoldenApple];
    [achievementsElement addChild:pick3GoldenAppleElement];
    
    GDataXMLElement *pick7GoldenAppleElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick7GoldenAppleElement name:@"Name" value:kAchievePickyFruit7GoldenApple];
    [self addAttributeToElement:pick7GoldenAppleElement name:@"Value" intValue:gcs.achieve7GoldenApple];
    [achievementsElement addChild:pick7GoldenAppleElement];
    
    GDataXMLElement *pick10GoldenAppleElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:pick10GoldenAppleElement name:@"Name" value:kAchievePickyFruit10GoldenApple];
    [self addAttributeToElement:pick10GoldenAppleElement name:@"Value" intValue:gcs.achieve10GoldenApple];
    [achievementsElement addChild:pick10GoldenAppleElement];
    
    // Levels Passed with 3 stars achievements
    GDataXMLElement *level18PassedWith3StarsElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:level18PassedWith3StarsElement name:@"Name" value:kAchievePickyFruitPassedLevel18];
    [self addAttributeToElement:level18PassedWith3StarsElement name:@"Value" intValue:gcs.achieveLevel18With3Stars];
    [achievementsElement addChild:level18PassedWith3StarsElement];
    
    GDataXMLElement *level33PassedWith3StarsElement = [GDataXMLNode elementWithName:@"Achievement"];
    [self addAttributeToElement:level33PassedWith3StarsElement name:@"Name" value:kAchievePickyFruitPassedLevel33];
    [self addAttributeToElement:level33PassedWith3StarsElement name:@"Value" intValue:gcs.achieveLevel33With3Stars];
    [achievementsElement addChild:level33PassedWith3StarsElement];
    
    [gameStateElement addChild:achievementsElement];
    
    // levels score
    GDataXMLElement *levelsElement = [GDataXMLNode elementWithName:@"Levels"];
    
    // update Levels
    for(GameLevel *level in gcs.levels) 
    {
        GDataXMLElement *levelElement = [GDataXMLNode elementWithName:@"Level"];
        
        // Level attributes
        [self addAttributeToElement:levelElement name:@"GroupNumber" intValue:level.groupNumber];
        [self addAttributeToElement:levelElement name:@"Number" intValue:level.number];

        // LevelScores child element
        GDataXMLElement *levelScoresElement = [GDataXMLNode elementWithName:@"LevelScores"];
        // scores attributes
        // state
        [self addAttributeToElement:levelScoresElement name:@"Score" intValue:level.stateScore];
        [self addAttributeToElement:levelScoresElement name:@"Bonus" intValue:level.stateBonus];
        [self addAttributeToElement:levelScoresElement name:@"StarScore" intValue:level.stateStarScore];
        [self addAttributeToElement:levelScoresElement name:@"Time" floatValue:level.stateTime format:@"%0.2f"];
        // previous
        [self addAttributeToElement:levelScoresElement name:@"PrevScore" intValue:level.prevScore];
        [self addAttributeToElement:levelScoresElement name:@"PrevBonus" intValue:level.prevBonus];
        [self addAttributeToElement:levelScoresElement name:@"PrevStarScore" intValue:level.prevStarScore];
        [self addAttributeToElement:levelScoresElement name:@"PrevTime" floatValue:level.prevTime format:@"%0.2f"];
        [self addAttributeToElement:levelScoresElement name:@"TimesPlayed" intValue:level.timesPlayed];
        [self addAttributeToElement:levelScoresElement name:@"TimesPassed" intValue:level.timesPassed];
        [self addAttributeToElement:levelScoresElement name:@"TimesFailed" intValue:level.timesFailed];
        [levelElement addChild:levelScoresElement];
        
        //@"LevelGoals/LevelGoal"
        GDataXMLElement *levelGoalsElement = [GDataXMLNode elementWithName:@"LevelGoals"];
        for(LevelGoal *goal in level.levelGoals)
        {
            //FruitName="OrangeHalf-32" Target="1"
            GDataXMLElement *goalElement = [GDataXMLNode elementWithName:@"LevelGoal"];
            [self addAttributeToElement:goalElement name:@"Tag" intValue:goal.tag];
            [self addAttributeToElement:goalElement name:@"FruitName" value:goal.fruitName];
            [self addAttributeToElement:goalElement name:@"Target" intValue:goal.target];
            // state
            [self addAttributeToElement:goalElement name:@"Count" intValue:goal.stateCount];
            // previous
            [self addAttributeToElement:goalElement name:@"PrevCount" intValue:goal.prevCount];
            [levelGoalsElement addChild:goalElement];
        }
        [levelElement addChild:levelGoalsElement];

        // add level element
        [levelsElement addChild:levelElement];
    }
    
    [gameStateElement addChild:levelsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] 
                                   initWithRootElement:gameStateElement];
    NSData *xmlData = document.XMLData;
    
    NSString *filePath = [self gameStateFilePath:TRUE];
    //CCLOG(@"GameStateXmlHelper: saveGameState: Saving state xml data to %@...", filePath);
    [xmlData writeToFile:filePath atomically:YES];
    [document release];
    document = nil;
    
    filePath = nil;
    xmlData = nil;
}

+(void)deleteGameState
{
    NSString *filePath = [self gameStateFilePath:TRUE];
    //CCLOG(@"GameStateXmlHelper: deleteGameState: path %@...", filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    filePath = nil;
    fileManager = nil;
    
    [[GameManager sharedInstance] loadConfigAndState];
    [GameManager setGroupNumberSelected:1];
}

+ (void)saveLevel:(GameLevel *)gl
{
    // not sure how to do this yet
}


@end
