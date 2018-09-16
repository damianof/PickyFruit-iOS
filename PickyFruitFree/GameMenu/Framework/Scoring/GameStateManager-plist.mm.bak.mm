//
//  GameStateManager.mm
//  GameMenu
//
//  Created by Damiano Fusco on 4/25/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "GameStateManager.h"


static GameStateManager *gameStateManagerInstance = nil;


@implementation GameStateManager


@synthesize 
    levels = _levels;


/*+(GameStateManager *)sharedManager
{
    NSAssert(gameStateManagerInstance != nil, @"GameStateManager not available!");
    return gameStateManagerInstance;
}*/

+(GameStateManager *)sharedGameManager
{
    if(gameStateManagerInstance != nil)
    {
        return gameStateManagerInstance;
    }
    else
    {
        return [[[self alloc] init] autorelease];
    }
}

-(id)init
{
    if((self = [super init]))
    {
        [self readPlist];
        gameStateManagerInstance = self;
    }
    
    return self;
}

-(void)readPlist
{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *path = [documentsDirectory stringByAppendingPathComponent:@"GameState.plist"];
    //[myPatients writeToFile:path atomically:YES];
    
    /*BOOL success;
	NSError *error;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"GameState.plist"];
	
	success = [fileManager fileExistsAtPath:filePath];
	if (!success) {		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"GameStateDefault" ofType:@"plist"];
		success = [fileManager copyItemAtPath:path toPath:filePath error:&error];
	}	
	
	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	
	[plistDict setValue:@"myValue" forKey:@"myKey"];
	[plistDict writeToFile:filePath atomically: YES];*/
    
    // apple's way:
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"GameState.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"GameStateDefault" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!temp) {
        CCLOG(@"GameStateManager: Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    //self.personName = [temp objectForKey:@"Name"];
    //self.levels = [NSMutableArray arrayWithArray:[temp objectForKey:@"Levels"]];
    self.levels = [NSMutableDictionary dictionaryWithDictionary:[temp objectForKey:@"Levels"]];
    int count = [self.levels count];
    CCLOG(@"GameStateManager loaded data for %d levels", count);
}

-(void)writePlist
{
    //_levels = [NSMutableDictionary dictionaryWithCapacity:2];
    //[_levels setObject:[self createLevelDataDictWithScore:3] forKey:@"1"];
    //[_levels setObject:[self createLevelDataDictWithScore:1] forKey:@"2"];
    
    NSString *error = @"";
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"GameState.plist"];
    //NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
    //                           [NSArray arrayWithObjects: self.levels, nil]
    //                                                      forKeys:[NSArray arrayWithObjects: @"Levels", nil]];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObject:_levels 
                                                          forKey:@"Levels"];
                               
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];

    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        CCLOG(@"GameStateManager writePlist error: %@", error);
        [error release];
    }
}

-(NSMutableDictionary*)createLevelDataDictWithScore:(int)s
{
    NSMutableArray *objects = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:s], nil];
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"Score", nil];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjects:objects
                                                                   forKeys:keys];
    return dict;
}

-(int)getLevelScore:(int)ln
{
    NSString *levelKey = [NSString stringWithFormat:@"%d", ln];
    id levelData = [_levels objectForKey:levelKey];

    int score = 0;
    if(levelData)
    {
        NSMutableDictionary *levelDict = (NSMutableDictionary*)levelData;
        NSNumber *numScore = (NSNumber *)[levelDict valueForKey:@"Score"];
        score = [numScore intValue];
    }
    else
    {
        [_levels setObject:[self createLevelDataDictWithScore:0] 
                    forKey:levelKey];
        //[self writePlist];
    }
    
    return score;
}

-(void)setLevelScore:(int)ln
               score:(int)s
{
    NSString *levelKey = [NSString stringWithFormat:@"%d", ln];
    [_levels setObject:[self createLevelDataDictWithScore:s] 
                    forKey:levelKey];
    [self writePlist];
}

-(int)getTotalScore
{
    int totScore = 0;
    /*for(id item in _levels) 
    {
        if(item)
        {
            NSMutableDictionary *levelDict = (NSMutableDictionary *)item;
            bool isvalid = [levelDict isKindOfClass:[NSMutableDictionary class]];
            CCLOG(@"isvalid %d", isvalid);
            CCLOG(@"class %@", [levelDict class]);
            //int count = [[levelDict allKeys] count];
            //id test = [[levelDict allKeys] objectAtIndex:0];
            //if ([[levelDict allKeys] containsObject:@"Score"]) 
            //{
            //    NSNumber *numScore = (NSNumber *)[levelDict valueForKey:@"Score"];
            //    totScore += [numScore intValue];
            //}
        }
    }*/
    
    int gameGroups = kGameGroups;
    int gameLevelsPerGroup = kGameLevelsPerGroup;
    int maxLevelAvailable = (gameGroups * gameLevelsPerGroup);
    
    for(int i = 1; i < maxLevelAvailable; i++)
    {
        NSString *levelKey = [NSString stringWithFormat:@"%d", i];
        id levelData = [_levels objectForKey:levelKey];
        if(levelData)
        {
            NSMutableDictionary *levelDict = (NSMutableDictionary*)levelData;
            NSNumber *numScore = (NSNumber *)[levelDict valueForKey:@"Score"];
            totScore += [numScore intValue];
        }
    }
    return totScore;
}

/*-(int)getLevelScoreFromDict:(int)ln
{

}*/

@end
